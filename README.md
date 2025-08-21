# ChainSage Smart Contracts

## Overview

ChainSage is a DeFi risk detection platform that provides real-time monitoring and alerts for blockchain threats. This repository contains the smart contracts that form the foundation of the platform.

## Smart Contract Architecture

### Core Contracts

#### 1. **ChainSageCore.sol**

The main coordination contract that handles:

- User registration and subscription management
- Risk event reporting and storage
- Role-based access control
- Platform fee collection and revenue management

**Key Functions:**

- `registerUser()` - Register as a new user
- `subscribe(uint256 months)` - Subscribe to the platform
- `reportRiskEvent()` - Report new risk events (analysts only)
- `getRiskEventsForTarget()` - Retrieve risk events for a specific address
- `hasActiveSubscription()` - Check user subscription status

#### 2. **RiskDetector.sol**

Handles risk scoring and monitoring:

- Multi-factor risk analysis (liquidity, contract, whale, market risks)
- Risk score storage and updates
- Watchlist management for high-risk addresses
- Threshold-based risk alerts

**Key Functions:**

- `updateRiskScore()` - Update risk score for a target address
- `getRiskScore()` - Retrieve current risk score
- `addToWatchlist()` - Add address to global watchlist
- `getTopRiskyAddresses()` - Get list of highest risk addresses

#### 3. **WatchlistManager.sol**

Manages user watchlists and alerts:

- Personal watchlist management
- Custom risk threshold settings
- Alert creation and management
- User notification preferences

**Key Functions:**

- `addToWatchlist()` - Add address to personal watchlist
- `removeFromWatchlist()` - Remove address from watchlist
- `createAlert()` - Create risk alert for user
- `markAlertAsRead()` - Mark alert as read

## Role-Based Access Control

### Roles

- **DEFAULT_ADMIN_ROLE**: Full administrative access
- **ADMIN_ROLE**: Platform administration functions
- **RISK_ANALYST_ROLE**: Risk event reporting and analysis
- **USER_ROLE**: Basic platform access

### Permission Matrix

| Function                | Admin | Analyst | User |
| ----------------------- | ----- | ------- | ---- |
| User Registration       | ❌    | ❌      | ✅   |
| Risk Reporting          | ❌    | ✅      | ❌   |
| Watchlist Management    | ❌    | ❌      | ✅   |
| Platform Administration | ✅    | ❌      | ❌   |

## Data Structures

### RiskEvent

```solidity
struct RiskEvent {
    uint256 id;
    address target;
    uint8 riskLevel;        // 0-100 scale
    string riskType;        // e.g., "RUG_PULL", "FLASH_LOAN_ATTACK"
    string description;
    string evidence;        // IPFS hash or similar
    address reporter;
    uint256 timestamp;
    bool isResolved;
}
```

### RiskScore

```solidity
struct RiskScore {
    uint8 overallScore;     // 0-100 overall risk
    uint8 liquidityRisk;    // Liquidity-related risks
    uint8 contractRisk;     // Smart contract vulnerabilities
    uint8 whaleRisk;        // Large holder manipulation risks
    uint8 marketRisk;       // Market manipulation risks
    uint256 lastUpdated;
    string analysis;
}
```

### UserProfile

```solidity
struct UserProfile {
    bool isRegistered;
    uint256 registrationDate;
    uint256 lastActive;
    uint256 riskEventsReported;
    uint256 subscriptionExpiry;
}
```

## Deployment

### Prerequisites

- Foundry installed
- Private key for deployment
- RPC endpoint for target network

### Environment Setup

```bash
# Set your private key
export PRIVATE_KEY=your_private_key_here

# Set RPC URL for target network
export RPC_URL=your_rpc_url_here
```

### Deploy Contracts

```bash
# Compile contracts
forge build

# Deploy to local network
forge script script/Deploy.s.sol --rpc-url $RPC_URL --broadcast

# Deploy to testnet
forge script script/Deploy.s.sol --rpc-url $RPC_URL --broadcast --verify
```

## Testing

### Run Tests

```bash
# Run all tests
forge test

# Run specific test
forge test --match-test testUserRegistration

# Run with verbose output
forge test -vvv
```

### Test Coverage

```bash
# Generate coverage report
forge coverage
```

## Integration Points

### 0g Network Integration

- Smart contracts emit events for 0g data indexing
- Risk scores and events stored on-chain for real-time access
- Event-driven architecture enables instant reactions to on-chain activities

### External Systems

- **Frontend**: Reads contract state and events for real-time updates
- **Backend**: Processes blockchain data and updates risk scores
- **AI Models**: Provide risk analysis results stored on-chain
- **Notification Services**: Triggered by smart contract events

## Gas Optimization

### Storage Optimization

- Use packed structs where possible
- Efficient array management for watchlists
- Event-based data for off-chain processing

### Computation Optimization

- Batch operations for multiple updates
- Efficient loops and array operations
- Minimal on-chain computation

## Security Features

### Access Control

- Role-based permissions for all critical functions
- Pausable functionality for emergency situations
- Admin-only functions for platform management

### Input Validation

- Address validation for all external inputs
- Risk score bounds checking (0-100)
- String length validation for descriptions

### Reentrancy Protection

- NonReentrant modifier on payable functions
- Secure state management patterns

## Upgradeability

### Proxy Pattern

- Contracts designed for future upgradeability
- State separation for upgrade safety
- Admin-controlled upgrade mechanisms

## Network Support

### Current Support

- Ethereum Mainnet
- Ethereum Testnets (Sepolia, Goerli)
- Local Development Networks

### Future Support

- Layer 2 Networks (Polygon, Arbitrum, Optimism)
- Cross-chain Risk Monitoring
- Multi-chain Data Aggregation

## Contributing

### Development Workflow

1. Fork the repository
2. Create feature branch
3. Implement changes with tests
4. Submit pull request

### Code Standards

- Solidity 0.8.20+
- OpenZeppelin contracts for security
- Comprehensive test coverage
- Gas optimization considerations

## License

MIT License - see LICENSE file for details

## Support

For technical support or questions:

- Create an issue in this repository
- Contact the ChainSage team
- Join our community channels

---

**Built with ❤️ by the ChainSage Team**
