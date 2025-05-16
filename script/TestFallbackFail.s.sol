// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import {ForteVault} from "../src/ForteVault.sol";

contract TestFallbackFail is Script {
    function run() external {
        ForteVault vault = new ForteVault();

        address dummyRulesEngine = 0xDeaDbeefdEAdbeefdEadbEEFdeadbeEFdEaDbeeF;
        vault.setRulesEngineAddress(dummyRulesEngine);

        address client = address(1);
        address artist = address(2);
        vm.deal(client, 1 ether);

        vm.startPrank(client);
        vault.createProject{value: 1 ether}(payable(artist), 2);
        uint256 projectId = vault.projectCounter();
        console.log("projectId = %s", projectId);

        // First milestone passed
        vault.releaseMilestone(projectId, true, false);

        // Invalid fallback (fallbackReady = false)
        try vault.fallbackRelease(projectId, false) {
            revert("Test failed: fallbackRelease should have reverted");
        } catch Error(string memory reason) {
            console.log("Caught revert with reason: %s", reason);
        } catch {
            console.log("Caught fallback revert without reason.");
        }


        vm.stopPrank();
    }
}
