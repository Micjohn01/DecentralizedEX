// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Exchange {
    struct Token {
        string name;
        uint256 totalSupply;
        mapping(address => uint256) balances;
    }

    mapping(address => Token) public tokens;
    mapping(address => mapping(address => uint256)) public orders;

    event TokenAdded(address indexed tokenAddress, string name, uint256 initialSupply);
    event Deposit(address indexed token, address indexed user, uint256 amount);
    event Withdrawal(address indexed token, address indexed user, uint256 amount);
    event OrderPlaced(address indexed fromToken, address indexed toToken, address indexed user, uint256 amount);
    event OrderFulfilled(address indexed fromToken, address indexed toToken, address indexed user, uint256 amount);

    function addToken(address tokenAddress, string memory name, uint256 initialSupply) public {
        require(tokens[tokenAddress].totalSupply == 0, "Token already exists");
        tokens[tokenAddress].name = name;
        tokens[tokenAddress].totalSupply = initialSupply;
        tokens[tokenAddress].balances[msg.sender] = initialSupply;
        emit TokenAdded(tokenAddress, name, initialSupply);
    }

    function deposit(address token) public payable {
        require(tokens[token].totalSupply > 0, "Token does not exist");
        tokens[token].balances[msg.sender] += msg.value;
        emit Deposit(token, msg.sender, msg.value);
    }

    function withdraw(address token, uint256 amount) public {
        require(tokens[token].balances[msg.sender] >= amount, "Insufficient balance");
        tokens[token].balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdrawal(token, msg.sender, amount);
    }

    function placeOrder(address fromToken, address toToken, uint256 amount) public {
        require(tokens[fromToken].balances[msg.sender] >= amount, "Insufficient balance");
        tokens[fromToken].balances[msg.sender] -= amount;
        orders[fromToken][toToken] += amount;
        emit OrderPlaced(fromToken, toToken, msg.sender, amount);
    }

    function fulfillOrder(address fromToken, address toToken, uint256 amount) public {
        require(orders[fromToken][toToken] >= amount, "Insufficient order amount");
        require(tokens[toToken].balances[msg.sender] >= amount, "Insufficient balance to fulfill");
        
        orders[fromToken][toToken] -= amount;
        tokens[toToken].balances[msg.sender] -= amount;
        tokens[fromToken].balances[msg.sender] += amount;
        tokens[toToken].balances[address(this)] += amount;
        
        emit OrderFulfilled(fromToken, toToken, msg.sender, amount);
    }

    function getBalance(address token, address user) public view returns (uint256) {
        return tokens[token].balances[user];
    }

    function getOrderAmount(address fromToken, address toToken) public view returns (uint256) {
        return orders[fromToken][toToken];
    }
}