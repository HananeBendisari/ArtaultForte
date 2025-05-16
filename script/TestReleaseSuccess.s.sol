// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import {ForteVault} from "../src/ForteVault.sol";

contract TestReleaseSuccess is Script {
    function run() external {
        // Deploy a fresh vault locally for this simulation
        ForteVault vault = new ForteVault();

        address client = address(1);
        address artist = address(2);

        // Fund the client
        vm.deal(client, 1 ether);

        // Simulate the client creating a project
        vm.startPrank(client);
        vault.createProject{value: 1 ether}(payable(artist), 2);
        uint256 projectId = vault.projectCounter();
        console.log("Created project ID: %s", projectId);

        // Call releaseMilestone with valid rules
        vault.releaseMilestone(projectId, true, false);
        vm.stopPrank();
    }
}
