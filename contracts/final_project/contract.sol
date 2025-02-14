/*
TODO:
1. change funds function and balances to ERC20 tokens
    - also fundswithdrawn could be not properly secure, fix it
2. debug functionalities for contract creator and owner:
    address public owner;
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }
    constructor() {
        owner = msg.sender;
    }
    // function getUsers and other getter / setters for only owner
    // выплаты платформе доп. налог за публикацию и т.д.
3. getTask paginated?
4. createTask:
    - // TODO: secure block.timestamp with Buffers or External Time Oracles due to variance and miner manipulations
    - // https://ethereum.stackexchange.com/questions/66579/how-can-i-implement-deadlines-in-smartcontract
    - // проверка на валидный limit, description, reward, deadline с помощью require и по правилам платформы
    - // проверка или условие на лимит максимально созданных одновременных задач от одного заказчика
5. change notBlacklisted() to blacklist / dissallow list structure to store them
    - https://ethereum.stackexchange.com/questions/99127/how-do-i-blacklist-an-address-from-buying-my-token
    - https://docs.openzeppelin.com/contracts/3.x/access-control
6. struct Task - возможность участвовать над выполнением задачи несколько человек одновременно если необходимо а не только одному победителю из всех?
7. deleteTask или автоматическое удалено задачи если она не набрала N количество человек за определенное время или процент лимита
8. function participateInTask() - maybe some fee payable to enter()?
    - // require(msg.value == 1 ether, "Entry fee is exactly 1 gwei"); // fix msg.value > 1 ether, than transfer its eth to the owner
    - // require(task.worker == address(0), "Task already has a worker assigned");
    - // require(block.timestamp < task.deadline, "Task deadline has passed");
9. // function getTask / pickTask only one task by some search query or etc.
10. uint limit; participants limit или как то понятно переназвать
11. address[] participants; // possible_participants
12. pickTaskWorker / // Winner // assignTask
    - // require(msg.sender == owner, "Only the owner can pick a winner");
    - // can be called by system / owner or by creator of task?
    - worker reroll system?
    - threshold:
        - // This is 50% of the task limit. You can adjust this value to make it customizable later.
        - // типа 50 процентов это настройка от платформы (но в дальнейшем можно будет кастомизироать это)
13. external vs internal vs public function
14. // unsafeRandom TODO: fix unsafe random - better to use Chainlink to safe random generator
    - // Task[] Task.participants.length block.difficulty, now, players
15 // address payable winner = payable(participants[index]);, // winner.transfer(address(this).balance); send notification to winner
*/

/*
upload to ipfs from ethersjs
// contract versioning solidity
TODO: ERC20 tokens as rating and other internal currency form
TODO: some functionality for owner of contract
TODO: static (code and binary) and dynamic analysis for vulnerabilities
TODO: SafeMath functions
TODO: secure and cheap random number generator
- it is possible to use like `uint256 random = uint(keccak256(abi.encodePacked(block.difficulty,block.timestamp,people)));`, but
Random numbers are not possible by design in solidity.
Every node that runs the transaction needs to come up with the same exact state, the language execution has to be deterministic.
Whatever you come up with will be pseudo-random and can be manipulated.
If you need random numbers, you'll have to use an Oracle. Chainlink has the most popular random oracle.
- but It is possible to do it safely via a commit/reveal scheme:
Say you want generate a shared random number for X users that can only be used once:
All Users pick a random number R off-chain (or the client does for them).
They send the hash of R to the smart contract where it's stored. (Commit phase)
After all users have sent their hashes, they send their R. (Reveal phase)
The contract verifies that for each user the previously submitted hash matches the hash of their submitted R.
If all hashes match, you can now use the combined (hashed, XORed etc.) Rs as the seed for your RNG function
Of course this only works if all users participate in both phases and you will have to decide what to do with users who attempt to cheat (where the hashes don't match) or who skip a phase.
- source - https://stackoverflow.com/questions/48848948/how-to-generate-a-random-number-in-solidity
// import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

// contract RandomNumberGenerator is VRFConsumerBase {
//     bytes32 internal keyHash;
//     uint256 internal fee;
//     uint256 public randomResult;

//     event RandomNumberRequested(bytes32 requestId);
//     event RandomNumberReceived(uint256 randomNumber);

//     constructor(
//         address vrfCoordinator,
//         address linkToken,
//         bytes32 _keyHash,
//         uint256 _fee
//     ) VRFConsumerBase(vrfCoordinator, linkToken) {
//         keyHash = _keyHash;
//         fee = _fee;
//     }

//     function getRandomNumber() public returns (bytes32 requestId) {
//         require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK");
//         requestId = requestRandomness(keyHash, fee);
//         emit RandomNumberRequested(requestId);
//     }

//     function fulfillRandomness(bytes32 requestId , uint256 randomness) internal override {
//         randomResult = randomness;
//         emit RandomNumberReceived(randomness);
//     }
// }
//     function rateUser(address user, bool success) external onlyRegistered {
//         require(users[user].registered, "User not registered");
//         if (success) {
//             users[user].rating += 10;
//         } else {
//             users[user].rating = users[user].rating > 50 ? users[user].rating - 50 : 0;
//         }
//         emit UserRated(user, success ? 10 : -50); // TypeError: Invalid type for argument in function call. Invalid implicit conversion from uint8 to int256 requested
//     }
// }
*/

