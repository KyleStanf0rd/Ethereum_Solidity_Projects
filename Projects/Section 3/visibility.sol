//SPDX-License-Identifier: GPL-3.0
 
pragma solidity >=0.5.0 <0.9.0;

contract Visibility{
    //4 TYPES
    /**
    Public -> can be called both internally and externally (getter method is automatically created for these visibility types)
    Private -> available only to the contracts they are defined in (subset of internal)
    Internal -> accessible only from the contract they are defined in and from derived contracts; default for state variables
    External -> can be accessed form other contracts or by EOA accounts using transactions (automatically public)
    **/
    int public x = 10;
    int y = 20;

    function get_y() public view returns(int){
        return y;
    }

    //Remix cannot call private functions, remember dummy
    function f1() private view returns(int){
        return x;
    }

    function f2() public view returns(int){
        int a;
        a = f1();
        return a;
    }

    function f3() internal view returns(int){
        return x;
    }

    function f4() external view returns(int){
        return x;
    }

    function f5() public pure returns(int){
        int b;
        // b = f4(); --> error since f4 is an external function
    }
}

contract B is Visibility{
    int public xx = f3();
    // int public yy = f1(); --> error since f1 is private and we are not in the same contract

}

contract C{
    Visibility public contract_a = new Visibility();
    int public xx = contract_a.f4();
    // int public y = contract_a.f1(); --> will not work since f1 is a private function
}