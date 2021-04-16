pragma solidity >=0.5.0 <0.6.0;

contract UserInterface {
    function isUser(address user_address) external view returns (bool isValid);
    function getUser(address user_address) external view returns (address user_ad, uint user_rep);
    function updateStatistics(uint user_id, uint accepted_requests, uint cancelled_requests, uint total_requests) external;
    function updateReputation(address user_address, uint factor) external; 
    function increaseAccepted(address user_address) external;
    function increaseCancelled(address user_address) external;
}

contract TaskDetailedContract {
    event ReservationApproved(address worker_address, uint task_id);
    
    address userContractAddress = 0x7EF2e0048f5bAeDe046f6BF797943daF4ED8CB47;
    UserInterface userContract = UserInterface(userContractAddress);
    
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
    uint public deposit;
    
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
    
    modifier singleReservation(address worker_address) {
        bool isPresent = false;
        
        for(uint i = 0; i < reservations.length; i++) {
            if (reservations[i].worker_address == worker_address) {
                isPresent = true;
                break;
            }
        }
        
        require(isPresent == false, "a worker can make single reservation");
        _;
    }
    
    function setDeposit(uint _deposit) external {
        deposit = _deposit;    
    }
    
    function  getReservation(address worker_address) internal returns (uint) {
        bool isPresent = false;
        uint solution_id = 0;
        
        for (uint i = 0; i < solutions.length; i++) {
            if (solutions[i].worker_address == worker_address) {
                isPresent = true;
                solution_id = solutions[i].id;
                break;
            }
        }
        
        require(isPresent, "worker need a reservation in order to add solution");
        return solution_id;
    }
    
    function addReservation(address _worker_address, uint _duration, uint _distance, uint _reputation, uint _quality_of_information) singleReservation(_worker_address) external returns (uint) {
        reservations.push(Reservation(reservationsCount, _worker_address, _duration, _distance, _reputation, _quality_of_information));
        return reservationsCount++;
    }
    
    function evaluateReservations() external {
        for (uint i = 0; i < reservationsCount; i++) {
            solutions.push(Solution(solutionsCount, reservations[i].worker_address, reservations[i].duration, 0, reservations[i].reputation, 0));
            solutionsCount++;
        }
    }
    
    function addSolution(address worker_address ,uint data) external {
        uint solution_id = getReservation(worker_address);
        
        solutions[solution_id].data = data;
    }
    
    function makePayments(uint total_quality) payable external {
        uint remaining_deposit = deposit - (min_payment * solutions.length);
        
        for (uint i = 0; i < solutions.length; i++) {
            uint quality_based_payment = (remaining_deposit * solutions[i].quality) / total_quality;
            uint amount = min_payment + quality_based_payment;
            
            address payable worker = address(uint160(solutions[i].worker_address));
            
            worker.transfer(amount * 1 ether);
        }
    }
    
    function evaluateSolutions() external returns (uint)  {
        uint total_data = 0;
        uint total_quality = 0;
        
        for (uint i = 0; i < solutions.length; i++) {
            total_data = total_data + solutions[i].data;
        }
        
        uint avg_data = total_data / solutions.length;
        
        for (uint i = 0; i < solutions.length; i++) {
            uint solution_quality;
            
            if (solutions[i].data == avg_data) {
                solution_quality = 100;
            } else if (solutions[i].data > avg_data) {
                solution_quality = 100 / (solutions[i].data - avg_data);
            } else {
                solution_quality = 100 / (avg_data - solutions[i].data);
            }
            
            solutions[i].quality = solution_quality;
            total_quality = total_quality + solution_quality;
            
            userContract.increaseAccepted(solutions[i].worker_address);
            userContract.updateReputation(solutions[i].worker_address, 20); //factor value hard coded to 20 for every correct suubmission
            
        }
        
        return total_quality;
    }
    
    
    
}