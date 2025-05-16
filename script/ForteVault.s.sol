// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import {ForteVault} from "../src/ForteVault.sol";

contract ForteVaultDeploy is Script {
    function run() external {
        // Load private key from .env
        uint256 deployerPrivateKey = vm.envUint("PRIV_KEY");

        vm.startBroadcast(deployerPrivateKey);

        // Deploy the contract
        ForteVault vault = new ForteVault();

        console.log("ForteVault deployed at:", address(vault));

        // Set Rules Engine address
        address rulesEngine = vm.envAddress("RULES_ENGINE_ADDRESS");
        vault.setRulesEngineAddress(rulesEngine);
        console.log("RulesEngine address set to:", rulesEngine);

        vm.stopBroadcast();
    }
}

