// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/ChainSageCore.sol";
import "../src/RiskDetector.sol";
import "../src/WatchlistManager.sol";

/**
 * @title ChainSage Tests
 * @dev Basic tests for ChainSage contracts
 * @author ChainSage Team
 */
contract ChainSageTest is Test {
    ChainSageCore public core;
    RiskDetector public riskDetector;
    WatchlistManager public watchlistManager;

    address public admin = address(1);
    address public user = address(2);
    address public analyst = address(3);
    address public target = address(4);

    function setUp() public {
        vm.startPrank(admin);

        // Deploy contracts
        core = new ChainSageCore();
        riskDetector = new RiskDetector();
        watchlistManager = new WatchlistManager();

        // Grant roles to contracts for integration
        core.grantRole(keccak256("RISK_ANALYST_ROLE"), address(riskDetector));
        core.grantRole(keccak256("USER_ROLE"), address(watchlistManager));

        vm.stopPrank();
    }

    function testUserRegistration() public {
        vm.startPrank(user);

        core.registerUser();

        ChainSageCore.UserProfile memory profile = core.getUserProfile(user);
        assertTrue(profile.isRegistered);

        vm.stopPrank();
    }

    function testUserSubscription() public {
        vm.startPrank(user);

        // Give user some ETH
        vm.deal(user, 1 ether);

        // Register first
        core.registerUser();

        // Subscribe for 1 month
        core.subscribe{value: 0.01 ether}(1);

        bool hasSubscription = core.hasActiveSubscription(user);
        assertTrue(hasSubscription);

        vm.stopPrank();
    }

    function testRiskEventReporting() public {
        vm.startPrank(admin);

        // Grant analyst role
        core.grantRole(keccak256("RISK_ANALYST_ROLE"), analyst);

        vm.stopPrank();

        vm.startPrank(analyst);

        // Report risk event
        core.reportRiskEvent(
            target,
            85,
            "RUG_PULL",
            "Suspicious liquidity removal",
            "ipfs://evidence"
        );

        // Check if event was created
        ChainSageCore.RiskEvent[] memory events = core.getRiskEventsForTarget(
            target,
            10
        );
        assertEq(events.length, 1);
        assertEq(events[0].riskLevel, 85);

        vm.stopPrank();
    }

    function testRiskDetection() public {
        vm.startPrank(admin);

        // Grant analyst role
        riskDetector.grantRole(keccak256("ANALYST_ROLE"), analyst);

        vm.stopPrank();

        vm.startPrank(analyst);

        // Create risk factors
        RiskDetector.RiskFactor[]
            memory factors = new RiskDetector.RiskFactor[](2);
        factors[0] = RiskDetector.RiskFactor({
            name: "Liquidity Risk",
            weight: 50,
            score: 80,
            description: "High liquidity removal detected"
        });
        factors[1] = RiskDetector.RiskFactor({
            name: "Contract Risk",
            weight: 50,
            score: 70,
            description: "Suspicious contract behavior"
        });

        // Update risk score
        RiskDetector.RiskScore memory score = RiskDetector.RiskScore({
            overallScore: 75,
            liquidityRisk: 80,
            contractRisk: 70,
            whaleRisk: 60,
            marketRisk: 50,
            lastUpdated: block.timestamp,
            analysis: "High risk due to liquidity concerns"
        });

        riskDetector.updateRiskScore(target, score, factors);

        // Check risk score
        RiskDetector.RiskScore memory retrievedScore = riskDetector
            .getRiskScore(target);
        assertEq(retrievedScore.overallScore, 75);

        vm.stopPrank();
    }

    function testWatchlistManagement() public {
        vm.startPrank(user);

        // Add to watchlist
        watchlistManager.addToWatchlist(
            target,
            "Suspicious Token",
            70,
            "High risk token to monitor"
        );

        // Check if in watchlist
        bool inWatchlist = watchlistManager.isInUserWatchlist(user, target);
        assertTrue(inWatchlist);

        // Get watchlist
        WatchlistManager.WatchlistItem[] memory items = watchlistManager
            .getUserWatchlist(user);
        assertEq(items.length, 1);
        assertEq(items[0].target, target);

        vm.stopPrank();
    }

    function testAlertSystem() public {
        vm.startPrank(admin);

        // Create alert
        watchlistManager.createAlert(
            user,
            target,
            85,
            "RUG_PULL",
            "High risk detected on watched address"
        );

        // Check alert count
        uint256 unreadCount = watchlistManager.getUnreadAlertCount(user);
        assertEq(unreadCount, 1);

        vm.stopPrank();

        // Mark as read
        vm.startPrank(user);
        watchlistManager.markAlertAsRead(1);

        unreadCount = watchlistManager.getUnreadAlertCount(user);
        assertEq(unreadCount, 0);

        vm.stopPrank();
    }

    function testAccessControl() public {
        vm.startPrank(user);

        // Should fail - user doesn't have admin role
        vm.expectRevert();
        core.pause();

        vm.stopPrank();
    }
}
