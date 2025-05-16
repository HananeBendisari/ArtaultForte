// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import {ForteVault} from "../src/ForteVault.sol";

contract TestReleaseFail is Script {
    function run() external {
        ForteVault vault = new ForteVault();

        // Simulate a dummy RulesEngine (any non-zero address works for local test)
        address dummyRulesEngine = 0xDeaDbeefdEAdbeefdEadbEEFdeadbeEFdEaDbeeF;
        vault.setRulesEngineAddress(dummyRulesEngine);

        address client = address(1);
        address artist = address(2);
        vm.deal(client, 1 ether);

        vm.startPrank(client);
        vault.createProject{value: 1 ether}(payable(artist), 2);
        uint256 projectId = vault.projectCounter();
        console.log("projectId = %s", projectId);

        // Expect this to revert due to rule violation
        try vault.releaseMilestone(projectId, false, true) {
            revert("Test failed: releaseMilestone should have reverted");
        } catch {
            console.log("Revert caught: releaseMilestone was blocked as expected.");
        }

        vm.stopPrank();
    }
}
