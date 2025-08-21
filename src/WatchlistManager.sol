// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
/**
 * @title Watchlist Manager
 * @dev Contract for managing user watchlists and alerts
 * @author ChainSage Team
 */
contract WatchlistManager is AccessControl, Pausable {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant USER_ROLE = keccak256("USER_ROLE");

    struct WatchlistItem {
        address target;
        string label;
        uint256 addedAt;
        bool isActive;
        uint8 customRiskThreshold;
        string notes;
    }

    struct Alert {
        uint256 id;
        address user;
        address target;
        uint8 riskLevel;
        string riskType;
        uint256 timestamp;
        bool isRead;
        string message;
    }

    struct UserWatchlist {
        address user;
        WatchlistItem[] items;
        uint256 itemCount;
        uint8 defaultRiskThreshold;
        bool notificationsEnabled;
    }

    // Storage
    mapping(address => UserWatchlist) public userWatchlists;
    mapping(address => Alert[]) public userAlerts;
    mapping(address => uint256) public alertCount;

    uint256 private _alertId;

    // Events
    event WatchlistItemAdded(
        address indexed user,
        address indexed target,
        string label
    );
    event WatchlistItemRemoved(address indexed user, address indexed target);
    event AlertCreated(
        uint256 indexed alertId,
        address indexed user,
        address indexed target
    );
    event AlertRead(address indexed user, uint256 indexed alertId);
    event UserSettingsUpdated(
        address indexed user,
        uint8 threshold,
        bool notifications
    );

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
        _grantRole(USER_ROLE, msg.sender);
    }

    /**
     * @dev Add item to user's watchlist
     * @param target Address to watch
     * @param label Human-readable label
     * @param customThreshold Custom risk threshold (0 = use default)
     * @param notes Additional notes
     */
    function addToWatchlist(
        address target,
        string calldata label,
        uint8 customThreshold,
        string calldata notes
    ) external whenNotPaused {
        require(target != address(0), "Invalid target address");
        require(bytes(label).length > 0, "Label required");

        UserWatchlist storage watchlist = userWatchlists[msg.sender];

        // Check if already in watchlist
        for (uint256 i = 0; i < watchlist.items.length; i++) {
            require(
                watchlist.items[i].target != target,
                "Already in watchlist"
            );
        }

        WatchlistItem memory newItem = WatchlistItem({
            target: target,
            label: label,
            addedAt: block.timestamp,
            isActive: true,
            customRiskThreshold: customThreshold,
            notes: notes
        });

        watchlist.items.push(newItem);
        watchlist.itemCount++;

        emit WatchlistItemAdded(msg.sender, target, label);
    }

    /**
     * @dev Remove item from user's watchlist
     * @param target Address to remove
     */
    function removeFromWatchlist(address target) external whenNotPaused {
        UserWatchlist storage watchlist = userWatchlists[msg.sender];

        for (uint256 i = 0; i < watchlist.items.length; i++) {
            if (watchlist.items[i].target == target) {
                // Remove item by swapping with last element
                watchlist.items[i] = watchlist.items[
                    watchlist.items.length - 1
                ];
                watchlist.items.pop();
                watchlist.itemCount--;

                emit WatchlistItemRemoved(msg.sender, target);
                return;
            }
        }

        revert("Item not found in watchlist");
    }

    /**
     * @dev Update watchlist item
     * @param target Address to update
     * @param label New label
     * @param customThreshold New custom threshold
     * @param notes New notes
     */
    function updateWatchlistItem(
        address target,
        string calldata label,
        uint8 customThreshold,
        string calldata notes
    ) external whenNotPaused {
        UserWatchlist storage watchlist = userWatchlists[msg.sender];

        for (uint256 i = 0; i < watchlist.items.length; i++) {
            if (watchlist.items[i].target == target) {
                watchlist.items[i].label = label;
                watchlist.items[i].customRiskThreshold = customThreshold;
                watchlist.items[i].notes = notes;
                return;
            }
        }

        revert("Item not found in watchlist");
    }

    /**
     * @dev Get user's watchlist
     * @param user Address of user
     * @return items Array of watchlist items
     */
    function getUserWatchlist(
        address user
    ) external view returns (WatchlistItem[] memory items) {
        return userWatchlists[user].items;
    }

    /**
     * @dev Get user's alerts
     * @param user Address of user
     * @return alerts Array of alerts
     */
    function getUserAlerts(
        address user
    ) external view returns (Alert[] memory alerts) {
        return userAlerts[user];
    }

    /**
     * @dev Create alert for user (called by risk detection system)
     * @param user Address of user to alert
     * @param target Address that triggered alert
     * @param riskLevel Risk level (0-100)
     * @param riskType Type of risk
     * @param message Alert message
     */
    function createAlert(
        address user,
        address target,
        uint8 riskLevel,
        string calldata riskType,
        string calldata message
    ) external onlyRole(ADMIN_ROLE) whenNotPaused {
        require(user != address(0), "Invalid user address");
        require(target != address(0), "Invalid target address");

        _alertId++;
        uint256 alertId = _alertId;

        Alert memory newAlert = Alert({
            id: alertId,
            user: user,
            target: target,
            riskLevel: riskLevel,
            riskType: riskType,
            timestamp: block.timestamp,
            isRead: false,
            message: message
        });

        userAlerts[user].push(newAlert);
        alertCount[user]++;

        emit AlertCreated(alertId, user, target);
    }

    /**
     * @dev Mark alert as read
     * @param alertId ID of alert to mark as read
     */
    function markAlertAsRead(uint256 alertId) external whenNotPaused {
        Alert[] storage alerts = userAlerts[msg.sender];

        for (uint256 i = 0; i < alerts.length; i++) {
            if (alerts[i].id == alertId) {
                alerts[i].isRead = true;
                emit AlertRead(msg.sender, alertId);
                return;
            }
        }

        revert("Alert not found");
    }

    /**
     * @dev Update user settings
     * @param defaultThreshold Default risk threshold
     * @param notificationsEnabled Enable/disable notifications
     */
    function updateUserSettings(
        uint8 defaultThreshold,
        bool notificationsEnabled
    ) external whenNotPaused {
        require(defaultThreshold <= 100, "Invalid threshold");

        UserWatchlist storage watchlist = userWatchlists[msg.sender];
        watchlist.defaultRiskThreshold = defaultThreshold;
        watchlist.notificationsEnabled = notificationsEnabled;

        emit UserSettingsUpdated(
            msg.sender,
            defaultThreshold,
            notificationsEnabled
        );
    }

    /**
     * @dev Get user settings
     * @param user Address of user
     * @return defaultThreshold Default risk threshold
     * @return notificationsEnabled Whether notifications are enabled
     */
    function getUserSettings(
        address user
    )
        external
        view
        returns (uint8 defaultThreshold, bool notificationsEnabled)
    {
        UserWatchlist storage watchlist = userWatchlists[user];
        return (watchlist.defaultRiskThreshold, watchlist.notificationsEnabled);
    }

    /**
     * @dev Check if user has item in watchlist
     * @param user Address of user
     * @param target Address to check
     * @return bool True if in watchlist
     */
    function isInUserWatchlist(
        address user,
        address target
    ) external view returns (bool) {
        UserWatchlist storage watchlist = userWatchlists[user];

        for (uint256 i = 0; i < watchlist.items.length; i++) {
            if (watchlist.items[i].target == target) {
                return true;
            }
        }

        return false;
    }

    /**
     * @dev Get unread alert count for user
     * @param user Address of user
     * @return count Number of unread alerts
     */
    function getUnreadAlertCount(
        address user
    ) external view returns (uint256 count) {
        Alert[] storage alerts = userAlerts[user];

        for (uint256 i = 0; i < alerts.length; i++) {
            if (!alerts[i].isRead) {
                count++;
            }
        }

        return count;
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
