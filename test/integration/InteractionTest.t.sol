//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";


contract InteractionTest is Test {

    FundMe fundMe;
    uint256 constant s_SENT_AMOUNT = 0.1 ether;
    address USER = makeAddr("david");
    uint256 constant s_GAS_PRICE = 1;
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp () external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testUserCanFundInteractions() external {
      //  vm.prank(USER);
        vm.deal(USER, 1e18);

        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));
        
        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

      //_bound  address funder = fundMe.getFunder(0);
        assert(address(fundMe).balance == 0);
    }
}