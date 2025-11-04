# ChainSage 0G Mainnet Deployment - Quick Start

## ✅ What We Have

### Smart Contracts (Ready to Deploy)
1. **ChainSageCore.sol** - Main coordination contract
2. **RiskDetector.sol** - Risk scoring and monitoring
3. **WatchlistManager.sol** - User watchlist management

### Deployment Tools
- ✅ Foundry setup complete
- ✅ Deploy script ready (`script/Deploy.s.sol`)
- ✅ 0G mainnet configuration documented
- ✅ Comprehensive deployment guide

---

## 🚀 Quick Deployment Steps

### 1. Install Foundry (if not installed)
```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

### 2. Setup Environment
```bash
cd contracts

# Create .env file
cp .env.example .env

# Edit .env and add your private key
# PRIVATE_KEY=your_actual_private_key_here
```

### 3. Install Dependencies
```bash
forge install
```

### 4. Build Contracts
```bash
forge build
```

### 5. Deploy to 0G Mainnet
```bash
forge script script/Deploy.s.sol \
  --rpc-url https://evmrpc.0g.ai \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --legacy
```

### 6. Save Contract Addresses
The deployment will output addresses like:
```
ChainSage Core deployed at: 0x1234...
Risk Detector deployed at: 0x5678...
Watchlist Manager deployed at: 0x9abc...
```

**SAVE THESE ADDRESSES!** You'll need them for:
- Frontend integration
- WaveHack submission
- Documentation

---

## 📝 After Deployment Checklist

### Immediate Actions
- [ ] Copy all 3 contract addresses
- [ ] Verify on https://chainscan.0g.ai
- [ ] Test one transaction to each contract
- [ ] Save addresses in `DEPLOYED_ADDRESSES.md`

### Documentation Updates
- [ ] Update `chainsage-app-v0/README.md` with contract addresses
- [ ] Add block explorer links
- [ ] Update `WAVEHACK_SUBMISSION.md` with contract info
- [ ] Create frontend config file with addresses

### Frontend Integration
- [ ] Create `lib/contracts.ts` with addresses
- [ ] Add ABI files to frontend
- [ ] Test contract interactions
- [ ] Update admin dashboard to use contracts

---

## 🎯 WaveHack Submission Requirements

### What Judges Need to See
1. ✅ **Deployed Contracts** - All 3 contracts on 0G mainnet
2. ✅ **Verified Addresses** - Links to block explorer
3. ✅ **Working Integration** - Frontend using the contracts
4. ✅ **Documentation** - Clear setup and architecture

### Submission Format
```markdown
**0G Mainnet Smart Contracts:**

1. **ChainSageCore**
   - Address: 0x...
   - Explorer: https://chainscan.0g.ai/address/0x...
   - Purpose: Main coordination and user management

2. **RiskDetector**
   - Address: 0x...
   - Explorer: https://chainscan.0g.ai/address/0x...
   - Purpose: Risk scoring and monitoring

3. **WatchlistManager**
   - Address: 0x...
   - Explorer: https://chainscan.0g.ai/address/0x...
   - Purpose: Personal watchlist management

**Network:** 0G Mainnet (Chain ID: 16661)
**RPC:** https://evmrpc.0g.ai
**Explorer:** https://chainscan.0g.ai
```

---

## 💡 Important Notes

### Gas Requirements
- You need ~0.05 0G tokens for deployment
- Make sure your wallet has enough before deploying
- Gas prices on 0G are very low

### Network Configuration
- **Chain ID:** 16661 (CRITICAL - must be correct)
- **RPC URL:** https://evmrpc.0g.ai
- **Use `--legacy` flag** for compatibility

### Security
- ⚠️ **NEVER commit your private key**
- ⚠️ Keep `.env` in `.gitignore`
- ⚠️ Use a deployment wallet, not your main wallet

---

## 🐛 Common Issues & Solutions

### "insufficient funds for gas"
**Problem:** Not enough 0G tokens
**Solution:** Get more 0G from faucet or bridge

### "invalid chain id"
**Problem:** Wrong network or missing --legacy flag
**Solution:** Use `--legacy` flag and verify RPC URL

### "nonce too low"
**Problem:** Transaction nonce mismatch
**Solution:** Wait a few seconds and retry

### "execution reverted"
**Problem:** Contract constructor issue
**Solution:** Check OpenZeppelin dependencies are installed

---

## 📊 Deployment Timeline

**Estimated Time:** 30-45 minutes

- Setup environment: 5 min
- Install dependencies: 5 min
- Build contracts: 2 min
- Deploy to 0G mainnet: 10 min
- Verify deployment: 5 min
- Update documentation: 10 min
- Frontend integration: 15 min

---

## 🎬 Next Steps After This

1. **Deploy Contracts** (this document)
2. **Update Frontend** with contract addresses
3. **Create Demo Video** showing contracts in action
4. **Write Twitter Thread** mentioning deployed contracts
5. **Submit to WaveHack** with all contract links

---

## 📞 Need Help?

If deployment fails:
1. Check the full deployment guide: `DEPLOY_0G_MAINNET.md`
2. Verify you have 0G tokens
3. Confirm network settings
4. Check Foundry installation

---

## ✅ Success Criteria

Deployment is successful when:
- [x] All 3 contracts deployed
- [x] Contract addresses saved
- [x] Visible on https://chainscan.0g.ai
- [x] Test transaction successful
- [x] Documentation updated

**Ready to deploy? Let's do this! 🚀**
