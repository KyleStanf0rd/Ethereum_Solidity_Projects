//SPDX-License-Identifier: GPL-3.0
 
pragma solidity >=0.5.0 <0.9.0;

contract Lottery{
    address payable[] public players;
    address public manager;

    constructor(){
        //setting manager to contract deployed from address
        manager = msg.sender;
    }

    // receive ether
    receive() external payable{
        //person paying must ONLY send 0.1 ether no more no less
        require(msg.value == 0.1 ether, "DID NOT SEND CORRECT AMOUNT");
        players.push(payable(msg.sender));
    }

    function getBalance() public view returns(uint){
        require(msg.sender == manager);
        return address(this).balance;
    }

    function random() public view returns(uint){
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players.length)));
    }

    function pickWinner() public{
        require(msg.sender == manager);
        require(players.length >= 3);

        uint randomNum = random();
        address payable winner;

        uint index = randomNum % players.length;
        winner = players[index];

        //transferring eth to winners address
        winner.transfer(getBalance());

        // resetting players array back to 0
        players = new address payable[](0);

    }









}