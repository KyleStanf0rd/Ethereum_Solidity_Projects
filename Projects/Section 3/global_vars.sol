//SPDX-License-Identifier: GPL-3.0
 
pragma solidity >=0.5.0 <0.9.0;

contract GlobalVariables{
    address public owner;
    uint public sentValue;

    //EXTRA GLOBAL VARIABLES
    uint public this_moment = block.timestamp;
    uint public block_nnumber = block.number;
    uint public difficulty = block.difficulty;
    uint public gaslimit = block.gaslimit;

    constructor(){
        owner=msg.sender;
    }

    //If you switch accounts it will change the owner when function is called
    function changeOwner() public {
        owner = msg.sender;
    }

    function sendEther() public payable {
        sentValue = msg.value;
    }

    function getBalance() public view returns(uint){
        return address(this).balance;
    }

    function howMuchGas() public view returns(uint){
        //gasleft is a in house variable
        uint start = gasleft();
        uint j = 1;
        //For loops are expensive
        for(uint i = 1; i < 20; i++){
            j *= i;
        }

        uint end = gasleft();

        return start - end;
    }


}

