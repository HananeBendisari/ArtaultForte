// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "@thrackle-io/forte-rules-engine/src/client/RulesEngineClient.sol";
import "forge-std/console.sol";

/**
 * @title Template Contract for Testing the Rules Engine
 */
abstract contract RulesEngineClientCustom is RulesEngineClient {
    /// @notice Modifier for checking rules before calling releaseMilestone
    /// @param projectId The ID of the project
    /// @param oracleDelivered Whether the oracle confirmed delivery
    /// @param isFraud Whether fraud has been detected
    modifier checkRulesBeforereleaseMilestone(uint256 projectId, bool oracleDelivered, bool isFraud) {
    console.log("modifier active: oracleDelivered = %s, isFraud = %s", oracleDelivered, isFraud);
    bytes4 selector = bytes4(keccak256("releaseMilestone(uint256,bool,bool)"));
    bytes memory encoded = abi.encodeWithSelector(selector, projectId, oracleDelivered, isFraud);
    _invokeRulesEngine(encoded);
    _;
}



    /// @notice Modifier for checking rules before calling fallbackRelease
    /// @param projectId The ID of the project
    /// @param fallbackReady Whether fallback conditions are met
    modifier checkRulesBeforefallbackRelease(uint256 projectId, bool fallbackReady) {
        bytes4 selector = bytes4(keccak256("fallbackRelease(uint256,bool)"));

        // DEBUG LOGGING
        console.log("fallbackRelease triggered");
        console.log("selector: 0x%x", uint256(uint32(selector)));
        console.log("projectId: %s", projectId);
        console.log("fallbackReady: %s", fallbackReady);

        bytes memory encoded = abi.encodeWithSelector(selector, projectId, fallbackReady);
        console.log("encoded length: %s", encoded.length);
        for (uint256 i = 0; i < encoded.length; i++) {
            console.log("  encoded[%s] = 0x%x", i, uint8(encoded[i]));
        }

        _invokeRulesEngine(encoded);
        _;
    }
}
