pragma solidity ^0.6.6;

contract TaskDetailedContract {
    struct Reservation {
        address worker_address;
        uint duration;
        uint distance;
        uint reputation;
        uint quality_of_information;
    }
    
    struct Solution {
        address worker_address;
        uint duration;
        uint data;
        uint reputation;
        uint quality;
    }
    
    struct Coordinate {
        uint lat;
        uint long;
    }
    
    address public owner_address;
    uint public owner_reputation;
    
    uint public duration;
    string public data_type;
    uint public similarity_tolerance;
    uint public total_solutions;
    Coordinate public location;
    uint public min_payment;
    
    Reservation[] reservations;
    Solution[] solutions;
    
    uint reservationsCount;
    uint solutionsCount;
    
    constructor(address _owner_address, uint _owner_reputation, uint _duration,  uint _similarity_tolerance, uint _min_payment, uint _lat, uint _long, string memory _data_type) public {
        owner_address = _owner_address;
        duration = _duration;
        data_type = _data_type;
        similarity_tolerance = _similarity_tolerance;
        location = Coordinate(_lat, _long);
        min_payment = _min_payment;
        reservationsCount = 0;
        solutionsCount = 0;
    }
    
    function addReservation() external {
        
    }
}