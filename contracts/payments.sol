// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

import "./rides.sol";

contract Payments { //the whole code works

    //referencing: https://docs.soliditylang.org/en/v0.8.17/solidity-by-example.html

    address payable public passenger; //sender
    address payable public driver; //recipient
    uint256 public expiration; //timeout

    constructor(address payable _driver, uint duration) payable {
        passenger = payable(msg.sender);
        driver = _driver;
        expiration = block.timestamp + duration;
    }

    function close(uint256 amount, bytes memory signature) external {
        require(msg.sender == driver);
        require(isValidSignature(amount, signature));

        driver.transfer(amount);
        selfdestruct(passenger);
    }

    function extend(uint256 newExpiration) external {
        require(msg.sender == passenger);
        require(newExpiration > expiration);
        expiration = newExpiration;
    }

    function claimTimeout() external {
        require(block.timestamp >= expiration);
        selfdestruct(passenger);
    }

    function isValidSignature(uint256 amount, bytes memory signature) internal view returns (bool) {
        bytes32 message = prefixed(keccak256(abi.encodePacked(this, amount)));
        return recoverSigner(message, signature) == passenger;
    }

    function splitSignature(bytes memory sig) internal pure returns (uint8 v, bytes32 r, bytes32 s) {
        require(sig.length == 65);

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }

        return (v, r, s);

    }

    function recoverSigner(bytes32 message, bytes memory sig) internal pure returns (address) {
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(sig);

        return ecrecover(message, v, r, s);
    }

    function prefixed(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

}