// pragma solidity ^0.8.8;
// import {Test, console} from "../lib/forge-std/src/Test.sol";
// import {FundMe} from "../src/FundMe.sol";
// import {DeployFundMe} from "../script/DeployFundMe.s.sol";

// contract FundMeTest is Test {
//     FundMe fundMe;

//     function setUp() external {
//         // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
//         DeployFundMe deployFundMe = new DeployFundMe();
//         fundMe = deployFundMe.run();

//     }

//     // Unit Tests Of (FundMe.sol)
//     function testMinimumUsd() public view {
//         assertEq(fundMe.minimumUSD(), 5e18);
//     }

//     function testOwnerSetCorrect() public view {
//         assertEq(fundMe.owner(), msg.sender);
//     }
// }

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;
import {Test, console} from "../lib/forge-std/src/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address user = address(0x1234);
    address anotherUser = address(0x5678);
    address owner;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        owner = fundMe.owner();
    }

    // Unit Tests Of (FundMe.sol)
    function testMinimumUsd() public view {
        assertEq(fundMe.minimumUSD(), 5e18);
    }

    function testOwnerSetCorrect() public view {
        assertEq(fundMe.owner(), owner);
    }

    // function testFund() public {
    //     // Start as a different user
    //     vm.startPrank(user);
    //     // Send ETH to the contract
    //     vm.deal(user, 10 ether);
    //     // Attempt to fund with insufficient ETH
    //     vm.expectRevert("Send minimum 1 ETH");
    //     fundMe.find{value: 0.1 ether}();
    //     // Fund with sufficient ETH
    //     fundMe.find{value: 1 ether}();
    //     // Check if the user is recorded as a funder
    //     assertEq(fundMe.addressToAmountFunded(user), 1 ether);
    //     vm.stopPrank();
    // }

    function testWithdraw() public {
        // Fund the contract from a user account
        vm.startPrank(user);
        vm.deal(user, 10 ether);
        fundMe.find{value: 1 ether}();
        vm.stopPrank();
        
        // Withdraw from the contract as the owner
        vm.startPrank(owner);
        uint256 initialBalance = owner.balance;
        fundMe.withdraw();
        uint256 finalBalance = owner.balance;

        assertEq(finalBalance, initialBalance + 1 ether);
        assertEq(fundMe.getBalance(), 0);
        vm.stopPrank();
    }

    function testOnlyOwnerCanWithdraw() public {
        // Fund the contract from a user account
        vm.startPrank(user);
        vm.deal(user, 10 ether);
        fundMe.find{value: 1 ether}();
        vm.stopPrank();

        // Attempt to withdraw as a different user
        vm.startPrank(anotherUser);
        vm.expectRevert("Sender is not owner");
        fundMe.withdraw();
        vm.stopPrank();
    }

    function testGetBalance() public {
        // Fund the contract from a user account
        vm.startPrank(user);
        vm.deal(user, 10 ether);
        fundMe.find{value: 1 ether}();
        vm.stopPrank();

        assertEq(fundMe.getBalance(), 1 ether);
    }

    function testLastWithdrawalTimeUpdates() public {
        // Fund the contract from a user account
        vm.startPrank(user);
        vm.deal(user, 10 ether);
        fundMe.find{value: 1 ether}();
        vm.stopPrank();

        // Withdraw from the contract as the owner
        vm.startPrank(owner);
        fundMe.withdraw();
        assertEq(fundMe.lastWithdrawalTime(), block.timestamp);
        vm.stopPrank();
    }

    function testMultipleFunders() public {
        // Fund the contract from user account
        vm.startPrank(user);
        vm.deal(user, 10 ether);
        fundMe.find{value: 1 ether}();
        vm.stopPrank();

        // Fund the contract from another user account
        vm.startPrank(anotherUser);
        vm.deal(anotherUser, 10 ether);
        fundMe.find{value: 2 ether}();
        vm.stopPrank();

        // Check balances and funders
        assertEq(fundMe.addressToAmountFunded(user), 1 ether);
        assertEq(fundMe.addressToAmountFunded(anotherUser), 2 ether);
        assertEq(fundMe.getBalance(), 3 ether);
    }

    function testWithdrawAfterMultipleFunders() public {
        // Fund the contract from user account
        vm.startPrank(user);
        vm.deal(user, 10 ether);
        fundMe.find{value: 1 ether}();
        vm.stopPrank();

        // Fund the contract from another user account
        vm.startPrank(anotherUser);
        vm.deal(anotherUser, 10 ether);
        fundMe.find{value: 2 ether}();
        vm.stopPrank();

        // Withdraw from the contract as the owner
        vm.startPrank(owner);
        uint256 initialBalance = owner.balance;
        fundMe.withdraw();
        uint256 finalBalance = owner.balance;

        assertEq(finalBalance, initialBalance + 3 ether);
        assertEq(fundMe.getBalance(), 0);
        vm.stopPrank();
    }

   
}

