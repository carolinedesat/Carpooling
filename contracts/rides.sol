// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

contract Rides {

    enum Titles {
        passenger,
        driver
    }

    struct passenger {
        string name;
        string email;
        string phoneNumber;
        address payable passengerAddress;
        string[] rides;
        Titles title;
    }

    struct driver {
        string name;
        string email;
        string phoneNumber;
        address payable driverAddress;
        string[] rides;
        Titles title;
    }

    event passengerRegistration(address indexed _address);

    function registerPassenger(string memory name, string memory email, string memory phoneNumber, uint256 title) external {
        passengers[msg.sender].name = name;
        passengers[msg.sender].email = email;
        passengers[msg.sender].phoneNumber = phoneNumber;
        passengers[msg.sender].title = Titles(title);

        emit passengerRegistration(msg.sender);
    }

    event driverRegistration(address indexed _address);

    function registerDriver(string memory name, string memory email, string memory phoneNumber, uint256 title) external {
        drivers[msg.sender].name = name;
        drivers[msg.sender].email = email;
        drivers[msg.sender].phoneNumber = phoneNumber;
        drivers[msg.sender].title = Titles(title);

        emit driverRegistration(msg.sender);
    }

}