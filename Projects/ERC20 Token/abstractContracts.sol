//SPDX-License-Identifier: GPL-3.0

//Contract goes over inheritance and interfaces
 
pragma solidity >=0.5.0 <0.9.0;

//abstract contract cannot be deployed on blockchain, can only be used from derivations from other contracts

interface Abstract{
    // int public x;
    // address public owner;

    // constructor(){
    //     x = 5;
    //     owner = msg.sender;

    // }

    function setX(int _x) external;
}


contract A is Abstract{
    int public x;
    int public y = 3;

    //must include override since we are changing the original function from parent contract
    function setX(int _x) public override{
        x = _x;
    }

}