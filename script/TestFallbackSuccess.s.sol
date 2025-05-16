// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import {ForteVault} from "../src/ForteVault.sol";

contract TestFallbackSuccess is Script {
    function run() external {
        // Deploy a new local ForteVault instance
        ForteVault vault = new ForteVault();

        address client = address(1);
        address artist = address(2);

        // Give the client some ETH
        vm.deal(client, 1 ether);

        // Simulate the client creating a project
        vm.startPrank(client);
        vault.createProject{value: 1 ether}(payable(artist), 2);
        uint256 projectId = vault.projectCounter();
        console.log("projectId = %s", projectId);

        // First milestone released via standard path
        vault.releaseMilestone(projectId, true, false);

        // Second milestone released via fallback path
        vault.fallbackRelease(projectId, true);

        vm.stopPrank();
    }
}
