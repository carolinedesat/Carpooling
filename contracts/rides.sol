// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;
 
contract Rides {

    //Payable addresses can receive ether
    address payable public owner;
    uint256 fee;
    
    //Creating Users enum to define user-data types
    enum Users {
        
        //Declaring variables type enum
        passenger,
        driver
    }

    //Creating the passagenger structure with all the necessary details
    struct passenger {
        //Declaring all necessary struct elements
        string name;
        string email;
        string phoneNumber;
        address payable passengerAddress;
        string[] rides;
        Users user;
    }

    //Creating mapping (hash tables) for passenger's data storage
    mapping(address => passenger) public passengers;
    address payable[] public passengerKeys;

    //Creating the driver structure with all the necessary details
    struct driver {
        //Declaring all necessary struct elements
        string name;
        string email;
        string phoneNumber;
        address payable driverAddress;
        string[] rides;
        Users user;
    }

    //Creating mapping (hash tables) for driver's data storage
    mapping(address => driver) public drivers;
    address payable[] public driverKeys;

    //Creating the ride structure with all the necessary details
    struct ride {
        //Declaring all necessary struct elements
        string id;
        string to;
        string from;
        string passengerId;
        string driverId;
        address payable passengerAddr;
        address payable driverAddr;
        uint256 price;
    }

    //Creating mapping (hash tables) for rides's data storage
    mapping(string => ride) public rides;
    mapping(string => bool) public existentRide;
    string[] public rideKeys;
    uint256 rideCost;

    //Constructor
    constructor() {
        owner = payable(msg.sender);
    }

    //Function which displays the balance
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    //------------------------------------------------------------

    //Creating the passenger registration event
    event passengerRegistration(address indexed _address);

    //Function which registers the passenger using attributes such as name, email and phone number
    function registerPassenger(string memory name, string memory email, string memory phoneNumber, uint256 user) external {
        passengers[msg.sender].name = name;
        passengers[msg.sender].email = email;
        passengers[msg.sender].phoneNumber = phoneNumber;
        passengers[msg.sender].user = Users(user);

        //Emitting the registration event
        emit passengerRegistration(msg.sender);
    }

    //Function which shows the passenger information
    function getPassengerInfo(address payable passengerAddress) external view returns(passenger memory) {
        return passengers[passengerAddress];
    }

    //Function which updates the passenger rides
    function updatePassengerRides (address payable passengerAddress, string memory rideId) external {
        passengers[passengerAddress].rides.push(rideId);
    }

    //------------------------------------------------------------

    //Creating the driver registration event
    event driverRegistration(address indexed _address);

    //Function which registers the driver using attributes such as name, email and phone number
    function registerDriver(string memory name, string memory email, string memory phoneNumber, uint256 user) external {
        drivers[msg.sender].name = name;
        drivers[msg.sender].email = email;
        drivers[msg.sender].phoneNumber = phoneNumber;
        drivers[msg.sender].user = Users(user);

        //Emitting the registration event
        emit driverRegistration(msg.sender);
    }

    //Function which shows the driver information
    function getDriverInfo(address payable driverAddress) external view returns (driver memory) {
        return drivers[driverAddress];
    }

    //Function which updates the driver rides
    function updateDriverRides(address payable driverAddress, string memory rideId) external {
        drivers[driverAddress].rides.push(rideId);
    }

    //This function will request a ride using attributes such as ID's, to and from locations, adresses and prices
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

    //This function shows information about the current ride
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