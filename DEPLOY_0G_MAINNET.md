# Deploy ChainSage Contracts to 0G Mainnet

## 🎯 Objective
Deploy ChainSageCore, RiskDetector, and WatchlistManager contracts to 0G Mainnet for WaveHack 5th Wave submission.

---

## 📋 Prerequisites

### 1. Install Foundry
```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

### 2. Verify Installation
```bash
forge --version
cast --version
```

### 3. Get 0G Tokens
- You need 0G tokens for gas fees
- Get from 0G faucet or bridge
- Recommended: 0.1 0G for deployment

---

## 🌐 0G Mainnet Configuration

### Network Details
```
Network Name: 0G Mainnet
Chain ID: 16661
RPC URL: https://evmrpc.0g.ai
Block Explorer: https://chainscan.0g.ai
Token Symbol: 0G
```

### Add to MetaMask
1. Open MetaMask
2. Add Network Manually
3. Enter details above
4. Save

---

## 🔑 Setup Environment Variables

### 1. Create .env file
```bash
cd contracts
cp .env.example .env
```

### 2. Edit .env file
```env
# Your private key (DO NOT COMMIT THIS!)
PRIVATE_KEY=your_private_key_here

# 0G Mainnet RPC
RPC_URL=https://evmrpc.0g.ai

# Chain ID
CHAIN_ID=16661

# Block Explorer API (for verification)
ETHERSCAN_API_KEY=not_needed_for_0g
```

### 3. Load environment
```bash
source .env
```

---

## 🔨 Build Contracts

### 1. Install Dependencies
```bash
forge install
```

### 2. Compile Contracts
```bash
forge build
```

### 3. Run Tests (Optional but recommended)
```bash
forge test
```

Expected output: All tests passing ✅

---

## 🚀 Deploy to 0G Mainnet

### Option 1: Using Forge Script (Recommended)

```bash
# Deploy all contracts
forge script script/Deploy.s.sol \
  --rpc-url https://evmrpc.0g.ai \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --legacy

# Note: Use --legacy flag for 0G mainnet compatibility
```

### Option 2: Manual Deployment

```bash
# Deploy ChainSageCore
forge create src/ChainSageCore.sol:ChainSageCore \
  --rpc-url https://evmrpc.0g.ai \
  --private-key $PRIVATE_KEY \
  --legacy

# Deploy RiskDetector
forge create src/RiskDetector.sol:RiskDetector \
  --rpc-url https://evmrpc.0g.ai \
  --private-key $PRIVATE_KEY \
  --legacy

# Deploy WatchlistManager
forge create src/WatchlistManager.sol:WatchlistManager \
  --rpc-url https://evmrpc.0g.ai \
  --private-key $PRIVATE_KEY \
  --legacy
```

---

## ✅ Verify Deployment

### 1. Check Contract Addresses
After deployment, you'll see output like:
```
ChainSage Core deployed at: 0x1234...
Risk Detector deployed at: 0x5678...
Watchlist Manager deployed at: 0x9abc...
```

### 2. Verify on Block Explorer
Visit: https://chainscan.0g.ai

Search for each contract address to confirm deployment.

### 3. Test Contract Interaction
```bash
# Check ChainSageCore
cast call <CORE_ADDRESS> "subscriptionPrice()" --rpc-url https://evmrpc.0g.ai

# Should return: 10000000000000000 (0.01 ETH in wei)
```

---

## 📝 Update Documentation

### 1. Save Contract Addresses
Create `DEPLOYED_ADDRESSES.md`:
```markdown
# ChainSage Deployed Contracts (0G Mainnet)

**Network:** 0G Mainnet (Chain ID: 16661)
**Deployment Date:** 2025-11-04
**Deployer:** 0x...

## Contract Addresses

### ChainSageCore
- **Address:** 0x...
- **Explorer:** https://chainscan.0g.ai/address/0x...
- **Purpose:** Main coordination contract

### RiskDetector
- **Address:** 0x...
- **Explorer:** https://chainscan.0g.ai/address/0x...
- **Purpose:** Risk scoring and monitoring

### WatchlistManager
- **Address:** 0x...
- **Explorer:** https://chainscan.0g.ai/address/0x...
- **Purpose:** User watchlist management
```

### 2. Update Frontend
Add contract addresses to frontend config:
```typescript
// lib/contracts.ts
export const CONTRACTS = {
  CHAINSAGE_CORE: '0x...',
  RISK_DETECTOR: '0x...',
  WATCHLIST_MANAGER: '0x...',
}

export const NETWORK = {
  chainId: 16661,
  name: '0G Mainnet',
  rpcUrl: 'https://evmrpc.0g.ai',
  blockExplorer: 'https://chainscan.0g.ai',
}
```

### 3. Update README.md
Add deployment section:
```markdown
## 📦 Smart Contracts

**Network:** 0G Mainnet (Chain ID: 16661)

### Deployed Contracts
- **ChainSageCore:** [0x...](https://chainscan.0g.ai/address/0x...)
- **RiskDetector:** [0x...](https://chainscan.0g.ai/address/0x...)
- **WatchlistManager:** [0x...](https://chainscan.0g.ai/address/0x...)

### Verify Contracts
All contracts are verified on [0G Block Explorer](https://chainscan.0g.ai)
```

---

## 🐛 Troubleshooting

### Issue: "insufficient funds for gas"
**Solution:** Add more 0G tokens to your wallet

### Issue: "nonce too low"
**Solution:** 
```bash
# Reset nonce
cast nonce <YOUR_ADDRESS> --rpc-url https://evmrpc.0g.ai
```

### Issue: "execution reverted"
**Solution:** Check contract constructor parameters and dependencies

### Issue: "invalid chain id"
**Solution:** Ensure you're using `--legacy` flag and correct RPC URL

---

## 📊 Gas Estimates

Estimated gas costs for deployment:
- **ChainSageCore:** ~2,000,000 gas
- **RiskDetector:** ~2,500,000 gas
- **WatchlistManager:** ~3,000,000 gas
- **Total:** ~7,500,000 gas

At current 0G prices: ~0.01-0.05 0G total

---

## 🔒 Security Checklist

Before deployment:
- [ ] Private key is secure and not committed
- [ ] Contracts compiled without errors
- [ ] Tests passing
- [ ] Sufficient 0G tokens for gas
- [ ] Correct network (Chain ID: 16661)
- [ ] Deployer address has admin rights

After deployment:
- [ ] Contract addresses saved
- [ ] Verified on block explorer
- [ ] Test transactions successful
- [ ] Documentation updated
- [ ] Frontend config updated

---

## 📚 Additional Resources

- **0G Documentation:** https://docs.0g.ai/
- **0G Block Explorer:** https://chainscan.0g.ai
- **0G RPC Endpoint:** https://evmrpc.0g.ai
- **Foundry Book:** https://book.getfoundry.sh/

---

## 🎯 Next Steps After Deployment

1. ✅ Save all contract addresses
2. ✅ Verify contracts on block explorer
3. ✅ Update frontend configuration
4. ✅ Update README with contract links
5. ✅ Test contract interactions
6. ✅ Add to WaveHack submission

---

**Deployment Checklist for WaveHack:**
- [ ] All 3 contracts deployed to 0G mainnet
- [ ] Contract addresses documented
- [ ] Block explorer links added to README
- [ ] Frontend updated with contract addresses
- [ ] Contracts tested and working
- [ ] Ready for submission! 🚀
