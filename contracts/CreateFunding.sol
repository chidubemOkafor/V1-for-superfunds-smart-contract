// SPDX-License-Identifier: MIT

pragma solidity ^0.8.27;

import "./Funding.sol";

contract CreateFunding {
    Funding[] public FundingArray;

    enum Status {
        ongoing,
        ended
    }

    Status status;

    event CreateFundingEvent(
        address indexed creator, 
        string fundingName, 
        uint target, 
        uint unlockTime, 
        uint minimumAmount,
        Status status
        );

    function createNewFunding(
        string calldata _name, 
        uint _target, 
        uint _unlockTime, 
        uint _minimumAmount
        ) public {
        require(bytes(_name).length != 0, "name cannot be empty");
        require(_target > 0, "enter an amount greater than 0");
        require(_unlockTime > 0, "enter an unlockTime greater than 0");
        require(block.timestamp < _unlockTime, "Unlock time should be in the future");

        Funding funding = new Funding(msg.sender, _name, _target, _unlockTime, _minimumAmount);
        FundingArray.push(funding);
        
        emit CreateFundingEvent(msg.sender, _name, _target, _unlockTime, _minimumAmount, Status.ongoing);
    }

    function getAllFundingCampaign() public view returns(Funding[] memory) {
       return FundingArray;
    }
}
