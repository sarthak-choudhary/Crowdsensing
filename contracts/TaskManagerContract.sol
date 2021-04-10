pragma solidity >=0.5.0 <0.6.0;

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
        Coordinate memory location = Coordinate(_lat, _long);
        uint min_payment = (5 * deposit) / (total_solutions * 10);
        
        tasks.push(Task(taskCount, user_ad, user_rep, Status.PENDING, duration, data_type, location, min_reputation, deposit, total_solutions, min_payment, similarity_tolerance));
        
        
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
}