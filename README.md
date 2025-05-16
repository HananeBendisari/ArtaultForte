# ForteVault – Milestone-based Escrow with On-chain Policy Enforcement (EasyA x Forte – Consensus Hackathon 2025)

## Problem Statement

Freelancers and artists often face three critical issues in creative contracts:

1. Some clients fail to pay even after delivery.
2. Some artists fail to deliver on time or as promised.
3. Some clients cancel events last-minute after an artist has blocked the date, leading to unpaid work and losses.

ForteVault solves this by acting as a rule-based escrow contract that protects both parties. It ensures funds are only released when predefined delivery and integrity conditions are met, using Forte's on-chain Rules Engine.

## Overview

ForteVault is a Solidity-based escrow contract designed for milestone-based payments between clients and artists. Each payment is gated by project-defined rules, enforced on-chain via Forte's RulesEngine.

This project was built as part of the EasyA x Forte track at the Consensus 2025 Hackathon.

## Features

* Milestone-based payment logic
* Full client/artist separation with access control
* Refund and project validation mechanisms
* On-chain policy enforcement using Forte RulesEngine
* Modular architecture: fallback handling, fraud protection, oracle integration
* Fully tested with Foundry (positive and negative flows)

## Smart Contract: `ForteVault.sol`

### Core Functions

* `createProject(address artist, uint256 milestones)`
* `releaseMilestone(uint256 projectId, bool oracleDelivered, bool isFraud)`
* `fallbackRelease(uint256 projectId, bool fallbackReady)`
* `refundClient(uint256 projectId)`
* `validateProject(uint256 projectId)`

### Rule Enforcement

* `releaseMilestone` is gated by the `checkRulesBeforereleaseMilestone` modifier
* `fallbackRelease` is gated by `checkRulesBeforefallbackRelease`

## RulesEngine Integration

Rules are enforced via injected modifiers that encode selector and arguments, and delegate evaluation to the RulesEngine.

Example `policy.json`:

```json
{
  "Policy": "ForteVaultPolicy",
  "RulesJSON": [
    {
      "condition": "oracleDelivered == true",
      "negativeEffects": ["revert(\"Delivery not confirmed\")"],
      "functionSignature": "releaseMilestone(uint256 projectId, bool oracleDelivered, bool isFraud)",
      "encodedValues": "uint256 projectId, bool oracleDelivered, bool isFraud"
    },
    {
      "condition": "isFraud == false",
      "negativeEffects": ["revert(\"Fraud detected\")"],
      "functionSignature": "releaseMilestone(uint256 projectId, bool oracleDelivered, bool isFraud)",
      "encodedValues": "uint256 projectId, bool oracleDelivered, bool isFraud"
    },
    {
      "condition": "fallbackReady == true",
      "negativeEffects": ["revert(\"Fallback not authorized\")"],
      "functionSignature": "fallbackRelease(uint256 projectId, bool fallbackReady)",
      "encodedValues": "uint256 projectId, bool fallbackReady"
    }
  ]
}
```

## Running Locally

All tests run in a local Foundry/Anvil environment. No deployment to testnet is needed.

### Setup

```bash
anvil                       # start local node
forge build
forge script script/TestReleaseSuccess.s.sol --fork-url http://localhost:8545
```

No `.env`, no private key, no broadcast required.

## Test Coverage

Scripts under `/script/` simulate complete user flows.

### Positive

* `TestReleaseSuccess.s.sol` – milestone release success
* `TestFallbackSuccess.s.sol` – fallback release when allowed

### Negative (revert expected)

* `TestReleaseFail.s.sol` – fails when delivery is false and fraud is true
* `TestReleaseFraudFail.s.sol` – fails when fraud is flagged
* `TestFallbackFail.s.sol` – fails when fallbackReady is false

Each test uses `try/catch` to assert reverts. For local simulation, the RulesEngine address is set to:

```solidity
vault.setRulesEngineAddress(0xDeaDbeefdEAdbeefdEadbEEFdeadbeEFdEaDbeeF);
```

Note: This dummy address is not a deployed contract. Reverts are expected, but may not return error messages.

## Project Structure

```
ArtaultForte/
├── script/
│   ├── ForteVault.s.sol
│   ├── DeployMockOracle.s.sol
│   ├── TestReleaseSuccess.s.sol
│   ├── TestFallbackSuccess.s.sol
│   ├── TestReleaseFail.s.sol
│   ├── TestReleaseFraudFail.s.sol
│   └── TestFallbackFail.s.sol
├── src/
│   ├── ForteVault.sol
│   ├── RulesEngineIntegration.sol
│   └── mocks/MockO2Oracle.sol
├── policy.json
├── foundry.toml
└── README.md
```

## Notes

* This project is designed to run entirely in a local environment.
* For production use, deploy with a valid RulesEngine contract and apply policies externally.
* Mocked reverts simulate expected behavior for this hackathon use case.

## Author

Built by Hanane Bendisari as a solo submission for the EasyA x Forte track at the Consensus Hackathon 2025.
No team or collaborators. Entire design, implementation, and test suite authored independently.
