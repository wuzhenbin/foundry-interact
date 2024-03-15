// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "forge-std/console.sol";

import "./interfaces/IWETH9.sol";
import "./interfaces/IUniswap.sol";
import "./interfaces/IERC20.sol";

import {HelperConfig} from "../script/MainnetConfig.s.sol";

contract ContractTest is Test {
    IERC20 WBTC;
    IERC20 DAI;
    WETH9 WETH;
    IUniswapV2Router UNISWAP_V2_ROUTER;

    function setUp() public {
        //fork mainnet at block 15327706
        vm.createSelectFork("mainnet", 15327706);

        HelperConfig helperConfig = new HelperConfig();
        (address wbtc, address dai, address weth, address uniswap_v2_router) = helperConfig.activeNetworkConfig();

        WBTC = IERC20(wbtc);
        DAI = IERC20(dai);
        WETH = WETH9(weth);
        UNISWAP_V2_ROUTER = IUniswapV2Router(uniswap_v2_router);

        vm.label(address(WBTC), "WBTC");
        vm.label(address(DAI), "DAI");
        vm.label(address(WETH), "WETH");
        vm.label(address(UNISWAP_V2_ROUTER), "ROUTER");

        vm.startPrank(0x218B95BE3ed99141b0144Dba6cE88807c4AD7C09);
        WBTC.transfer(address(this), 10 ** WBTC.decimals()); // transfer 1 BTC to self-contract
        vm.stopPrank();
    }

    function testUniswapv2_swap() public {
        uint256 daiToDecimals = 10 ** DAI.decimals();
        uint256 wbtcToDecimals = 10 ** WBTC.decimals();

        uint256 btcBalance = WBTC.balanceOf(address(this));

        console2.log("----Swap 1 WBTC to DAI----");
        console2.log("DAI balance before swap:", DAI.balanceOf(address(this)) / daiToDecimals);
        console2.log("WBTC balance before swap:", btcBalance / wbtcToDecimals);
        console2.log("----");
        swap(address(WBTC), address(DAI), btcBalance, 1, address(this));
        console2.log("DAI balance after swap:", DAI.balanceOf(address(this)) / daiToDecimals);
        console2.log("WBTC balance after swap:", WBTC.balanceOf(address(this)) / wbtcToDecimals);
    }

    function swap(address _tokenIn, address _tokenOut, uint256 _amountIn, uint256 _amountOutMin, address _to) public {
        IERC20(_tokenIn).approve(address(UNISWAP_V2_ROUTER), _amountIn);

        address[] memory path;
        // 如果是eth交易对 则是 [token1 , eth], 否则就是 [token1, eth, token2]
        if (_tokenIn == address(WETH) || _tokenOut == address(WETH)) {
            path = new address[](2);
            path[0] = _tokenIn;
            path[1] = _tokenOut;
        } else {
            path = new address[](3);
            path[0] = _tokenIn;
            path[1] = address(WETH);
            path[2] = _tokenOut;
        }

        // 根据精确的token交换尽量多的token
        UNISWAP_V2_ROUTER.swapExactTokensForTokens(_amountIn, _amountOutMin, path, _to, block.timestamp + 1);
    }
}
