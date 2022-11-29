// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

//Defining Contract 
contract Rides {

    address payable public owner;
    uint256 amount;

    fallback() external payable {}
    receive() external payable {}
    
    //Creating Users Enum to define user-data types
    enum Users {
        
        // declaring variables type enum
        passenger,
        driver
    }

    //Creating the passagenger structure with all the necessary details
    struct passenger {
        //Declaring different struct elements
        string name;
        string email;
        string phoneNumber;
        address payable passengerAddress;
        string[] rides;
        Users user;
    }

    //Creating mapping(hash tables) for data storage
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

    struct ride {
        string id;
        string to;
        string from;
        string passengerId;
        string driverId;
        address payable passengerAddr;
        address payable driverAddr;
        uint256 price;
    }

    //Hash
    mapping(string => ride) public rides;
    mapping(string => bool) public existentRide;
    string[] public rideKeys;
    uint256 rideCost;

    constructor() {
        owner = payable(msg.sender);
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    //passenger

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

    function updatePassengerRides (address payable passengerAddress, string memory rideId) external {
        passengers[passengerAddress].rides.push(rideId);
    }

    //driver

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

    function updateDriverRides(address payable driverAddress, string memory rideId) external {
        drivers[driverAddress].rides.push(rideId);
    }

    function requestRide(string memory id, string memory to, string memory from, string memory passengerId, string memory driverId, address payable passengerAddress, address payable driverAddress, uint256 price) external {
        rides[id].id = id;
        rides[id].to = to;
        rides[id].from = from;
        rides[id].passengerId = passengerId;
        rides[id].driverId = driverId;
        rides[id].passengerAddress = passengerAddress;
        rides[id].driverAddress = driverAddress;
        rides[id].price = price;
    }

    function getRideInfo(string memory id) external view returns (ride memory) {
        return (rides[id]);
    }

    function passengerPaymentRefund(address payable passengerAddress, uint256 amount) external {
        require(msg.sender == owner, "Permission denied");
        require(passengerAddress != address(0), "Permission denied");
        (bool success,) = passengerAddress.call{value: amount}("");
        require(success, "Request failed");
    }

    function passengerPaymentAndConfirmation(string memory id) external payable {
        require(msg.value == rideCost + rides[id].price, "Error");
    }

    function driverConfirmation() external payable {
        require(msg.value == rideCost, "Error");
    }

}