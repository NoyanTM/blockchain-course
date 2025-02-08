// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.26;

// Assignment 3
// Task 4: DONE
contract CounterWithLimitations {
    uint256 public count; // A public variable uint256 public count that stores the current value of the counter.

    function increment(uint256 value) public {
        if(value > 10){ // Reverts if value is greater than 10.
            count = count;
        }
        else {
            count += value;
        }
    }

    function decrement(uint256 value) public {
        if(value > count){ // Reverts if value is greater than the current counter value.
            count = count;
        } else{
            count -= value;
        }
    }
}

// Task 5: DONE
contract GuessTheNumber {
    uint256 private secretNumber;

    constructor(uint256 _secretNumber){
        secretNumber = _secretNumber;
    }

    function guess(uint256 guessedNumber) public view returns(bool){
        bool temp_value;
        if(guessedNumber == secretNumber){
            temp_value = true;
        } else {
            temp_value = false;
        }
        return temp_value;
    }

}

// Task 6: DONE
contract Lottery {
    address[] public players; // participants
    address payable owner;

    constructor(){
        owner = payable(msg.sender);
    }

    function enter() public payable {
        // Requires the sender to send 1 ETH to participate.
        require(msg.value == 1 gwei, "Entry fee is exactly 1 gwei"); // fix msg.value > 1 ether, than transfer its eth to the owner

        // Adds the sender’s address to the players array.
        players.push(msg.sender);
    }

    function pickWinner() public {
        // Can only be called by the owner of the contract
        require(msg.sender == owner, "Only the owner can pick a winner");
        
        // Picks a random winner from the players array and sends them the contract's balance.
        require(players.length > 0, "No players in the lottery");

        // better to use Chainlink to safe random generator
        uint index = unsafeRandom() % players.length;
        address payable winner = payable(players[index]);
        winner.transfer(address(this).balance);
        delete players;
    }

    function unsafeRandom() private view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, players.length)));
    }
}

// Task 7: DONE
contract AccessControl { // allows restricted access to certain functions
    address payable owner; // admin or deployer's address

    constructor(){
        owner = payable(msg.sender);
    }

    // function modifier restricts access to functions
    // like decorators in other languages
    modifier onlyAdmin() {
        require(msg.sender == owner, "Access denied: only for administrator");
        _;
    }

    function changeAdmin(address payable newAdmin) public onlyAdmin{
        // Changes the admin address.
        // Can only be called by the current admin.
        // require(newAdmin != address(0), "Invalid address");
        owner = newAdmin;
    }

    function restrictedFunction() public onlyAdmin view returns (bool){
        // that can only be called by the admin
        bool temp_value = true;
        return temp_value;
    }
}

// Task 8: DONE
contract ERC20LikeToken {
    string public name;
    string public symbol;
    uint256 public totalSupply;
    mapping(address => uint256) public balances;

    constructor(string memory _name, string memory _symbol, uint256 _initialSupply) {
        name = _name;
        symbol = _symbol;
        totalSupply = _initialSupply;
        balances[msg.sender] = _initialSupply;
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        require(to != address(0), "Invalid recipient");

        balances[msg.sender] -= amount;
        balances[to] += amount;
        return true;
    }

    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }
}

// Task 9: DONE
contract SavingAccount {
    mapping(address => uint256) public balances;

    function deposit() public payable {
        require(msg.value > 0, "Deposit amount must be greater than zero");
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) public {
        require(balances[msg.sender] >= amount, "Insufficient balance");

        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
    }

    function getBalance() public view returns (uint256) {
        return balances[msg.sender];
    }
}

// Task 10: DONE
contract TimeLocked {
    uint256 public unlockTime;
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function setUnlockTime(uint256 time) public {
        require(msg.sender == owner, "Only owner can set unlock time");
        require(time > block.timestamp, "Unlock time must be in the future");

        unlockTime = time;
    }

    function deposit() public payable {
        require(msg.value > 0, "Deposit must be greater than zero");
    }

    function withdraw() public {
        require(block.timestamp >= unlockTime, "Funds are locked");
        require(address(this).balance > 0, "No funds available");

        payable(owner).transfer(address(this).balance);
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
