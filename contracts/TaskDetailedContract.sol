pragma solidity >=0.5.0 <0.6.0;

contract TaskDetailedContract {
    struct Reservation {
        uint id;
        address worker_address;
        uint duration;
        uint distance;
        uint reputation;
        uint quality_of_information;
    }
    
    struct Solution {
        uint id;
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
    
    function addReservation(address _worker_address, uint _duration, uint _distance, uint _reputation, uint _quality_of_information) external returns (uint) {
        reservations.push(Reservation(reservationsCount, _worker_address, _duration, _distance, _reputation, _quality_of_information));
        return reservationsCount++;
    }
    
}