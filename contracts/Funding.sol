// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

// written 2024
// please do not try to hack this contract 
// if you ignore my plea and are successful, you can email me at okaforchidubem7@gmail.com

contract Funding is ReentrancyGuard {
    address public immutable owner;
    address private immutable factoryOwner;
    uint public immutable maxAmount;
    uint public immutable unlockTime;
    uint public immutable minAmount;
    uint public immutable feePercentage;
    address public immutable contractAddress = address(this);

    uint public totalFunds;
    string public issueLink;

    mapping(address => uint) public contributors;

    event ContributionMade(address indexed owner, address indexed sender, uint amount, uint totalAmount);
    event FundsWithdrawn(address indexed owner, uint amount);
    event FeeTransferred(address indexed factoryOwner, uint fee);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    constructor(
        address _owner,
        string memory _issueLink,
        uint _maxAmount,
        uint _unlockTime,
        uint _minAmount,
        uint _feePercentage,
        address _factoryOwner
    ) {
        require(_owner != address(0), "Invalid owner address");
        require(_factoryOwner != address(0), "Invalid factory owner address");
        require(_maxAmount > 0, "Max amount must be greater than zero");
        require(_minAmount > 0, "Min amount must be greater than zero");
        require(_feePercentage <= 100, "Fee percentage cannot exceed 100");

        owner = _owner;
        issueLink = _issueLink;
        maxAmount = _maxAmount;
        unlockTime = _unlockTime;
        minAmount = _minAmount;
        feePercentage = _feePercentage;
        factoryOwner = _factoryOwner;
    }

    function contribute() external payable {
        require(block.timestamp < unlockTime, "Funding period has ended");
        require(msg.value >= minAmount, "Contribution below minimum amount");

        uint contribution = msg.value;
        uint total = totalFunds + contribution;

        if (total > maxAmount) {
            uint refundAmount = total - maxAmount;

            // Refund excess amount
            (bool success, ) = msg.sender.call{value: refundAmount}("");
            require(success, "Refund failed");

            contribution -= refundAmount;
        }

        contributors[msg.sender] += contribution;
        totalFunds += contribution;

        emit ContributionMade(owner, msg.sender, contribution, totalFunds);
    }

    function withdraw() external onlyOwner nonReentrant {
        require(totalFunds > 0, "No funds to withdraw");
        require(
            totalFunds >= maxAmount || block.timestamp >= unlockTime,
            "Target amount not reached, and unlock time has not passed"
        );
        
        uint fee = (totalFunds * feePercentage) / 100; // Calculate the fee
        uint amountToSend = totalFunds - fee;

        totalFunds = 0; 

        (bool successOwner, ) = owner.call{value: amountToSend}("");
        require(successOwner, "Owner transfer failed");

        (bool successFee, ) = factoryOwner.call{value: fee, gas: 4000}("");
        require(successFee, "Fee transfer failed");

        emit FundsWithdrawn(owner, amountToSend);
        emit FeeTransferred(factoryOwner, fee);

    }

}