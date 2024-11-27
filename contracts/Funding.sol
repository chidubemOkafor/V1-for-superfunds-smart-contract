// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

contract Funding {
    address owner;
    uint private target;
    uint private unlockTime;
    uint private minimumAmount;
    string private name;
    uint private totalFunds;

    enum Status {
        ongoing,
        ended
    }

    Status status;

    mapping(address => uint) public contributors;
    address[] public contributorAddresses;

    event ContributionMade(address indexed senderAddress, uint amount);
    event SeedSent(address indexed Founder, uint amount);
    event SeedReversed(address indexed InitialSender, uint amount);
    event TargetNotMet();
    event TargetMet();

    // Constructor does not need the _owner argument
    constructor(address _owner, string memory _name, uint _target, uint _unlockTime, uint _minimumAmount) {
        name = _name;
        target = _target;
        unlockTime = _unlockTime;
        minimumAmount = _minimumAmount;
        owner = _owner;
        status = Status.ongoing;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    function contribute() external payable {
        require(block.timestamp < unlockTime, "You can no longer contribute");
        require(msg.value >= minimumAmount, "Not up to minimum amount");

        totalFunds += msg.value;

        if (contributors[msg.sender] == 0) {
            contributorAddresses.push(msg.sender);
        }

        contributors[msg.sender] += msg.value;

        emit ContributionMade(msg.sender, msg.value);
    }

    function fundOrReject() public onlyOwner {
        require(block.timestamp >= unlockTime, "Funding period has not ended yet");
        require(status == Status.ongoing, "this campaign has already ended");
        
        status = Status.ended;

        if (totalFunds >= target) {
            (bool success, ) = owner.call{value: totalFunds}("");
            require(success, "Transfer failed");
            emit SeedSent(owner, totalFunds);
            emit TargetMet();
            delete contributorAddresses;
        } else {
            sendFundsBack();
        }
    }

    function sendFundsBack() private onlyOwner {
        for (uint i = 0; i < contributorAddresses.length; i++) {
            address contributor = contributorAddresses[i];
            uint amount = contributors[contributor];

            contributors[contributor] = 0;

            (bool success, ) = contributor.call{value: amount}("");
            require(success, "Transfer failed");
            emit SeedReversed(contributor, amount);
        }
        emit TargetNotMet();
    }

    // Getter functions
    function getName() public view returns (string memory) {
        return name;
    }

    function getUnlockTime() public view returns (uint) {
        return unlockTime;
    }

    function getMinimumAmount() public view returns (uint) {
        return minimumAmount;
    }

    function getTotalFunds() public view returns (uint) {
        return totalFunds;
    }

    function getTarget() public view returns (uint) {
        return target;
    }

    function getStatus() public view returns (Status) {
        return status;
    }
}
