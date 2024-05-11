// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperDeploy is Script {
    struct HelperConfig {
        address priceFeed;
    }

    HelperConfig public helperConfig;

    constructor() {
        if (block.chainid == 11155111) {
            helperConfig = getSepoliaEthPriceFeed();
        } else if (block.chainid == 1) {
            helperConfig = getMainnetEthPriceFeed();
        } else if (block.chainid == 31337) {
            helperConfig = getLocalEthPriceFeed();
        }
    }

    function getSepoliaEthPriceFeed() public pure returns (HelperConfig memory) {
        return
            HelperConfig({
                priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
            });
    }

    function getMainnetEthPriceFeed()
        public
        pure
        returns (HelperConfig memory)
    {
        return
            HelperConfig({
                priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
            });
    }

    function getLocalEthPriceFeed() public returns (HelperConfig memory) {
        if (helperConfig.priceFeed != address(0)) {
            return helperConfig;
        }
        
        vm.startBroadcast();
        MockV3Aggregator priceFeed = new MockV3Aggregator({
            _decimals: 8,
            _initialAnswer: 2e13
        });
        vm.stopBroadcast();

        return HelperConfig({
            priceFeed: address(priceFeed)
        });
    }
}
