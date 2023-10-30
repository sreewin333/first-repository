// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {FundMe} from "../../src/FundMe.sol";
import {Test, console} from "forge-std/Test.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant sendvalue = 0.1 ether;
    uint256 constant startingbalance = 10 ether;
    uint256 constant gas_price = 1;

    function setUp() external {
        //fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployfundme = new DeployFundMe();
        fundMe = deployfundme.run();
        vm.deal(USER, startingbalance);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: sendvalue}();
        _;
    }

    function testminimumusdis5() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testowner() public {
        assertEq(fundMe.getowner(), msg.sender);
    }

    function testgetversion() public {
        assertEq(fundMe.getVersion(), 4);
    }

    function testfundfailswithoutenougheth() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testfundupdetesfundeddatastructures() public funded {
        uint256 amountfunded = fundMe.getadresstoamountfunded(USER);
        assertEq(amountfunded, sendvalue);
    }

    function testaddsfundertoarrayoffunders() public funded {
        address funder = fundMe.getfunder(0);
        assertEq(funder, USER);
    }

    function testonlyownercanwithdraw() public funded {
        vm.expectRevert();
        fundMe.cheaperwithdraw();
    }

    function testwithdrawwithasinglefunder() public funded {
        //arrange
        uint256 startingownerbalance = fundMe.getowner().balance;
        uint256 startingfundmebalance = address(fundMe).balance;

        //act
        vm.txGasPrice(gas_price);
        vm.prank(fundMe.getowner());
        fundMe.cheaperwithdraw();

        //assert
        uint256 endingownerbalance = fundMe.getowner().balance;
        uint256 endingfundmebalance = address(fundMe).balance;
        assertEq(endingfundmebalance, 0);
        assertEq(
            startingfundmebalance + startingownerbalance,
            endingownerbalance
        );
    }

    function testwithdrawfrommultiplefunders() public funded {
        //arrange

        uint160 numberoffunders = 10;
        uint160 startingfunderindex = 1;
        for (uint160 i = startingfunderindex; i < numberoffunders; i++) {
            hoax(address(i), sendvalue);
            fundMe.fund{value: sendvalue}();
        }

        uint256 startingownerbalance = fundMe.getowner().balance;
        uint256 startingfundmebalance = address(fundMe).balance;

        //act
        vm.startPrank(fundMe.getowner());
        fundMe.cheaperwithdraw();
        vm.stopPrank();

        //assert
        assertEq(address(fundMe).balance, 0);
        assert(
            startingfundmebalance + startingownerbalance ==
                fundMe.getowner().balance
        );
    }
}