contract OutsourceKZ {
    enum TaskStatus { 
        Pending, 
        InProgress,
        Completed,
        Canceled
    }
    
    struct Task {
        string description;
        uint reward;
        address creator;
        address worker;
        TaskStatus status;
        uint deadline; // in seconds (unix time)
        uint limit;
        address[] participants;
        string report;
    }

    struct User {
        int rating;
        bool is_active;
    }

    mapping(address => User) public users;
    mapping(address => uint) public balances;
    Task[] public tasks;

    event FundsDeposited(address indexed user, uint amount);
    event FundsWithdrawn(address indexed user, uint amount);
    event TaskCreated(uint indexed taskId, string description, uint reward, address creator);
    event TaskAssigned(uint indexed taskId, address worker);
    event TaskCompleted(uint indexed taskId, address worker);
    event UserRated(address indexed user, int change);

    modifier onlyRegistered() {
        require(users[msg.sender].is_active, "Not registered");
        _;
    }

    modifier onlyCreator(uint taskId) {
        require(tasks[taskId].creator == msg.sender, "Not task creator");
        _;
    }

    modifier onlyWorker(uint taskId){
        require(tasks[taskId].worker == msg.sender, "Not task worker");
        _;
    }

    modifier notBlacklisted() {
        require(users[msg.sender].rating >= 100, "User is blacklisted");
        _;
    }

    function register() external {
        require(!users[msg.sender].is_active, "Already registered");
        users[msg.sender] = User({rating: 1000, is_active: true});
    }

    function depositFunds() external payable onlyRegistered {
        require(msg.value > 10000 gwei, "Must send gwei"); // change to eth or something else
        balances[msg.sender] += msg.value;
        emit FundsDeposited(msg.sender, msg.value);
    }

    function withdrawFunds(uint amount) external onlyRegistered {
        require(balances[msg.sender] >= amount, "Insufficient funds");
        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit FundsWithdrawn(msg.sender, amount);
    }

    function getTasks() public view returns(Task[] memory) { // only registered?
        return tasks;
    }

    function createTask(string memory description, uint reward, uint deadline, uint limit) external onlyRegistered notBlacklisted {
        require(balances[msg.sender] >= reward, "Insufficient balance");
        address[] memory emptyParticipants;
        tasks.push(Task({
            description: description,
            reward: reward,
            creator: msg.sender,
            worker: address(0),
            status: TaskStatus.Pending,
            deadline: block.timestamp + deadline,
            limit: limit,
            participants: emptyParticipants,
            report: ""
        }));
        balances[msg.sender] -= reward;
        emit TaskCreated(tasks.length - 1, description, reward, msg.sender);
    }
    
    function participateInTask(uint taskId) public onlyRegistered notBlacklisted {
        Task storage task = tasks[taskId];
        require(task.creator != msg.sender, "Creator cannot participate in their own task");
        require(task.status == TaskStatus.Pending, "Cannot participate in non-pending task");
        require(task.participants.length <= task.limit, "Participants limit exceeded");
        for (uint i = 0; i < task.participants.length; i++) {
            require(task.participants[i] != msg.sender, "You have already registered to this task");
        }
        task.participants.push(msg.sender);
    }

    function pickTaskWorker(uint taskId) public onlyRegistered notBlacklisted onlyCreator(taskId) {
        Task storage task = tasks[taskId];
        require(task.status == TaskStatus.Pending, "Cannot pick worker for non-pending task");
        // require(participants.length > 0, "No possible participants in the task");
        // require(tasks[taskId].worker == address(0), "Task already assigned");
        uint threshold = task.limit / 2;
        require(task.participants.length >= threshold, "Not enough participants for task");
        uint index = unsafeRandom() % task.participants.length;
        address worker = task.participants[index];
        task.worker = worker; // tasks[taskId].worker = worker;
        task.status = TaskStatus.InProgress; // tasks[taskId].status = TaskStatus.InProgress;
        emit TaskAssigned(taskId, worker);
    }

    function unsafeRandom() private view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.timestamp, block.prevrandao)));
    }

    function completeTask(uint taskId, string memory report) public onlyRegistered notBlacklisted onlyWorker(taskId) {
        Task storage task = tasks[taskId];
        require(task.status == TaskStatus.InProgress, "Cannot complete non in progress task");
        require(block.timestamp <= tasks[taskId].deadline, "Deadline passed");
        task.status = TaskStatus.Completed; // tasks[taskId].status
        task.report = report;
        balances[msg.sender] += tasks[taskId].reward;
        users[msg.sender].rating += 10;
        emit TaskCompleted(taskId, msg.sender);
        emit UserRated(msg.sender, 10);
    }
}