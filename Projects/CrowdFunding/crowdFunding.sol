//SPDX-License-Identifier: GPL-3.0
 
pragma solidity >=0.5.0 <0.9.0;

contract crowdFunding{
    //each address holds an amount they sent to contract
    mapping(address => uint) public contributors;
    address public admin;
    uint public numOfContributors;
    uint public minimumContribution;
    uint public deadline; //timestamp
    uint public goal;
    uint public raisedAmount;
    struct Request{
        string description;
        address payable recipient;
        uint value;
        bool completed;
        uint numOfVoters;
        // deafault for bool is false
        mapping(address => bool) voters;
    }

    mapping(uint => Request) public requests;
    uint public numRequests;


    constructor(uint _goal, uint _deadline){
        goal = _goal;
        deadline = block.timestamp + _deadline;
        minimumContribution = 100 wei;
        admin = msg.sender;
    }

    event ContributeEvent(address _sender, uint _value);
    event CreateRequestEvent(string _description, address _recipient, uint _value);
    event MakePaymentEvent(address _recipient, uint _value);


    function contribute() public payable{
        require(block.timestamp < deadline, "Deadline has passed.");
        require(msg.value >= minimumContribution, "Minimum Contribution not met.");


        //checks if this is the first time the user sent money to the contract
        if(contributors[msg.sender] == 0){
            numOfContributors++;
        }

        contributors[msg.sender] += msg.value;
        raisedAmount += msg.value;

        emit ContributeEvent(msg.sender, msg.value);
    }

    receive() payable external{
        contribute();
    }

    function getBalance() public view returns(uint){
        return address(this).balance;
    }

    function getRefund() public{
        //exceeded deadline to raise money and did not reach goal
        require(block.timestamp > deadline && raisedAmount < goal);
        require(contributors[msg.sender] > 0);

        //setting recipient to contract creators address
        address payable recipient = payable(msg.sender);
        //getting contributedAmount from contributors mapping
        uint value = contributors[msg.sender];
        recipient.transfer(value);

        // payable(msg.sender).transfer(contributors[msg.sender]);

        // restting this users contributed amount to 0 so they cannot take advantage of the possible security vunlernability
        contributors[msg.sender] = 0;
    }

    modifier onlyAdmin(){
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    function createRequest(string memory _description, address payable _recipient, uint _value) public onlyAdmin{
        Request storage newRequest = requests[numRequests];
        numRequests++;

        newRequest.description = _description;
        newRequest.recipient = _recipient;
        newRequest.value = _value;
        newRequest.completed = false;
        newRequest.numOfVoters = 0;

        emit CreateRequestEvent(_description, _recipient, _value);
    }

    function voteRequest(uint _requestNum) public{
        require(contributors[msg.sender] > 0, "You must be a contributor to vote!");
        //saved in storage because I worked directly on it and not a copy
        Request storage thisRequest = requests[_requestNum];

        require(thisRequest.voters[msg.sender] == false, "You have already voted!");
        //means user has already voted
        thisRequest.voters[msg.sender] = true;
        thisRequest.numOfVoters++;
    }

    function makePayment(uint _requestNum) public onlyAdmin{
        require(raisedAmount >= goal);
        Request storage thisRequest = requests[_requestNum];
        require(thisRequest.completed == false, "The request has been completed");
        require(thisRequest.numOfVoters > numOfContributors / 2); //if 50% voted for this request then it passes the check

        thisRequest.recipient.transfer(thisRequest.value);
        thisRequest.completed = true;

        emit MakePaymentEvent(thisRequest.recipient, thisRequest.t)
    }



}