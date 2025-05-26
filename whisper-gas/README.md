# Shadow Gas Network

> Invisible gas fees, seamless transactions - A comprehensive gasless transaction system for the Stacks blockchain

## 🌟 Overview

Shadow Gas Network enables gasless transactions on the Stacks blockchain through a sophisticated meta-transaction system. Users can execute smart contract functions without holding STX tokens for gas fees, while sponsors fund transaction costs through a decentralized relay network.

## ✨ Key Features

- **🚫 No Gas Required**: Users execute transactions without STX tokens
- **🤝 Sponsor Network**: Decentralized system where sponsors pay gas fees
- **🔐 Secure Meta-Transactions**: Cryptographic signature verification
- **⚡ Batch Processing**: Execute multiple transactions efficiently
- **🛡️ Replay Protection**: Nonce-based security against duplicate transactions
- **⏰ Expiry Control**: Time-limited transactions prevent stale executions
- **📊 Gas Tracking**: Comprehensive usage analytics and monitoring

## 🏗️ Architecture

### Core Components

1. **Sponsor Management System**
   - Sponsor registration and deposits
   - Balance tracking and withdrawals
   - Minimum balance requirements

2. **Meta-Transaction Engine**
   - Signature verification
   - Nonce management
   - Gas estimation and deduction

3. **Security Layer**
   - Replay attack prevention
   - Expiry timestamp validation
   - Input sanitization

4. **Administrative Controls**
   - Contract enable/disable functionality
   - Emergency withdrawal mechanisms
   - Parameter configuration

## 🚀 Getting Started

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) CLI tool
- [Stacks Blockchain](https://stacks.co/) testnet access
- Basic understanding of Clarity smart contracts

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/phantom-relay-stacks.git
cd phantom-relay-stacks
```

2. Initialize Clarinet project:
```bash
clarinet new phantom-relay
cd phantom-relay
```

3. Add the contract:
```bash
cp ../contracts/phantom-executor.clar contracts/
```

4. Update `Clarinet.toml`:
```toml
[contracts.phantom-executor]
path = "contracts/phantom-executor.clar"
```

### Testing

Run comprehensive tests:
```bash
clarinet test
```

Check contract syntax:
```bash
clarinet check
```

## 📖 Usage Guide

### For Sponsors

#### 1. Register as a Sponsor
```clarity
(contract-call? .phantom-executor register-sponsor u5000000) ;; 5 STX initial deposit
```

#### 2. Add Funds to Sponsor Account
```clarity
(contract-call? .phantom-executor sponsor-deposit u2000000) ;; 2 STX additional
```

#### 3. Execute Gasless Transaction for User
```clarity
(contract-call? .phantom-executor execute-gasless-tx
  'SP1234...USER-PRINCIPAL
  "transfer-token"
  (list u1000 u567)
  u0  ;; nonce
  u1000  ;; expiry block
  u25000  ;; gas limit
  0x1234...signature)
```

### For Users

#### 1. Generate Transaction Signature
```javascript
// Off-chain signature generation (simplified)
const message = {
  user: userPrincipal,
  functionName: "transfer-token",
  args: [1000, 567],
  nonce: 0,
  expiry: blockHeight + 100
};
const signature = signMessage(message, userPrivateKey);
```

#### 2. Submit to Sponsor or Relay Service
Users submit signed transaction data to sponsors or relay services for execution.

### Batch Transactions

Execute multiple gasless transactions:
```clarity
(contract-call? .phantom-executor execute-batch-gasless-tx
  (list 
    {user: 'SP123..., function-name: "action1", args: (list u100), nonce: u0, expiry: u1000, gas-limit: u20000, signature: 0x...}
    {user: 'SP456..., function-name: "action2", args: (list u200), nonce: u1, expiry: u1000, gas-limit: u25000, signature: 0x...}
  ))
```

## 🔍 Contract Functions

### Public Functions

| Function | Description | Parameters |
|----------|-------------|------------|
| `register-sponsor` | Register as transaction sponsor | `initial-deposit: uint` |
| `sponsor-deposit` | Add funds to sponsor balance | `amount: uint` |
| `sponsor-withdraw` | Withdraw sponsor funds | `amount: uint` |
| `execute-gasless-tx` | Execute single gasless transaction | `user, function-name, args, nonce, expiry, gas-limit, signature` |
| `execute-batch-gasless-tx` | Execute multiple gasless transactions | `transactions: list` |

### Read-Only Functions

| Function | Description | Returns |
|----------|-------------|---------|
| `get-sponsor-balance` | Get sponsor's current balance | `uint` |
| `get-user-nonce` | Get user's current nonce | `uint` |
| `get-gas-usage` | Get total gas used by user | `uint` |
| `is-transaction-executed` | Check if transaction was executed | `bool` |

### Admin Functions

| Function | Description | Access |
|----------|-------------|--------|
| `set-contract-enabled` | Enable/disable contract | Owner only |
| `set-min-sponsor-balance` | Set minimum sponsor balance | Owner only |
| `emergency-withdraw` | Emergency fund withdrawal | Owner only |

## 🛡️ Security Features

- **Signature Verification**: Ensures transaction authenticity
- **Nonce Management**: Prevents replay attacks
- **Expiry Timestamps**: Blocks stale transactions
- **Input Validation**: Sanitizes all user inputs
- **Balance Checks**: Verifies sufficient sponsor funds
- **Access Controls**: Admin-only critical functions

## 🔧 Configuration

### Default Settings

```clarity
min-sponsor-balance: 1,000,000 micro-STX (1 STX)
max-gas-limit: 50,000 units
contract-enabled: true
```

### Customization

Administrators can modify settings through admin functions:
- Adjust minimum sponsor balance requirements
- Update maximum gas limits
- Enable/disable contract functionality

## 🚦 Error Codes

| Code | Constant | Description |
|------|----------|-------------|
| u100 | `ERR-UNAUTHORIZED` | Insufficient permissions |
| u101 | `ERR-INSUFFICIENT-FUNDS` | Inadequate balance |
| u102 | `ERR-INVALID-SIGNATURE` | Signature verification failed |
| u103 | `ERR-NONCE-USED` | Nonce already consumed |
| u104 | `ERR-EXPIRED` | Transaction past expiry |
| u105 | `ERR-INVALID-SPONSOR` | Sponsor not registered |

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines

- Follow Clarity best practices
- Add comprehensive tests for new features
- Update documentation for API changes
- Ensure all security checks pass

## 🙏 Acknowledgments

- [Stacks Foundation](https://stacks.org/) for blockchain infrastructure
- [Clarity Language](https://clarity-lang.org/) for smart contract capabilities
- Community contributors and testers

**Built with ❤️ for the Stacks ecosystem**