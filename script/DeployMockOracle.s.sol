// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import {MockO2Oracle} from "../src/mocks/MockO2Oracle.sol";

contract DeployMockOracle is Script {
    function run() external {
        vm.startBroadcast();

        MockO2Oracle oracle = new MockO2Oracle();
        console.log("MockO2Oracle deployed at: %s", address(oracle));

        vm.stopBroadcast();
    }
}
