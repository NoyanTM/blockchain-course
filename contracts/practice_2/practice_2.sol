// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

contract DataTypes {
    // bool public myBool = true; // state

    // function myFunc(bool _inputBool) public {
    //     bool localBool = false; // local
    // }

    uint public myUnit = 42;
    // function demo(uint _inputUint) public {
    //     uint localUint = 42;
    // }
    uint8 public mySmallUint = 2;
    // 2 ** 8 = 256
    // 0 --> (256 - 1)

    int public myInt = -42;
    int8 public mySmallInt = -1;
    // 2 ** 7 = 128
    // -128  --> (128 - 1)

    uint public minimum;
    uint public maximum;
    function calculateMinimum() public {
        minimum = type(uint8).min; //0 
    }
    function calculateMaximum() public {
        maximum = type(uint8).max;
    }
}
