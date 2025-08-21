// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
/**
 * @title ChainSage Core
 * @dev Main contract for ChainSage DeFi Risk Detection Platform
 * @author ChainSage Team
 */
contract ChainSageCore is AccessControl, ReentrancyGuard, Pausable {
    // Role definitions
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant RISK_ANALYST_ROLE = keccak256("RISK_ANALYST_ROLE");
    bytes32 public constant USER_ROLE = keccak256("USER_ROLE");

    // Platform state
    uint256 private _riskEventId;
    uint256 private _userCount;

    uint256 public subscriptionPrice = 0.01 ether; // 0.01 ETH per month
    uint256 public totalRevenue;

    // Risk event tracking
    struct RiskEvent {
        uint256 id;
        address target;
        uint8 riskLevel; // 0-100
        string riskType;
        string description;
        string evidence; // IPFS hash or similar
        address reporter;
        uint256 timestamp;
        bool isResolved;
    }

    struct UserProfile {
        bool isRegistered;
        uint256 registrationDate;
        uint256 lastActive;
        uint256 riskEventsReported;
        uint256 subscriptionExpiry;
    }

    mapping(uint256 => RiskEvent) public riskEvents;
    mapping(address => UserProfile) public userProfiles;
    mapping(address => bool) public isSubscribed;

    // Events
    event UserRegistered(address indexed user, uint256 timestamp);
    event UserSubscribed(address indexed user, uint256 expiry);
    event RiskEventCreated(
        uint256 indexed eventId,
        address indexed target,
        uint8 riskLevel,
        string description
    );
    event RevenueCollected(address indexed collector, uint256 amount);

    /**
     * @dev Constructor sets up initial roles and admin
     */
    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
        _grantRole(RISK_ANALYST_ROLE, msg.sender);

        emit UserRegistered(msg.sender, block.timestamp);
    }

    /**
     * @dev Register as a new user
     */
    function registerUser() external {
        require(
            !userProfiles[msg.sender].isRegistered,
            "User already registered"
        );

        userProfiles[msg.sender] = UserProfile({
            isRegistered: true,
            registrationDate: block.timestamp,
            lastActive: block.timestamp,
            riskEventsReported: 0,
            subscriptionExpiry: 0
        });

        _userCount++;
        emit UserRegistered(msg.sender, block.timestamp);
    }

    /**
     * @dev Subscribe to ChainSage platform
     * @param months Number of months to subscribe
     */
    function subscribe(
        uint256 months
    ) external payable nonReentrant whenNotPaused {
        require(months > 0 && months <= 12, "Invalid subscription period");
        require(
            msg.value >= subscriptionPrice * months,
            "Insufficient payment"
        );
        require(userProfiles[msg.sender].isRegistered, "User not registered");

        uint256 currentExpiry = userProfiles[msg.sender].subscriptionExpiry;
        uint256 newExpiry = currentExpiry > block.timestamp
            ? currentExpiry + (months * 30 days)
            : block.timestamp + (months * 30 days);

        userProfiles[msg.sender].subscriptionExpiry = newExpiry;
        isSubscribed[msg.sender] = true;
        userProfiles[msg.sender].lastActive = block.timestamp;

        totalRevenue += msg.value;
        emit UserSubscribed(msg.sender, newExpiry);
    }

    /**
     * @dev Report a new risk event (only authorized roles)
     * @param target Address of the risky contract/wallet
     * @param riskLevel Risk level (0-100)
     * @param riskType Type of risk detected
     * @param description Description of the risk
     * @param evidence Evidence hash (IPFS or similar)
     */
    function reportRiskEvent(
        address target,
        uint8 riskLevel,
        string calldata riskType,
        string calldata description,
        string calldata evidence
    ) external onlyRole(RISK_ANALYST_ROLE) whenNotPaused {
        require(riskLevel <= 100, "Invalid risk level");
        require(bytes(description).length > 0, "Description required");

        _riskEventId++;
        uint256 eventId = _riskEventId;

        riskEvents[eventId] = RiskEvent({
            id: eventId,
            target: target,
            riskLevel: riskLevel,
            riskType: riskType,
            description: description,
            evidence: evidence,
            reporter: msg.sender,
            timestamp: block.timestamp,
            isResolved: false
        });

        // Update user profile if reporter is registered
        if (userProfiles[msg.sender].isRegistered) {
            userProfiles[msg.sender].riskEventsReported++;
        }

        emit RiskEventCreated(eventId, target, riskLevel, description);
    }

    /**
     * @dev Get risk events for a specific target
     * @param target Address to check
     * @param limit Maximum number of events to return
     * @return events Array of risk events
     */
    function getRiskEventsForTarget(
        address target,
        uint256 limit
    ) external view returns (RiskEvent[] memory events) {
        uint256 count = 0;
        uint256 maxEvents = limit > 0 ? limit : 50;

        // Count matching events
        for (uint256 i = 1; i <= _riskEventId; i++) {
            if (riskEvents[i].target == target) {
                count++;
                if (count >= maxEvents) break;
            }
        }

        events = new RiskEvent[](count);
        uint256 index = 0;

        // Fill events array
        for (uint256 i = 1; i <= _riskEventId && index < count; i++) {
            if (riskEvents[i].target == target) {
                events[index] = riskEvents[i];
                index++;
            }
        }
    }

    /**
     * @dev Check if user has active subscription
     * @param user Address to check
     * @return bool True if user has active subscription
     */
    function hasActiveSubscription(address user) external view returns (bool) {
        return
            isSubscribed[user] &&
            userProfiles[user].subscriptionExpiry > block.timestamp;
    }

    /**
     * @dev Get user profile
     * @param user Address to get profile for
     * @return profile User profile struct
     */
    function getUserProfile(
        address user
    ) external view returns (UserProfile memory profile) {
        return userProfiles[user];
    }

    /**
     * @dev Collect platform revenue (admin only)
     */
    function collectRevenue() external onlyRole(ADMIN_ROLE) nonReentrant {
        uint256 amount = address(this).balance;
        require(amount > 0, "No revenue to collect");

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");

        totalRevenue += amount;
        emit RevenueCollected(msg.sender, amount);
    }

    /**
     * @dev Pause contract (admin only)
     */
    function pause() external onlyRole(ADMIN_ROLE) {
        _pause();
    }

    /**
     * @dev Unpause contract (admin only)
     */
    function unpause() external onlyRole(ADMIN_ROLE) {
        _unpause();
    }

    /**
     * @dev Get platform statistics
     * @return users Total registered users
     * @return events Total risk events
     * @return revenue Total platform revenue
     */
    function getPlatformStats()
        external
        view
        returns (uint256 users, uint256 events, uint256 revenue)
    {
        return (_userCount, _riskEventId, totalRevenue);
    }

    // Receive function for ETH
    receive() external payable {}
}
