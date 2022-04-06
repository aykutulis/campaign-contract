//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Campaign {
    struct Request {
        string description;
        uint value;
        address payable recipient;
        bool complete;
        uint approvalCount;
        mapping(address => bool) approvals;
    }

    mapping(uint => Request) public requests;
    uint private requestsLength;
    address public manager;
    uint public minimumContribution;
    mapping(address => bool) public approvers;
    uint public approversCount;

    constructor(uint minimum, address creator) {
        manager = creator;
        minimumContribution = minimum;
    }

    modifier restricted() {
        require(msg.sender == manager, "Only the manager allowed");
        _;
    }

    function contribute() public payable {
        require(msg.value >= minimumContribution, "Minimum contribution not met");
        approvers[msg.sender] = true;
    }

    function createRequest(string memory description, uint value, address payable recipient) public restricted {
        Request storage newRequest = requests[requestsLength];
        newRequest.description = description;
        newRequest.value = value;
        newRequest.recipient = recipient;
        newRequest.complete = false;
        newRequest.approvalCount = 0;
        requestsLength++;
        approversCount++;
    }

    function approveRequest(uint reqIndex) public {
        Request storage request = requests[reqIndex];

        require(approvers[msg.sender], "Approver not registered");
        require(!request.approvals[msg.sender], "Already approved");

        request.approvals[msg.sender] = true;
        request.approvalCount++;
    }

    function finalizeRequest(uint reqIndex) public restricted {
        Request storage request = requests[reqIndex];
        require(request.approvalCount > (approversCount / 2), "Not enough approvals");

        require(!request.complete, "Request already finalized");

        request.recipient.transfer(request.value);
        request.complete = true;
    }
}
