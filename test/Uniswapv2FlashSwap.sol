// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "./interfaces/IWETH9.sol";
import "./interfaces/IUniswap.sol";

import {HelperConfig} from "../script/HelperConfig.s.sol";

contract Uniswapv2FlashSwapTest is Test {
    WETH9 WETH;
    // uni/weth
    IUniswapV2Pair UniswapV2Pair = IUniswapV2Pair(0xd3d2E2692501A5c9Ca623199D38826e513033a17);

    function setUp() public {
        //fork mainnet at block 15012670
        vm.createSelectFork("mainnet", 15012670);

        HelperConfig helperConfig = new HelperConfig();
        address weth = helperConfig.getVar("weth");
        WETH = WETH9(weth);
    }

    function testUniswapv2Flashswap() public {
        WETH.deposit{value: 2 ether}();
        UniswapV2Pair.swap(0, 100 * 1e18, address(this), "0x00");
    }

    function uniswapV2Call(address sender, uint256 amount0, uint256 amount1, bytes calldata data) external {
        emit log_named_decimal_uint("Before flashswap, WETH balance of user:", WETH.balanceOf(address(this)), 18);
        // 0.3% fees
        uint256 fee = ((amount1 * 3) / 997) + 1;
        uint256 amountToRepay = amount1 + fee;
        emit log_named_decimal_uint("Amount to repay:", amountToRepay, 18);

        WETH.transfer(address(UniswapV2Pair), amountToRepay);

        emit log_named_decimal_uint("After flashswap, WETH balance of user:", WETH.balanceOf(address(this)), 18);
    }

    receive() external payable {}
}
