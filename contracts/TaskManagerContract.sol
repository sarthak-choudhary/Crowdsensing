pragma solidity >=0.5.0 <0.6.0;
import "./TaskDetailedContract.sol";

contract UserInterface {
    function isUser(address user_address) external view returns (bool isValid);
    function getUser(address user_address) external view returns (address user_ad, uint user_rep);
}

contract TaskManagerContract {
    enum Status { PENDING, COMPLETED, CANCELED }

    struct Coordinate {
        uint lat;
        uint long;
    }
    
    struct Task {
        uint task_id;
        address owner_address;
        uint owner_reputation;
        Status task_status;
        uint duration;
        string data_type;
        Coordinate location;
        uint min_reputation;
        uint deposit;
        uint total_solutions;
        uint min_payment;
        uint similarity_tolerance;
        address TDC_address;
    }
    
    Task[] tasks;
    
    uint taskCount;
    address userContractAddress = 0x7EF2e0048f5bAeDe046f6BF797943daF4ED8CB47;
    UserInterface userContract = UserInterface(userContractAddress);
    
    constructor() public {
        taskCount = 0;
    }
    
    modifier onlyUsers() {
        require(userContract.isUser(msg.sender));
        _;
    }
    
    modifier validTask(uint task_id) {
        require(task_id < tasks.length);
        _;
    }
    
    modifier isRequestor(uint task_id) {
        require(msg.sender == tasks[task_id].owner_address);
        _;
    }
    
    function addTask(uint duration, string memory data_type, uint min_reputation, uint _lat, uint _long, uint deposit, uint total_solutions, uint similarity_tolerance) onlyUsers public payable returns (uint) {
        address user_ad;
        uint user_rep;
        
        (user_ad, user_rep) = userContract.getUser(msg.sender);
        Coordinate memory _location = Coordinate(_lat, _long);
        
        Task memory task = Task(taskCount, user_ad, user_rep, Status.PENDING, duration, data_type, _location, min_reputation, deposit, total_solutions,(5 * deposit) / (total_solutions * 10), similarity_tolerance, address(0));
        TaskDetailedContract tdc = new TaskDetailedContract(task.owner_address, task.owner_reputation, task.duration, task.similarity_tolerance, task.min_payment, _lat, _long, task.data_type);
        
        task.TDC_address = address(tdc);
        tasks.push(task);
        
        
        return taskCount++;
    }
    
    function updateStatus(uint task_id, uint newStatus) validTask(task_id) isRequestor(task_id) public {
        require(newStatus <= 2);
        
        if (newStatus == 0) {
            tasks[task_id].task_status = Status.PENDING;
        } else if (newStatus == 1) {
            tasks[task_id].task_status = Status.COMPLETED;
        } else {
            tasks[task_id].task_status = Status.CANCELED;
        }
    }
    
    function reduceSolutions(uint task_id, uint decrement) validTask(task_id) isRequestor(task_id) public {
        require(tasks[task_id].total_solutions - decrement > 0, "solutions can't be less than 1");
        
        tasks[task_id].total_solutions = tasks[task_id].total_solutions - decrement;
    }


    function addReservation(string memory data_type, uint submission_time, uint distance) onlyUsers public {
        uint max_QOI = 0;
        uint task_id ;
        uint user_rep;
        
        (, user_rep) = userContract.getUser(msg.sender);
        for (uint i = 0; i < tasks.length; i++) {
            if (tasks[i].task_status == Status.PENDING && keccak256(abi.encodePacked((tasks[i].data_type))) == keccak256(abi.encodePacked((data_type))) && tasks[i].min_reputation <= user_rep) {
                uint QOI = (user_rep * 100) / (submission_time * distance);
                
                if (QOI > max_QOI) {
                    max_QOI = QOI;
                    task_id = i;
                }
            }
        }
        
        TaskDetailedContract desired_task = TaskDetailedContract(tasks[task_id].TDC_address);
        desired_task.addReservation
        
        
    }
}