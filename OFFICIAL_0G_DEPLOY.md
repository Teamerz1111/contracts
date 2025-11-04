# Official 0G Mainnet Deployment Guide
## Based on 0G Documentation: https://docs.0g.ai/

---

## ✅ Network Configuration (From Official Docs)

### 0G Mainnet
```
Network Name: 0G Mainnet
RPC URL: https://evmrpc.0g.ai
Chain ID: 16661
Currency Symbol: 0G
Block Explorer: https://chainscan.0g.ai
```

### 0G Testnet (Galileo) - For Testing First
```
Network Name: 0G Testnet
RPC URL: https://evmrpc-testnet.0g.ai
Chain ID: 16602
Currency Symbol: A0GI
Block Explorer: https://chainscan-galileo.0g.ai
Faucet: https://faucet.0g.ai
```

---

## 🚀 Deployment Method 1: Hardhat (RECOMMENDED)

### Step 1: Install Hardhat
```bash
cd contracts
npm install --save-dev hardhat @nomicfoundation/hardhat-toolbox
npx hardhat
# Select "Create an empty hardhat.config.js"
```

### Step 2: Create hardhat.config.js
```javascript
require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

module.exports = {
  solidity: {
    version: "0.8.20",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  networks: {
    "0g-testnet": {
      url: "https://evmrpc-testnet.0g.ai",
      chainId: 16602,
      accounts: [process.env.PRIVATE_KEY]
    },
    "0g-mainnet": {
      url: "https://evmrpc.0g.ai",
      chainId: 16661,
      accounts: [process.env.PRIVATE_KEY]
    }
  }
};
```

### Step 3: Create .env File
```bash
PRIVATE_KEY=your_private_key_here_without_0x_prefix
```

### Step 4: Create Deploy Script
Create `scripts/deploy.js`:
```javascript
async function main() {
  console.log("Deploying ChainSageMonitor...");
  
  const ChainSageMonitor = await ethers.getContractFactory("ChainSageMonitor");
  const monitor = await ChainSageMonitor.deploy();
  
  await monitor.waitForDeployment();
  const address = await monitor.getAddress();
  
  console.log("ChainSageMonitor deployed to:", address);
  console.log("Block Explorer:", `https://chainscan.0g.ai/address/${address}`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
```

### Step 5: Copy Contract to Hardhat
```bash
# Copy our contract to Hardhat contracts folder
mkdir -p contracts
cp ChainSageMonitor.sol contracts/
```

### Step 6: Deploy to Testnet First (Test)
```bash
npx hardhat run scripts/deploy.js --network 0g-testnet
```

### Step 7: Deploy to Mainnet
```bash
npx hardhat run scripts/deploy.js --network 0g-mainnet
```

---

## 🔨 Deployment Method 2: Foundry (If Installed)

### Step 1: Install Foundry
```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

### Step 2: Update foundry.toml
```toml
[profile.default]
src = "src"
out = "out"
libs = ["lib"]

[rpc_endpoints]
0g_testnet = "https://evmrpc-testnet.0g.ai"
0g_mainnet = "https://evmrpc.0g.ai"
```

### Step 3: Deploy with Foundry
**IMPORTANT: Use `--evm-version cancun` flag (from official docs)**

```bash
# Deploy to mainnet
forge create --rpc-url https://evmrpc.0g.ai \
  --private-key $PRIVATE_KEY \
  --evm-version cancun \
  ChainSageMonitor.sol:ChainSageMonitor

# Or using the alias
forge create --rpc-url 0g_mainnet \
  --private-key $PRIVATE_KEY \
  --evm-version cancun \
  ChainSageMonitor.sol:ChainSageMonitor
```

---

## 🌐 Deployment Method 3: Remix (EASIEST)

### Step 1: Open Remix
https://remix.ethereum.org

### Step 2: Create Contract File
1. Click "+" to create new file
2. Name: `ChainSageMonitor.sol`
3. Paste contract code from `ChainSageMonitor.sol`

