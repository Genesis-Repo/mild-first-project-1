// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract DecentralizedExchange {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    address public admin;
    mapping(address => mapping(address => uint256)) public balances;

    event Deposit(address indexed token, address indexed user, uint256 amount);
    event Withdraw(address indexed token, address indexed user, uint256 amount);
    event Trade(address indexed tokenGive, uint256 amountGive, address indexed tokenGet, uint256 amountGet);

    constructor() {
        admin = msg.sender;
    }

    function deposit(address _token, uint256 _amount) external {
        IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);
        balances[_token][msg.sender] = balances[_token][msg.sender].add(_amount);
        emit Deposit(_token, msg.sender, _amount);
    }

    function withdraw(address _token, uint256 _amount) external {
        require(balances[_token][msg.sender] >= _amount, "Insufficient balance");
        
        balances[_token][msg.sender] = balances[_token][msg.sender].sub(_amount);
        IERC20(_token).safeTransfer(msg.sender, _amount);
        emit Withdraw(_token, msg.sender, _amount);
    }
    
    function trade(address _token, uint256 _amount, address _forToken) external {
        require(balances[_token][msg.sender] >= _amount, "Insufficient balance");
        
        // Calculate the amount to receive based on the swap ratio
        uint256 amountToReceive = (_amount * getExchangeRate(_token, _forToken)) / 1e18;
        
        // Ensure the contract has enough balance to perform the swap
        require(balances[_forToken][address(this)] >= amountToReceive, "Insufficient liquidity");
        
        // Perform the token swap
        balances[_token][msg.sender] = balances[_token][msg.sender].sub(_amount);
        balances[_forToken][msg.sender] = balances[_forToken][msg.sender].add(amountToReceive);
        
        emit Trade(_token, _amount, _forToken, amountToReceive);
    }
    
    function getExchangeRate(address _tokenA, address _tokenB) public view returns (uint256) {
        // Example: Return a fixed exchange rate of 1:100 between token A and token B
        return 100;
    }
}