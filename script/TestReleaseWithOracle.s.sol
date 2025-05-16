// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import {ForteVault} from "../src/ForteVault.sol";
import {MockO2Oracle} from "../src/mocks/MockO2Oracle.sol";

contract TestReleaseWithOracle is Script {
    function run() external {
        vm.startBroadcast();

        ForteVault vault = new ForteVault();
        MockO2Oracle oracle = new MockO2Oracle();

        uint256 projectId = 123;

        oracle.setDelivered(projectId, true);
        bool oracleDelivered = oracle.readBool(projectId, 0); // 0 = delivered
        bool isFraud = oracle.readBool(projectId, 1);         // 1 = fraud

        console.log("oracleDelivered: %s", oracleDelivered);
        console.log("isFraud: %s", isFraud);

        vault.releaseMilestone(projectId, oracleDelivered, isFraud);

        vm.stopBroadcast();
    }
}
