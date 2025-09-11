// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "forge-std/Test.sol";
import "../src/StakingToken.sol";
import "../src/StakingApp.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract StakingAppTest is Test {
    StakingToken stakingToken;
    StakingApp stakingApp;

    string name_ = "Staking Token";
    string symbol_ = "STK";

    address owner_ = vm.addr(1);
    uint256 stakingPeriod_ = 10000000000;
    uint256 fixedStakingAmount_ = 10;
    uint256 rewardPerPeriod_ = 1 ether;

    address randomUser = vm.addr(2);

    function setUp() external {
        stakingToken = new StakingToken(name_, symbol_);
        stakingApp =
            new StakingApp(address(stakingToken), owner_, stakingPeriod_, fixedStakingAmount_, rewardPerPeriod_);
    }

    function testStakingTokenCorrectCorrectlyDeployed() external view {
        assert(address(stakingToken) != address(0));
    }

    function testStakingAppCorrectCorrectlyDeployed() external view {
        assert(address(stakingApp) != address(0));
    }

    function testShouldRevertIfNotOwner() external {
        uint256 NewStakingPeriod = 3;
        vm.expectRevert();
        stakingApp.channgeStakingPeriod(NewStakingPeriod);
    }

    function testShouldChangeStakingPeriod() external {
        vm.startPrank(owner_);
        uint256 newStakingPeriod = 3;
        uint256 stakingPeriodBefore = stakingApp.stakingPeriod();
        stakingApp.channgeStakingPeriod(newStakingPeriod);
        uint256 stakingPeriodAfter = stakingApp.stakingPeriod();

        assert(stakingPeriodAfter != stakingPeriodBefore);
        assert(newStakingPeriod == stakingPeriodAfter);

        vm.stopPrank();
    }

    function testContractRecievesEtherCorrectly() external {
        vm.startPrank(owner_);
        vm.deal(owner_, 1 ether);

        uint256 etherValue = 1 ether;

        uint256 balanceBefore = address(stakingApp).balance;
        (bool success,) = address(stakingApp).call{value: etherValue}("");
        uint256 balanceAfter = address(stakingApp).balance;

        require(success, "Trasnfer failed");
        assert(balanceAfter - balanceBefore == etherValue);

        vm.stopPrank();
    }

    function testIncorrectlyAmountShouldRevert() external {
        vm.startPrank(randomUser);

        uint256 depositAmount = 1;
        vm.expectRevert("Incorrect amount");
        stakingApp.depositTokenks(depositAmount);

        vm.stopPrank();
    }

    function testDepositTokenCorrectly() external {
        vm.startPrank(randomUser);
        uint256 tokenAmount = stakingApp.fixedStakingAmout();
        stakingToken.mint(tokenAmount);

        uint256 userBalanceBefore = stakingApp.userBalance(randomUser);
        uint256 elapsePeriodBefore = stakingApp.elapsePeriod(randomUser);
        ERC20(stakingToken).approve(address(stakingApp), tokenAmount);
        stakingApp.depositTokenks(tokenAmount);
        uint256 userBalanceAfter = stakingApp.userBalance(randomUser);
        uint256 elapsePeriodAfter = stakingApp.elapsePeriod(randomUser);

        assert(userBalanceAfter - userBalanceBefore == tokenAmount);
        assert(elapsePeriodBefore == 0);
        assert(elapsePeriodAfter == block.timestamp);

        vm.stopPrank();
    }

    function testUserCanNotDepositMoreThanOnce() external {
        vm.startPrank(randomUser);
        uint256 tokenAmount = stakingApp.fixedStakingAmout();
        stakingToken.mint(tokenAmount);

        ERC20(stakingToken).approve(address(stakingApp), tokenAmount);
        stakingApp.depositTokenks(tokenAmount);

        stakingToken.mint(tokenAmount);
        ERC20(stakingToken).approve(address(stakingApp), tokenAmount);
        vm.expectRevert("User already deposited");
        stakingApp.depositTokenks(tokenAmount);

        vm.stopPrank();
    }

    function testCanOnlyWithdraw0() external {
        vm.startPrank(randomUser);
        uint256 userBalanceBefore = stakingApp.userBalance(randomUser);
        stakingApp.withdrawTokens();
        uint256 userBalanceAfter = stakingApp.userBalance(randomUser);
        assert(userBalanceBefore == userBalanceAfter);

        vm.stopPrank();
    }

    function testWithdrawTokenOK() external {
        vm.startPrank(randomUser);
        uint256 tokenAmount = stakingApp.fixedStakingAmout();
        stakingToken.mint(tokenAmount);
        uint256 userBalanceBefore = stakingApp.userBalance(randomUser);
        uint256 elapsePeriodBefore = stakingApp.elapsePeriod(randomUser);
        ERC20(stakingToken).approve(address(stakingApp), tokenAmount);
        stakingApp.depositTokenks(tokenAmount);
        uint256 userBalanceAfter = stakingApp.userBalance(randomUser);
        uint256 elapsePeriodAfter = stakingApp.elapsePeriod(randomUser);
        assert(userBalanceAfter - userBalanceBefore == tokenAmount);
        assert(elapsePeriodBefore == 0);
        assert(elapsePeriodAfter == block.timestamp);

        uint256 userBalanceBeforeWithdraw = IERC20(stakingToken).balanceOf(randomUser);
        uint256 userBalanceInMapping = stakingApp.userBalance(randomUser);
        stakingApp.withdrawTokens();
        uint256 userBalanceAfterWithdraw = IERC20(stakingToken).balanceOf(randomUser);
        assert(userBalanceAfterWithdraw == userBalanceBeforeWithdraw + userBalanceInMapping);

        vm.stopPrank();
    }

    function testCanNotClaimIfNotStaking() external {
        vm.startPrank(randomUser);
        vm.expectRevert("Not staking");
        stakingApp.claimRewards();
        vm.stopPrank();
    }

    function testCanNotClaimIfNotElapseTime() external {
        vm.startPrank(randomUser);
        uint256 tokenAmount = stakingApp.fixedStakingAmout();
        stakingToken.mint(tokenAmount);
        uint256 userBalanceBefore = stakingApp.userBalance(randomUser);
        uint256 elapsePeriodBefore = stakingApp.elapsePeriod(randomUser);
        ERC20(stakingToken).approve(address(stakingApp), tokenAmount);
        stakingApp.depositTokenks(tokenAmount);
        uint256 userBalanceAfter = stakingApp.userBalance(randomUser);
        uint256 elapsePeriodAfter = stakingApp.elapsePeriod(randomUser);
        assert(userBalanceAfter - userBalanceBefore == tokenAmount);
        assert(elapsePeriodBefore == 0);
        assert(elapsePeriodAfter == block.timestamp);

        vm.expectRevert("Need to wait");
        stakingApp.claimRewards();
        vm.stopPrank();
    }

    function testShouldRevertIfNotEther() external {
        vm.startPrank(randomUser);
        uint256 tokenAmount = stakingApp.fixedStakingAmout();
        stakingToken.mint(tokenAmount);
        uint256 userBalanceBefore = stakingApp.userBalance(randomUser);
        uint256 elapsePeriodBefore = stakingApp.elapsePeriod(randomUser);
        ERC20(stakingToken).approve(address(stakingApp), tokenAmount);
        stakingApp.depositTokenks(tokenAmount);
        uint256 userBalanceAfter = stakingApp.userBalance(randomUser);
        uint256 elapsePeriodAfter = stakingApp.elapsePeriod(randomUser);
        assert(userBalanceAfter - userBalanceBefore == tokenAmount);
        assert(elapsePeriodBefore == 0);
        assert(elapsePeriodAfter == block.timestamp);

        vm.warp(block.timestamp + stakingPeriod_);
        vm.expectRevert("Transfer failed");
        stakingApp.claimRewards();
        vm.stopPrank();
    }

    function testCanClaimRewardsCorrectly() external {
        vm.startPrank(randomUser);
        uint256 tokenAmount = stakingApp.fixedStakingAmout();
        stakingToken.mint(tokenAmount);
        uint256 userBalanceBefore = stakingApp.userBalance(randomUser);
        uint256 elapsePeriodBefore = stakingApp.elapsePeriod(randomUser);
        ERC20(stakingToken).approve(address(stakingApp), tokenAmount);
        stakingApp.depositTokenks(tokenAmount);
        uint256 userBalanceAfter = stakingApp.userBalance(randomUser);
        uint256 elapsePeriodAfter = stakingApp.elapsePeriod(randomUser);
        assert(userBalanceAfter - userBalanceBefore == tokenAmount);
        assert(elapsePeriodBefore == 0);
        assert(elapsePeriodAfter == block.timestamp);
        vm.stopPrank();

        vm.startPrank(owner_);
        uint256 etherAmount = 1000 ether;
        vm.deal(owner_, etherAmount);
        (bool success,) = address(stakingApp).call{value: etherAmount}("");
        require(success, "Test transfer failed");
        vm.stopPrank();

        vm.startPrank(randomUser);
        vm.warp(block.timestamp + stakingPeriod_);
        uint256 etherAmountBefore = address(randomUser).balance;
        stakingApp.claimRewards();
        uint256 etherAmountAfter = address(randomUser).balance;
        assert(etherAmountAfter - etherAmountBefore == rewardPerPeriod_);
        vm.stopPrank();
    }
}
