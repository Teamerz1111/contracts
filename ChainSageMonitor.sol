// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title ChainSageMonitor
 * @dev Blockchain monitoring contract for ChainSage on 0G Mainnet
 * @notice Manages watchlists and risk scores for monitored wallet addresses
 */
contract ChainSageMonitor {
    // Contract owner
    address public owner;
    
    // Watchlist entry structure
    struct WatchlistEntry {
        address wallet;
        string label;
        uint256 addedAt;
        uint256 riskScore;
        bool isActive;
    }
    
    // Risk assessment structure
    struct RiskAssessment {
        uint256 timestamp;
        uint256 score;
        string level;
        string reason;
    }
    
    // State mappings
    mapping(address => mapping(address => WatchlistEntry)) public watchlists;
    mapping(address => address[]) public userWatchlists;
    mapping(address => uint256) public currentRiskScores;
    mapping(address => RiskAssessment[]) public riskHistory;
    
    // Counters
    uint256 public totalWatchlists;
    uint256 public totalRiskAssessments;
    uint256 public totalUsers;
    
    // Events
    event WalletAdded(address indexed user, address indexed wallet, string label, uint256 timestamp);
    event WalletRemoved(address indexed user, address indexed wallet, uint256 timestamp);
    event RiskScoreUpdated(address indexed wallet, uint256 oldScore, uint256 newScore, uint256 timestamp);
    event RiskAssessed(address indexed wallet, uint256 score, string level, uint256 timestamp);
    
    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    constructor() {
        owner = msg.sender;
    }
    
    /**
     * @dev Add a wallet to user's watchlist
     * @param _wallet Address to monitor
     * @param _label Human-readable label for the wallet
     */
    function addToWatchlist(address _wallet, string memory _label) external {
        require(_wallet != address(0), "Invalid wallet address");
        require(!watchlists[msg.sender][_wallet].isActive, "Wallet already in watchlist");
        require(bytes(_label).length > 0, "Label cannot be empty");
        
        // Check if this is user's first watchlist entry
        if (userWatchlists[msg.sender].length == 0) {
            totalUsers++;
        }
        
        watchlists[msg.sender][_wallet] = WatchlistEntry({
            wallet: _wallet,
            label: _label,
            addedAt: block.timestamp,
            riskScore: 0,
            isActive: true
        });
        
        userWatchlists[msg.sender].push(_wallet);
        totalWatchlists++;
        
        emit WalletAdded(msg.sender, _wallet, _label, block.timestamp);
    }
    
    /**
     * @dev Remove a wallet from user's watchlist
     * @param _wallet Address to stop monitoring
     */
    function removeFromWatchlist(address _wallet) external {
        require(watchlists[msg.sender][_wallet].isActive, "Wallet not in watchlist");
        
        watchlists[msg.sender][_wallet].isActive = false;
        totalWatchlists--;
        
        emit WalletRemoved(msg.sender, _wallet, block.timestamp);
    }
    
    /**
     * @dev Update risk score for a wallet (owner only for now)
     * @param _wallet Address to update risk score for
     * @param _score Risk score (0-100)
     */
    function updateRiskScore(address _wallet, uint256 _score) external onlyOwner {
        require(_wallet != address(0), "Invalid wallet address");
        require(_score <= 100, "Risk score must be between 0 and 100");
        
        uint256 oldScore = currentRiskScores[_wallet];
        currentRiskScores[_wallet] = _score;
        totalRiskAssessments++;
        
        emit RiskScoreUpdated(_wallet, oldScore, _score, block.timestamp);
    }
    
    /**
     * @dev Record a detailed risk assessment
     * @param _wallet Address being assessed
     * @param _score Risk score (0-100)
     * @param _level Risk level (low/medium/high/critical)
     * @param _reason Explanation of the risk assessment
     */
    function recordRiskAssessment(
        address _wallet,
        uint256 _score,
        string memory _level,
        string memory _reason
    ) external onlyOwner {
        require(_wallet != address(0), "Invalid wallet address");
        require(_score <= 100, "Risk score must be between 0 and 100");
        
        riskHistory[_wallet].push(RiskAssessment({
            timestamp: block.timestamp,
            score: _score,
            level: _level,
            reason: _reason
        }));
        
        currentRiskScores[_wallet] = _score;
        totalRiskAssessments++;
        
        emit RiskAssessed(_wallet, _score, _level, block.timestamp);
    }
    
    /**
     * @dev Get user's complete watchlist
     * @param _user User address
     * @return Array of watched wallet addresses
     */
    function getUserWatchlist(address _user) external view returns (address[] memory) {
        return userWatchlists[_user];
    }
    
    /**
     * @dev Get detailed watchlist entry
     * @param _user User address
     * @param _wallet Watched wallet address
     * @return Watchlist entry details
     */
    function getWatchlistEntry(address _user, address _wallet) 
        external 
        view 
        returns (WatchlistEntry memory) 
    {
        return watchlists[_user][_wallet];
    }
    
    /**
     * @dev Get current risk score for a wallet
     * @param _wallet Wallet address
     * @return Current risk score (0-100)
     */
    function getRiskScore(address _wallet) external view returns (uint256) {
        return currentRiskScores[_wallet];
    }
    
    /**
     * @dev Get risk assessment history for a wallet
     * @param _wallet Wallet address
     * @return Array of risk assessments
     */
    function getRiskHistory(address _wallet) external view returns (RiskAssessment[] memory) {
        return riskHistory[_wallet];
    }
    
    /**
     * @dev Get platform statistics
     * @return users Total number of users
     * @return watchlists Total number of active watchlists
     * @return assessments Total number of risk assessments
     */
    function getPlatformStats() 
        external 
        view 
        returns (uint256 users, uint256 watchlists, uint256 assessments) 
    {
        return (totalUsers, totalWatchlists, totalRiskAssessments);
    }
    
    /**
     * @dev Check if a wallet is in user's watchlist
     * @param _user User address
     * @param _wallet Wallet address to check
     * @return True if wallet is in watchlist
     */
    function isInWatchlist(address _user, address _wallet) external view returns (bool) {
        return watchlists[_user][_wallet].isActive;
    }
    
    /**
     * @dev Transfer ownership (owner only)
     * @param _newOwner New owner address
     */
    function transferOwnership(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "Invalid new owner address");
        owner = _newOwner;
    }
}
