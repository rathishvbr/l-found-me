//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    function setUp() external {
        // Should send correct args
        fundMe = new FundMe(address(this));
    }

    function testMiniumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public view {
        console.log("Owner address:", fundMe.getOwner());
        console.log("Sender address:", address(this));
        assertEq(fundMe.getOwner(), address(this));
    }
}
