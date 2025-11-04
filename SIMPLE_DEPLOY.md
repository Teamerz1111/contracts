# Simple Contract Deployment to 0G Mainnet

## 🚨 Quick Fix: Deploy Simple Contract

Since Foundry setup is complex on Windows, let's deploy a simpler, working contract that meets WaveHack requirements.

---

## Option 1: Deploy via Remix (EASIEST - 5 minutes)

### Step 1: Open Remix
Go to: https://remix.ethereum.org

### Step 2: Create New File
Create `ChainSageMonitor.sol` with this code:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title ChainSageMonitor
 * @dev Simple monitoring contract for ChainSage on 0G Mainnet
 */
contract ChainSageMonitor {
    // Owner
    address public owner;
    
    // Watchlist tracking
    struct WatchlistEntry {
        address wallet;
        string label;
        uint256 addedAt;
        uint256 riskScore;
        bool isActive;
    }
    
    // Mappings
    mapping(address => mapping(address => WatchlistEntry)) public watchlists;
    mapping(address => address[]) public userWatchlists;
    mapping(address => uint256) public riskScores;
    
    // Counters
    uint256 public totalWatchlists;
    uint256 public totalRiskAssessments;
    
    // Events
    event WalletAdded(address indexed user, address indexed wallet, string label);
    event WalletRemoved(address indexed user, address indexed wallet);
    event RiskScoreUpdated(address indexed wallet, uint256 score);
    
    constructor() {
        owner = msg.sender;
    }
    
    /**
     * @dev Add wallet to watchlist
     */
    function addToWatchlist(address _wallet, string memory _label) external {
        require(_wallet != address(0), "Invalid address");
        require(!watchlists[msg.sender][_wallet].isActive, "Already in watchlist");
        
        watchlists[msg.sender][_wallet] = WatchlistEntry({
            wallet: _wallet,
            label: _label,
            addedAt: block.timestamp,
            riskScore: 0,
            isActive: true
        });
        
        userWatchlists[msg.sender].push(_wallet);
        totalWatchlists++;
        
        emit WalletAdded(msg.sender, _wallet, _label);
    }
    
    /**
     * @dev Remove wallet from watchlist
     */
    function removeFromWatchlist(address _wallet) external {
        require(watchlists[msg.sender][_wallet].isActive, "Not in watchlist");
        
        watchlists[msg.sender][_wallet].isActive = false;
        totalWatchlists--;
        
        emit WalletRemoved(msg.sender, _wallet);
    }
    
    /**
     * @dev Update risk score (owner only)
     */
    function updateRiskScore(address _wallet, uint256 _score) external {
        require(msg.sender == owner, "Only owner");
        require(_score <= 100, "Score must be 0-100");
        
        riskScores[_wallet] = _score;
        totalRiskAssessments++;
        
        emit RiskScoreUpdated(_wallet, _score);
    }
    
    /**
     * @dev Get user's watchlist
     */
    function getUserWatchlist(address _user) external view returns (address[] memory) {
        return userWatchlists[_user];
    }
    
    /**
     * @dev Get watchlist entry
     */
    function getWatchlistEntry(address _user, address _wallet) 
        external 
        view 
        returns (WatchlistEntry memory) 
    {
        return watchlists[_user][_wallet];
    }
    
    /**
     * @dev Get risk score
     */
    function getRiskScore(address _wallet) external view returns (uint256) {
        return riskScores[_wallet];
    }
}
```

### Step 3: Compile
1. Click "Solidity Compiler" tab
2. Select compiler version: 0.8.20+
3. Click "Compile ChainSageMonitor.sol"

### Step 4: Add 0G Mainnet to MetaMask
1. Open MetaMask
2. Add Network:
   - Network Name: 0G Mainnet
   - RPC URL: https://evmrpc.0g.ai
   - Chain ID: 16661
   - Currency Symbol: 0G
   - Block Explorer: https://chainscan.0g.ai

### Step 5: Deploy
1. Click "Deploy & Run Transactions" tab
2. Environment: "Injected Provider - MetaMask"
3. Make sure MetaMask is on 0G Mainnet
4. Click "Deploy"
5. Confirm transaction in MetaMask
6. **SAVE THE CONTRACT ADDRESS!**

### Step 6: Verify
1. Go to https://chainscan.0g.ai
2. Search for your contract address
3. Contract should appear!

---

## Option 2: Use Hardhat (15 minutes)

### Step 1: Setup
```bash
cd contracts
npm init -y
npm install --save-dev hardhat @nomicfoundation/hardhat-toolbox
npx hardhat
# Select "Create an empty hardhat.config.js"
```

### Step 2: Create hardhat.config.js
```javascript
require("@nomicfoundation/hardhat-toolbox");

module.exports = {
  solidity: "0.8.20",
  networks: {
    zg: {
      url: "https://evmrpc.0g.ai",
      chainId: 16661,
      accounts: [process.env.PRIVATE_KEY]
    }
  }
};
```

### Step 3: Create Deploy Script
Create `scripts/deploy.js`:
```javascript
async function main() {
  const ChainSageMonitor = await ethers.getContractFactory("ChainSageMonitor");
  const monitor = await ChainSageMonitor.deploy();
  await monitor.deployed();
  
  console.log("ChainSageMonitor deployed to:", monitor.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
```

### Step 4: Deploy
```bash
# Set your private key
$env:PRIVATE_KEY="your_private_key_here"

# Deploy
npx hardhat run scripts/deploy.js --network zg
```

---

## 🎯 After Deployment

### Save This Info:
```
Contract Name: ChainSageMonitor
Contract Address: 0x... (from deployment)
Network: 0G Mainnet
Chain ID: 16661
Block Explorer: https://chainscan.0g.ai/address/0x...
Deployment Date: 2025-11-04
```

### Update README:
```markdown
## Smart Contracts

**Network:** 0G Mainnet (Chain ID: 16661)

**ChainSageMonitor Contract:**
- Address: `0x...`
- Explorer: https://chainscan.0g.ai/address/0x...
- Purpose: Watchlist management and risk scoring

### Features:
- Add/remove wallets from personal watchlist
- Track risk scores for monitored addresses
- On-chain storage of monitoring data
- Event-driven updates for real-time integration
```

---

## ✅ Success Criteria

You've successfully deployed when:
- [ ] Contract deployed to 0G mainnet
- [ ] Address saved
- [ ] Visible on https://chainscan.0g.ai
- [ ] Can call functions (test with addToWatchlist)
- [ ] README updated with address

---

## 🚀 Quick Win Strategy

**For WaveHack submission:**
1. Deploy this simple contract via Remix (5 min)
2. Save the address
3. Update README
4. Add to submission
5. **Score boost: +20 points!**

The contract is simple but functional and demonstrates:
- ✅ 0G mainnet deployment
- ✅ On-chain data storage
- ✅ Event-driven architecture
- ✅ Real monitoring functionality

**This meets the 40% deployment criteria!**

---

## 💡 Recommendation

**Use Remix (Option 1)** because:
- No installation needed
- Works on Windows easily
- 5 minutes to deploy
- Visual interface
- Immediate results

**Ready to deploy via Remix?** I'll walk you through it step by step! 🚀
