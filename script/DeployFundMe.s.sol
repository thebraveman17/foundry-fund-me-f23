// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperDeploy} from "./HelperDeploy.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        HelperDeploy helperDeploy = new HelperDeploy();
        console.logAddress(address(helperDeploy));
        address priceFeed = helperDeploy.helperConfig();
        vm.startBroadcast();
        FundMe fundMe = new FundMe(priceFeed);
        vm.stopBroadcast();
        return fundMe;
    }
}
