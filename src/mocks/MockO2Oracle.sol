// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ForteVault} from "../ForteVault.sol"; 

/**
 * @title MockO2Oracle
 * @dev Simulates delivery and fraud status for a project ID, used by the Rules Engine.
 */
contract MockO2Oracle {
    mapping(uint256 => bool) public delivered;
    mapping(uint256 => bool) public fraud;

    function setDelivered(uint256 projectId, bool status) external {
        delivered[projectId] = status;
    }

    function setFraud(uint256 projectId, bool status) external {
        fraud[projectId] = status;
    }

    /**
     * @notice Read a boolean value for a given projectId and index
     * @dev index 0 = delivered, index 1 = fraud
     */
    function readBool(uint256 projectId, uint256 index) external view returns (bool) {
        if (index == 0) {
            return delivered[projectId];
        } else if (index == 1) {
            return fraud[projectId];
        } else {
            revert("Invalid index");
        }
    }
}
