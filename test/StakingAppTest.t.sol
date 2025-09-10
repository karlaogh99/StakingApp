// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;
import "forge-std/Test.sol";
import "../src/StakingToken.sol";
import "../src/StakingApp.sol";

contract StakingAppTest is Test{
    StakingToken stakingToken;
    StakingApp stakingApp;

    string name_= "Staking Token";
    string symbol_ = "STK";

    address owner_ = vm.addr(1);
    uint256 stakingPeriod_ = 10000000000;
    uint256 fixedStakingAmount_ = 10;
    uint256 rewardPerPeriod_ = 1 ether;
    function setUp() external{
        stakingToken = new StakingToken(name_, symbol_);
        stakingApp = new StakingApp(address(stakingToken), owner_, stakingPeriod_, fixedStakingAmount_, rewardPerPeriod_ );

    }
    function testStakingTokenCorrectCorrectlyDeployed() external view{
        assert (address(stakingToken) != address(0));
    }
    function testStakingAppCorrectCorrectlyDeployed() external view{
        assert (address(stakingApp) != address(0));
    }
    

}