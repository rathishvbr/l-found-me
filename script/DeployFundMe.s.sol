//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";

contract DeployFundMe is Script {
    function run() public {
        vm.startBroadcast();
        new FundMe(address(this));
        vm.stopBroadcast();
    }
}
