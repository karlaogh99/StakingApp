// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract StakingApp is Ownable{

    address public stakingToken;
    uint256 public stakingPeriod;
    uint256 public fixedStakingAmout;
    uint256 public rewardPerPeriod;
    mapping (address => uint256) public userBalance;
    mapping (address => uint256) public elapsePeriod;

    event ChangeStakePeriod(uint256 newStakingPeriod_);
    event DepositTokens(address userAddress_ ,uint256 depositAmout_);
    event WithdrawTokens(address userAddress_, uint256 withdrawAmount_ );
    event EtherSent(uint256 amount_);
    constructor(address stakingToken_, address owner_ , uint256 stakingPeriod_, uint256 fixedStakingAmout_, uint256 rewardPerPeriod_) Ownable(owner_) {
        stakingToken = stakingToken_;
        stakingPeriod= stakingPeriod_;
        fixedStakingAmout = fixedStakingAmout_;
        rewardPerPeriod = rewardPerPeriod_;
    }

    function depositTokenks(uint256 tokenAmountToDeposit_) external{
        require(tokenAmountToDeposit_ == fixedStakingAmout, "Incorrect amount");
        require(userBalance[msg.sender] == 0, "User already deposited");

        IERC20(stakingToken).transferFrom(msg.sender, address(this), tokenAmountToDeposit_);
        userBalance[msg.sender] += tokenAmountToDeposit_;
        elapsePeriod[msg.sender] = block.timestamp;
        emit DepositTokens(msg.sender, tokenAmountToDeposit_);
    }

    function withdrawTokens()  external {
        uint256 userBalance_ = userBalance[msg.sender];
        userBalance[msg.sender] = 0;
        IERC20(stakingToken).transfer(msg.sender, userBalance_);
        emit WithdrawTokens(msg.sender, userBalance_);
        
    }

    function claimRewards() external {
        require(userBalance[msg.sender] == fixedStakingAmout, "Not staking");
        uint256 elapsePeriod_ = block.timestamp - elapsePeriod[msg.sender];
        require(elapsePeriod_ >= stakingPeriod, "Need to wait");
        elapsePeriod[msg.sender] = block.timestamp;
        (bool success, ) = msg.sender.call{value: rewardPerPeriod}("");
        require(success, "Transfer failed");

    }


    receive() external payable onlyOwner{
        emit EtherSent(msg.value);
    }

    function channgeStakingPeriod(uint256 newStakingPeriod_) external onlyOwner{
        stakingPeriod = newStakingPeriod_;
        emit ChangeStakePeriod(newStakingPeriod_);
    }


}