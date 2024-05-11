// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe public fundMe;
    DeployFundMe public deployFundMe;

    address private immutable i_pranker = makeAddr("sender");

    modifier funded() {
        vm.deal(i_pranker, 10 ether);
        vm.prank(i_pranker);
        _;
    }

    function setUp() external {
        deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
    }

    function testOwner() external view {
        console.log(fundMe.getOwner(), msg.sender);
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testMINIMUM_USD() external view {
        assertEq(fundMe.MINIMUM_USD(), 5 * 10 ** 18);
    }

    function testVersion() external view {
        assertEq(fundMe.getVersion(), 4);
    }

    function testFailSendSmallAmountETH() external {
        fundMe.fund();
    }

    function testStateVariablesAfterCallingFund() external payable funded {
        fundMe.fund{value: 1 ether}();
        uint amountFunded = fundMe.getAddressToAmountFunded(i_pranker);
        assertEq(amountFunded, 1 ether);
    }

    function testFundedArrayAfterCallingFund() external payable funded {
        fundMe.fund{value: 1 ether}();
        address funder = fundMe.getFunder(0);
        assertEq(funder, i_pranker);
    }

    function testOnlyOwnerCanWithdraw() external {
        vm.prank(i_pranker);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() external funded {
        // Arrange
        uint startingOwnerBalance = fundMe.getOwner().balance;
        uint startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // Assert
        assertEq(address(fundMe).balance, 0);
        assertEq(
            fundMe.getOwner().balance,
            startingOwnerBalance + startingFundMeBalance
        );
    }

    function testWithdrawFromMultipleFunders() external {
        uint8 numberOfFunders = 10;

        for (uint8 i = 1; i < numberOfFunders; ++i) {
            hoax(address(uint160(i)), 10 ether);
            fundMe.fund{value: 10 ether}();
        }

        address owner = fundMe.getOwner();
        address addrFundMe = address(fundMe);

        uint startingOwnerBalance = owner.balance;
        uint startingFundMeBalance = addrFundMe.balance;

        vm.startPrank(owner);
        fundMe.withdraw();
        vm.stopPrank();

        assertEq(addrFundMe.balance, 0);
        assertEq(owner.balance, startingOwnerBalance + startingFundMeBalance);
    }
}
