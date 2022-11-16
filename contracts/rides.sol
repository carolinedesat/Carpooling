// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

contract Rides {
    
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

    function getPassengerInfo(address payable passengerAddress) external view returns(passenger memory) {
        return passengers[passengerAddress];
    }

    event driverRegistration(address indexed _address);

    function registerDriver(string memory name, string memory email, string memory phoneNumber, uint256 user) external {
        drivers[msg.sender].name = name;
        drivers[msg.sender].email = email;
        drivers[msg.sender].phoneNumber = phoneNumber;
        drivers[msg.sender].user = Users(user);

        emit driverRegistration(msg.sender);
    }

    function getDriverInfo(address payable driverAddress) external view returns (driver memory) {
        return drivers[driverAddress];
    }

    struct ride {
        address payable passengerAddress;
        address payable driverAddress;
        uint256 amount;
    }

    mapping(string => ride) public rides;
    string[] public rideKeys;
    uint256 rideAmount;

}