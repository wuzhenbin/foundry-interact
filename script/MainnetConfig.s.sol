// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Script} from "forge-std/Script.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        address wbtc;
        address dai;
        address weth;
        address uniswap_v2_router;
    }

    NetworkConfig public activeNetworkConfig;
    uint96 public constant FUND_AMOUNT = 3 ether;

    constructor() {
        activeNetworkConfig = getEthConfig();
    }

    function getEthConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            wbtc: 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599,
            dai: 0x6B175474E89094C44Da98b954EedeAC495271d0F,
            weth: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, // 30 seconds
            uniswap_v2_router: 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        });
    }
}
