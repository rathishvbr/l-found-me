//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_LIMIT = 3000000;
    
    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMiniumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public view {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public view {
        // This will fail on mainnet, because on mainnet the version is 6
        assertEq(fundMe.getVersion(), 4);
    }

    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundUpdatesFundedDataStructure() public doFund{
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public doFund {
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    function testOnlyOwnerCanWithdraw() public doFund {

        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public doFund {
        //Arrange
        uint256 startingContractBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = address(fundMe.getOwner()).balance;

        //Act
        uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_LIMIT);
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log("gasUsed", gasUsed);

        //Assert
        assertEq(address(fundMe).balance, 0);
        assertEq(address(fundMe.getOwner()).balance, startingOwnerBalance + startingContractBalance);
    }

    function testWithdrawFromMultipleFunders() public doFund {
        //Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            //vm.prank(USER);
            //fundMe.fund{value: SEND_VALUE}();
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();

        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        //Assert
        assertEq(address(fundMe).balance, 0);
        assertEq(address(fundMe.getOwner()).balance, startingOwnerBalance + startingFundMeBalance);
    }

    function testWithdrawFromMultipleFundersCheaper() public doFund {
        //Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            //vm.prank(USER);
            //fundMe.fund{value: SEND_VALUE}();
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();

        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //Act
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        //Assert
        assertEq(address(fundMe).balance, 0);
        assertEq(address(fundMe.getOwner()).balance, startingOwnerBalance + startingFundMeBalance);
    }
    

    //Modifier
    modifier doFund {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }
}
