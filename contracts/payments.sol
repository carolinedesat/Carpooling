// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

contract Payment {

    address payable public passenger; //sender
    address payable public driver; //recipient

    constructor(address payable _driver, uint distance) {
        passenger = payable(msg.sender);
        driver = _driver;
        distance = block.timestamp + distance;
    }

    function isValidSignature(uint amount, bytes memory signature) internal view returns (bool) {
        bytes32 message = prefixed(keccak256(abi.encodePacked(this, amount)));
        return recoverSigner(message, signature) == passenger;
    }

    function close(uint amount, bytes memory signature) public {
        require(msg.sender == driver);
        require(isValidSignature(amount, signature));

        driver.transfer(amount);
        selfdestruct(passenger);
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

//   function payDriver(address receiver, uint amount) public returns(bool success) {
//         if (balances[msg.sender] < amount) return false;
//         balances[msg.sender] -= amount;
//         balances[receiver] += amount;
//         emit Transfer(msg.sender, driver, amount);
//         return true;
//    }

}