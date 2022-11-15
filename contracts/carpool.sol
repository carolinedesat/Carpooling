// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

contract Carpool {

    //PAYMENTS
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
        require(msg.sender == sender);
        require(newExpiration > expiration);
        expiration = newExpiration;
    }

    function claimTimeout() external {
        require(block.timestamp >= expiration);
        selfdestruct(sender);
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

    //----------------------------------------------------------------------------------------------------
    //RIDES
    
    enum Users {
        passenger,
        driver
    }

    struct passenger {
        string name;
        string email;
        string phoneNumber;
        address payable passengerAddress;
        string[] rides;
        Users user;
    }

    string location;

    mapping(address => passenger) public passengers;
    address payable[] public passengerKeys;

    struct driver {
        string name;
        string email;
        string phoneNumber;
        address payable driverAddress;
        string[] rides;
        Users user;
    }

    mapping(address => driver) public drivers;
    address payable[] public driverKeys;

    event passengerRegistration(address indexed _address);

    function registerPassenger(string memory name, string memory email, string memory phoneNumber, uint256 user) external {
        passengers[msg.sender].name = name;
        passengers[msg.sender].email = email;
        passengers[msg.sender].phoneNumber = phoneNumber;
        passengers[msg.sender].user = Users(user);

        emit passengerRegistration(msg.sender);
    }

    getPassengerInfo(address payable passengerAddr) external view returns(Passenger memory) {
        return passengers[passengerAddr];
    }

    event driverRegistration(address indexed _address);

    function registerDriver(string memory name, string memory email, string memory phoneNumber, uint256 user) external {
        drivers[msg.sender].name = name;
        drivers[msg.sender].email = email;
        drivers[msg.sender].phoneNumber = phoneNumber;
        drivers[msg.sender].user = Users(user);

        emit driverRegistration(msg.sender);
    }

    getDriverInfo(address payable driverAddr) external view returns (Driver memory) {
        return drivers[driverAddr];
    }

    struct ride {
        address payable passengerAddr;
        address payable driverAddr;
        uint256 amount;
    }

    mapping(string => ride) public rides;
    string[] public rideKeys;
    uint256 rideAmount;

}