### Step 3: Compile
1. Go to "Solidity Compiler" tab
2. Select version: 0.8.20
3. Click "Compile ChainSageMonitor.sol"

### Step 4: Add 0G Mainnet to MetaMask
**Network Settings:**
- Network Name: 0G Mainnet
- RPC URL: https://evmrpc.0g.ai
- Chain ID: 16661
- Currency Symbol: 0G
- Block Explorer: https://chainscan.0g.ai

### Step 5: Deploy
1. Go to "Deploy & Run Transactions" tab
2. Environment: "Injected Provider - MetaMask"
3. Ensure MetaMask is on "0G Mainnet"
4. Click "Deploy"
5. Confirm in MetaMask

---

## ✅ Verification Steps

### 1. Check Deployment
After deployment, you'll get a contract address like:
```
0x1234567890abcdef1234567890abcdef12345678
```

### 2. Verify on Block Explorer
Visit: https://chainscan.0g.ai/address/YOUR_CONTRACT_ADDRESS

You should see:
- Contract creation transaction
- Contract code
- Transaction history

### 3. Test Contract Interaction
Using Remix or Hardhat console:
```javascript
// Test addToWatchlist function
await contract.addToWatchlist(
  "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb",
  "Test Wallet"
);

// Check stats
const stats = await contract.getPlatformStats();
console.log("Users:", stats.users.toString());
console.log("Watchlists:", stats.watchlists.toString());
```

---

## 🐛 Troubleshooting (From Official Docs)

### Error: "insufficient funds"
**Solution:** Get 0G tokens from:
- Mainnet: Bridge from another chain
- Testnet: https://faucet.0g.ai

### Error: "invalid chain id"
**Solution:** Double-check:
- Mainnet Chain ID: 16661
- Testnet Chain ID: 16602

### Error: "nonce too low"
**Solution:** 
```bash
# Check current nonce
cast nonce YOUR_ADDRESS --rpc-url https://evmrpc.0g.ai

# Or reset MetaMask: Settings → Advanced → Reset Account
```

### Error: "execution reverted"
**Solution:** Check:
- Contract compiles without errors
- Constructor parameters are correct
- You have enough gas

### For Foundry: Use `--evm-version cancun`
**This is CRITICAL per official docs!**

---

## 📋 Post-Deployment Checklist

- [ ] Contract deployed successfully
- [ ] Contract address saved
- [ ] Verified on https://chainscan.0g.ai
- [ ] Test transaction successful
- [ ] README updated with contract address
- [ ] WaveHack submission updated

---

## 📚 Official Resources

- **Deployment Guide:** https://docs.0g.ai/developer-hub/building-on-0g/contracts-on-0g/deploy-contracts
- **Network Details:** https://docs.0g.ai/developer-hub/testnet/testnet-overview
- **Block Explorer:** https://chainscan.0g.ai
- **Faucet (Testnet):** https://faucet.0g.ai
- **Official Examples:** https://github.com/0gfoundation/0g-deployment-scripts

---

## 🎯 Recommended Approach

**For WaveHack Submission:**

1. **Use Hardhat** (most reliable on Windows)
2. **Test on testnet first** (free tokens from faucet)
3. **Deploy to mainnet** once tested
4. **Verify on block explorer**
5. **Update documentation**

**Estimated Time:** 20-30 minutes

---

## 💡 Quick Start Commands

```bash
# Setup
cd contracts
npm install --save-dev hardhat @nomicfoundation/hardhat-toolbox dotenv
npx hardhat

# Create config (use code above)
# Create .env with your private key
# Create deploy script (use code above)

# Deploy to testnet (test first!)
npx hardhat run scripts/deploy.js --network 0g-testnet

# Deploy to mainnet
npx hardhat run scripts/deploy.js --network 0g-mainnet
```

**Save the contract address and you're done!** 🚀
