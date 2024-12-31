// SPDX-License-Identifier: MIT

pragma solidity ^0.8.27;

import "./Funding.sol";

contract CreateFunding {
    address deployer;

    event CreateFundingEvent(
        address indexed creator, 
        string issueLink, 
        uint maxAmount, 
        uint unlockTime, 
        uint minAmount,
        uint feePercentage,
        address newFundingAddress
        );

    constructor() {
        deployer = msg.sender;
    }

    function createNewFunding(
        string calldata _issueLink, 
        uint _maxAmount, 
        uint _unlockTime, 
        uint _minAmount,
        uint _feePercentage
    ) public {
        require(bytes(_issueLink).length != 0, "link cannot be empty");
        require(_maxAmount > 0, "enter an amount greater than 0");
        require(_unlockTime > 0, "enter an unlockTime greater than 0");
        require(block.timestamp < _unlockTime, "Unlock time should be in the future");
        require(_minAmount > 0, "Minimum amount must be greater than 0");
        require(_feePercentage >= 0 && _feePercentage <= 100, "Invalid fee percentage");

        Funding funding = new Funding(
            msg.sender,
            _issueLink, 
            _maxAmount, 
            _unlockTime,
            _minAmount, 
            _feePercentage, 
            deployer
        );

        emit CreateFundingEvent(
            msg.sender, 
            _issueLink, 
            _maxAmount, 
            _unlockTime, 
            _minAmount, 
            _feePercentage,
            address(funding)
        );
    }
}
