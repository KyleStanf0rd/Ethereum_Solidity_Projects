//SPDX-License-Identifier: GPL-3.0
 
pragma solidity >=0.5.0 <0.9.0;

contract AuctionCreator{
    Auction[] public auctions;

    function createAuction() public {
        Auction newAuction = new Auction(msg.sender);
        auctions.push(newAuction);
    }
}

contract Auction{
    address payable public owner;
    uint public startBlock;
    uint public endBlock;
    string public ipfsHash;

    enum State {Started, Running, Ended, Canceled}
    State public auctionState;

    uint public highestBindingBid;
    address payable public highestBidder;

    //keys are the addresses of the bidders and values are amount sent
    mapping(address => uint) public bids;
    uint bidIncrement;

    constructor(address eoa){ //externally owned account --> call this contract in another contract and edit the address in which created
        owner = payable(eoa);
        auctionState = State.Running;
        //initialize auction start and ending date
        startBlock = block.number;
        //want it to end after 3 transactions
        endBlock = startBlock + 3;
        // block will be running for a week, so auction is up for a week
        ipfsHash = "";
        bidIncrement = 1000000000000000000;  //in wei
    }

    modifier notOwner(){
        require(msg.sender != owner);
        _;
    }

    modifier afterStart(){
        require(block.number >= startBlock);
        _;
    }

    modifier beforeEnd(){
        require(block.number <= endBlock);
        _;
    }

    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }


    function cancelAuction() public onlyOwner{
        auctionState = State.Canceled;

    }

    function min(uint a, uint b) pure internal returns(uint){
        if(a <= b){
            return a;
        }else{
            return b;
        }
    }

    //Main logic for the auction
    function placeBid() public payable notOwner afterStart beforeEnd{
        require(auctionState == State.Running);
        require(msg.value >= 100);

        uint currentBid = bids[msg.sender] + msg.value;
        require(currentBid > highestBindingBid);

        bids[msg.sender] = currentBid;

        if(currentBid <= bids[highestBidder]){
            highestBindingBid = min(currentBid + bidIncrement, bids[highestBidder]);
        }else{
            highestBindingBid = min(currentBid, bids[highestBidder]+ bidIncrement);
            highestBidder = payable(msg.sender);
        }
    }

    //Checks to see if auction was canceled, allows users to get their money back as well as if the auction ended, if that is the case
    // then the auction gives the highest bidder the prize
    function finalizeAuctions() public {
        require(auctionState == State.Canceled || block.number > endBlock); //second argument checks if auction ended (exceeded specified time of open)
        require(msg.sender == owner || bids[msg.sender] > 0); //second argument means that the msg.sender must be a bidder so either woner or bidder can finalize auction


        address payable recipient;
        uint value;

        if(auctionState == State.Canceled){ //auction canceled
            recipient = payable(msg.sender);
            value = bids[msg.sender];
        }else{ //auction ended, not canceled
            if(msg.sender == owner){ //this is the owner
                recipient = owner;
                value = highestBindingBid;
            }else{ //this is a bidder
                if(msg.sender == highestBidder){
                    recipient = highestBidder;
                    value = bids[highestBidder] - highestBindingBid;
                }else{ //this is neither the owner or the highest bidder
                    recipient = payable(msg.sender);
                    value = bids[msg.sender];
                }
            }
        }

        //resetting the bids of the recipient to zero
        //makes it to where user can only call this function once
        bids[recipient] = 0;


        //send amount to the recipient
        recipient.transfer(value);

    }
}