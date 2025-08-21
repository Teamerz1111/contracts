// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

/**
 * @title Risk Detector
 * @dev Contract for risk scoring and monitoring
 * @author ChainSage Team
 */
contract RiskDetector is AccessControl, Pausable {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant ANALYST_ROLE = keccak256("ANALYST_ROLE");

    struct RiskScore {
        uint8 overallScore;
        uint8 liquidityRisk;
        uint8 contractRisk;
        uint8 whaleRisk;
        uint8 marketRisk;
        uint256 lastUpdated;
        string analysis;
    }

    struct RiskFactor {
        string name;
        uint8 weight;
        uint8 score;
        string description;
    }

    // Risk thresholds
    uint8 public highRiskThreshold = 80;
    uint8 public mediumRiskThreshold = 50;
    uint8 public lowRiskThreshold = 20;

    // Storage
    mapping(address => RiskScore) public riskScores;
    mapping(address => RiskFactor[]) public riskFactors;
    mapping(address => bool) public isInWatchlist;
    mapping(address => string) public watchlistLabels;

    address[] public watchlistAddresses;

    // Events
    event RiskScoreUpdated(
        address indexed target,
        uint8 newScore,
        uint256 timestamp
    );
    event WatchlistItemAdded(address indexed target, string label);
    event WatchlistItemRemoved(address indexed target);
    event RiskThresholdExceeded(
        address indexed target,
        uint8 score,
        uint8 threshold
    );
    event RiskThresholdsUpdated(uint8 high, uint8 medium, uint8 low);

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
        _grantRole(ANALYST_ROLE, msg.sender);
    }

    /**
     * @dev Update risk score for a target (only authorized)
     * @param target Address to update
     * @param newScore New risk score
     * @param factors Risk factors contributing to score
     */
    function updateRiskScore(
        address target,
        RiskScore calldata newScore,
        RiskFactor[] calldata factors
    ) external onlyRole(ANALYST_ROLE) whenNotPaused {
        require(target != address(0), "Invalid target address");
        require(newScore.overallScore <= 100, "Invalid risk score");

        riskScores[target] = newScore;

        // Clear existing factors and add new ones
        delete riskFactors[target];
        for (uint256 i = 0; i < factors.length; i++) {
            riskFactors[target].push(factors[i]);
        }

        // Check if risk exceeds thresholds
        if (newScore.overallScore >= highRiskThreshold) {
            emit RiskThresholdExceeded(
                target,
                newScore.overallScore,
                highRiskThreshold
            );
        }

        emit RiskScoreUpdated(target, newScore.overallScore, block.timestamp);
    }

    /**
     * @dev Get risk score for a target
     * @param target Address to check
     * @return score Risk score struct
     */
    function getRiskScore(
        address target
    ) external view returns (RiskScore memory score) {
        return riskScores[target];
    }

    /**
     * @dev Get risk factors for a target
     * @param target Address to check
     * @return factors Array of risk factors
     */
    function getRiskFactors(
        address target
    ) external view returns (RiskFactor[] memory factors) {
        return riskFactors[target];
    }

    /**
     * @dev Check if risk is above threshold
     * @param target Address to check
     * @param threshold Risk threshold to check against
     * @return bool True if risk is above threshold
     */
    function isRiskAboveThreshold(
        address target,
        uint8 threshold
    ) external view returns (bool) {
        return riskScores[target].overallScore >= threshold;
    }

    /**
     * @dev Add address to watchlist (only authorized)
     * @param target Address to add
     * @param label Human-readable label
     */
    function addToWatchlist(
        address target,
        string calldata label
    ) external onlyRole(ANALYST_ROLE) {
        require(target != address(0), "Invalid target address");
        require(!isInWatchlist[target], "Already in watchlist");

        isInWatchlist[target] = true;
        watchlistLabels[target] = label;
        watchlistAddresses.push(target);

        emit WatchlistItemAdded(target, label);
    }

    /**
     * @dev Remove address from watchlist (only authorized)
     * @param target Address to remove
     */
    function removeFromWatchlist(
        address target
    ) external onlyRole(ANALYST_ROLE) {
        require(isInWatchlist[target], "Not in watchlist");

        isInWatchlist[target] = false;
        delete watchlistLabels[target];

        // Remove from watchlistAddresses array
        for (uint256 i = 0; i < watchlistAddresses.length; i++) {
            if (watchlistAddresses[i] == target) {
                watchlistAddresses[i] = watchlistAddresses[
                    watchlistAddresses.length - 1
                ];
                watchlistAddresses.pop();
                break;
            }
        }

        emit WatchlistItemRemoved(target);
    }

    /**
     * @dev Get all watchlist addresses
     * @return addresses Array of watchlist addresses
     */
    function getWatchlistAddresses()
        external
        view
        returns (address[] memory addresses)
    {
        return watchlistAddresses;
    }

    /**
     * @dev Get watchlist label for an address
     * @param target Address to check
     * @return label Watchlist label
     */
    function getWatchlistLabel(
        address target
    ) external view returns (string memory label) {
        return watchlistLabels[target];
    }

    /**
     * @dev Update risk thresholds (admin only)
     * @param high New high risk threshold
     * @param medium New medium risk threshold
     * @param low New low risk threshold
     */
    function updateRiskThresholds(
        uint8 high,
        uint8 medium,
        uint8 low
    ) external onlyRole(ADMIN_ROLE) {
        require(high > medium && medium > low, "Invalid threshold order");
        require(high <= 100 && low >= 0, "Thresholds out of range");

        highRiskThreshold = high;
        mediumRiskThreshold = medium;
        lowRiskThreshold = low;

        emit RiskThresholdsUpdated(high, medium, low);
    }

    /**
     * @dev Get top risky addresses
     * @param limit Maximum number of addresses to return
     * @return addresses Array of risky addresses
     * @return scores Array of corresponding risk scores
     */
    function getTopRiskyAddresses(
        uint256 limit
    )
        external
        view
        returns (address[] memory addresses, RiskScore[] memory scores)
    {
        uint256 maxLimit = limit > 0 ? limit : 10;
        uint256 count = 0;

        // Count addresses with risk scores
        for (uint256 i = 0; i < watchlistAddresses.length; i++) {
            if (riskScores[watchlistAddresses[i]].overallScore > 0) {
                count++;
                if (count >= maxLimit) break;
            }
        }

        addresses = new address[](count);
        scores = new RiskScore[](count);

        uint256 index = 0;
        for (
            uint256 i = 0;
            i < watchlistAddresses.length && index < count;
            i++
        ) {
            if (riskScores[watchlistAddresses[i]].overallScore > 0) {
                addresses[index] = watchlistAddresses[i];
                scores[index] = riskScores[watchlistAddresses[i]];
                index++;
            }
        }
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
}
