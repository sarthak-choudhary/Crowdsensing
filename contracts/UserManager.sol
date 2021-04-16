pragma solidity >=0.5.0 <0.6.0;
contract UserManagerContract {
    enum types { REQUESTER, WORKER}
    
    struct User {
        uint user_id;
        address user_address;
        types user_type;
        uint reputation;
        uint accepted_requests;
        uint cancelled_requests;
        uint total_requests;
    }
    
    User[] users;
    mapping(address => uint) public UserToId;
    
    uint userCounter;
    uint public default_reputation;
    
    constructor() public {
        userCounter = 0;
        default_reputation = 100;
    }
    
    
    function() external payable {
        
    }
    
    function isUser(address user_address) external view returns (bool isValid) {
        isValid = false;
        
        for (uint i = 0; i < users.length; i++) {
            if (users[i].user_address == user_address) {
                isValid = true;
                break;
            }
        }
    }
    
    function getUser(address user_address) external view returns (address user_ad, uint user_rep) {
        User storage current_user = users[UserToId[user_address]];
        user_ad = current_user.user_address;
        user_rep = current_user.reputation;
    }
    

    
    function addUser(uint user_type) public {
        require(user_type == 0 || user_type == 1);
        
        types t;
        
        if (user_type == 0) {
            t = types.REQUESTER;
        } else {
            t = types.WORKER;
        }
        users.push(User(userCounter, msg.sender, t, default_reputation, 0, 0, 0));
        UserToId[msg.sender] = userCounter; 
        userCounter++;
    }
    
    function updateStatistics(uint user_id, uint accepted_requests, uint cancelled_requests, uint total_requests) external {
        require(user_id >= 0);
        users[user_id].accepted_requests = accepted_requests;
        users[user_id].cancelled_requests = cancelled_requests;
        users[user_id].total_requests = total_requests;     
        
    }
    
    function increaseAccepted(address user_address) external {
        users[UserToId[user_address]].accepted_requests++;
        users[UserToId[user_address]].total_requests++;
    }
    
    function increaseCancelled(address user_address) external {
        users[UserToId[user_address]].cancelled_requests++;
        users[UserToId[user_address]].total_requests++;
    }
    
    function updateReputation(address user_address, uint factor) external {
        require(factor <= 100);
        uint user_id = UserToId[user_address];
        uint new_reputation = (factor * users[user_id].reputation/100) * 100 + ((100 - factor) * users[user_id].accepted_requests)/users[user_id].total_requests;
        users[user_id].reputation = new_reputation;
    }
}