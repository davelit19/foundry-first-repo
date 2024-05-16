//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

//import "forge-std/console.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    uint256 constant s_SENT_AMOUNT = 0.1 ether;
    address USER = makeAddr("david");
    uint256 constant s_GAS_PRICE = 1;
    

    function setUp() external {
        //  fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();

    }

    function testIsMinimumDollar() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testIsOwner() public view {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        console.log(version);
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughEth() public {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.fund{value: s_SENT_AMOUNT}();
    }

    function testFundUpdatesToFundedDataStructure() public funded {
        
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, s_SENT_AMOUNT);
    }

    function testAddsFundersToArrayOfFunders() public funded {
        address funder = fundMe.getFunder(0);
        assertEq(USER, funder);
    }

    modifier funded() {
        vm.prank(USER);
        deal(USER, 20 ether);
        fundMe.fund{value: s_SENT_AMOUNT}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        //Arrange

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        console.log("startingOwnerBalance:", startingOwnerBalance);
        console.log("startingFundMeBalance:", startingFundMeBalance);

        //Act

        vm.txGasPrice(s_GAS_PRICE);
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

    

        //assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingfundMeBalance = address(fundMe).balance;
        console.log("endingfundMeBalance:", endingfundMeBalance);
        console.log("endingOwnerBalance:", endingOwnerBalance);

        assertEq(endingfundMeBalance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance);
    }

    function testWithdrawFromMultipleFunders() public funded {
        //Arrange
        uint160 numberOfFunders = 10;
        uint160 startingIndex = 1;

        for (uint160 i = startingIndex; i <= numberOfFunders; i++) {
            hoax(address(i), s_SENT_AMOUNT);
            fundMe.fund{value: s_SENT_AMOUNT}();
            console.log(address(i));
        }

        //Act
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
       // console.log("startingOwnerBalance:", startingOwnerBalance);
       // console.log("startingFundMeBalance:", startingFundMeBalance);

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        //Assert

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
       // console.log("endingOwnerBalance:", endingOwnerBalance);

        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == endingOwnerBalance);
    }

     function testWithdrawFromMultipleFundersCheaper() public funded {
        //Arrange
        uint160 numberOfFunders = 10;
        uint160 startingIndex = 1;

        for (uint160 i = startingIndex; i <= numberOfFunders; i++) {
            hoax(address(i), s_SENT_AMOUNT);
            fundMe.fund{value: s_SENT_AMOUNT}();
            console.log(address(i));
        }

        //Act
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
       // console.log("startingOwnerBalance:", startingOwnerBalance);
       // console.log("startingFundMeBalance:", startingFundMeBalance);

        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        //Assert

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
       // console.log("endingOwnerBalance:", endingOwnerBalance);

        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == endingOwnerBalance);
    }
}
