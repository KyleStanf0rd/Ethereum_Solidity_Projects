//SPDX-License-Identifier: GPL-3.0
 
pragma solidity >=0.5.0 <0.9.0;

contract A {
    string[] public cities = ['Prague', 'Bucharest'];

//VIEW MODE BECAUSE FUNCTION DOES NOT CHANGE THE BLOCKCHAIN
    function f_memory() public view{
        string[] memory s1 = cities;
        // string s2; --> error 
        s1[0] = 'Berlin';
    }

    function f_storage() public{
        string[] storage s1 = cities;
        // string s2; --> error 
        s1[0] = 'Berlin';
    }

    //DEPLOY AND CALL FUNCTIONS TO SEE DIFFERENCE IN FUNCTION STORAGE AND MEMORY




}