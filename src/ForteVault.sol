// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "src/RulesEngineIntegration.sol";

/**
 * @title ForteVault
 * @dev Smart contract for milestone-based escrow payments between clients and artists,
 * enhanced with on-chain policy enforcement via Forte Rules Engine.
 */
contract ForteVault is RulesEngineClientCustom {
    enum ProjectStatus { Uninitialized, Created, InProgress, Completed, Refunded }

    struct Project {
        address client;
        address payable artist;
        uint256 totalAmount;
        uint256 milestones;
        uint256 releasedMilestones;
        uint256 createdAt;
        ProjectStatus status;
    }

    mapping(uint256 => Project) public projects;
    uint256 public projectCounter;

    modifier onlyClient(uint256 projectId) {
        require(msg.sender == projects[projectId].client, "Not the client");
        _;
    }

    modifier onlyArtist(uint256 projectId) {
        require(msg.sender == projects[projectId].artist, "Not the artist");
        _;
    }

    modifier projectExists(uint256 projectId) {
        require(projects[projectId].status != ProjectStatus.Uninitialized, "Project does not exist");
        _;
    }

    modifier inProgress(uint256 projectId) {
        require(projects[projectId].status == ProjectStatus.InProgress, "Project not in progress");
        _;
    }

    event ProjectCreated(uint256 indexed projectId, address indexed client, address indexed artist, uint256 amount, uint256 milestones);
    event MilestoneReleased(uint256 indexed projectId, uint256 milestoneNumber, uint256 amount);
    event ProjectRefunded(uint256 indexed projectId, uint256 remainingAmount);
    event ProjectValidated(uint256 indexed projectId);

    /// @notice Create a new project escrow
    function createProject(address payable artist, uint256 milestones) external payable {
        require(msg.value > 0, "No funds sent");
        require(milestones > 0, "Milestones must be > 0");

        uint256 projectId = ++projectCounter;
        projects[projectId] = Project({
            client: msg.sender,
            artist: artist,
            totalAmount: msg.value,
            milestones: milestones,
            releasedMilestones: 0,
            createdAt: block.timestamp,
            status: ProjectStatus.InProgress
        });

        emit ProjectCreated(projectId, msg.sender, artist, msg.value, milestones);
    }

    /// @notice Release next milestone to the artist
    /// @dev Enforces on-chain rules before proceeding (oracle + fraud check)
    function releaseMilestone(uint256 projectId, bool oracleDelivered, bool isFraud)
    external
    onlyClient(projectId)
    inProgress(projectId)
    checkRulesBeforereleaseMilestone(projectId, oracleDelivered, isFraud) 

    {
        Project storage p = projects[projectId];
        require(p.releasedMilestones < p.milestones, "All milestones released");

        uint256 amount = p.totalAmount / p.milestones;
        p.releasedMilestones += 1;
        p.artist.transfer(amount);

        emit MilestoneReleased(projectId, p.releasedMilestones, amount);
    }

    /// @notice Refund remaining funds to the client
    function refundClient(uint256 projectId) external onlyArtist(projectId) inProgress(projectId) {
        Project storage p = projects[projectId];
        uint256 released = p.totalAmount * p.releasedMilestones / p.milestones;
        uint256 refund = p.totalAmount - released;
        require(refund > 0, "Nothing to refund");

        p.status = ProjectStatus.Refunded;
        payable(p.client).transfer(refund);

        emit ProjectRefunded(projectId, refund);
    }

    /// @notice Validate and mark project as completed
    function validateProject(uint256 projectId) external onlyClient(projectId) inProgress(projectId) {
        Project storage p = projects[projectId];
        require(p.releasedMilestones == p.milestones, "Not all milestones released");

        p.status = ProjectStatus.Completed;

        emit ProjectValidated(projectId);
    }

    /// @notice Fallback release if both parties agree or timeout is reached
    /// @dev Enforces fallback readiness via the Rules Engine
    function fallbackRelease(uint256 projectId, bool fallbackReady)
        external
        projectExists(projectId)
        inProgress(projectId)
        checkRulesBeforefallbackRelease(projectId, fallbackReady)
    {
        require(
            msg.sender == projects[projectId].client || msg.sender == projects[projectId].artist,
            "Unauthorized"
        );

        Project storage p = projects[projectId];
        require(p.releasedMilestones < p.milestones, "All milestones paid");

        uint256 amount = p.totalAmount / p.milestones;
        p.releasedMilestones += 1;
        p.artist.transfer(amount);

        emit MilestoneReleased(projectId, p.releasedMilestones, amount);
    }
}
