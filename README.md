# 🌐 StakingApp

A simple staking dApp built with **Solidity** and **Foundry**, that allows users to stake a fixed amount of ERC20 tokens and earn periodic rewards in ETH.  
The project includes:
- ✅ A staking smart contract  
- ✅ A custom ERC20 token  
- ✅ Unit tests with Foundry  

---

## ✨ Features

- 🔹 **Custom ERC20 Token (`StakingToken`)**
  - Deployable ERC20 token with a `mint` function for testing.

- 🔹 **Staking Contract (`StakingApp`)**
  - Stake a fixed token amount.
  - Earn ETH rewards per staking period.
  - Owner can change staking period and deposit ETH for rewards.
  - Users can deposit, withdraw, and claim rewards.

- 🔹 **Tests**
  - Built with Foundry (`forge-std/Test.sol`).
  - Includes token minting and contract deployment validation.

---

## 📂 Project Structure

```text
├── src/
│   ├── StakingApp.sol        # Main staking contract
│   └── StakingToken.sol      # ERC20 token for staking
├── test/
│   ├── StakingAppTest.t.sol  # Tests for staking contract
│   └── StakingTokenTest.t.sol# Tests for token
```

---

## ⚙️ Contracts Overview

### 📌 StakingToken.sol
- Extends OpenZeppelin’s `ERC20`.
- Includes a `mint` function for testing and distribution.

### 📌 StakingApp.sol
- Main logic for staking.  
- **Key functions:**
  - `depositTokenks(uint256 amount)` → Stake tokens.
  - `withdrawTokens()` → Withdraw staked tokens.
  - `claimRewards()` → Claim ETH rewards after staking period.
  - `channgeStakingPeriod(uint256 newPeriod)` → Update staking period (only owner).

---

## 🚀 Getting Started

### 🔧 Prerequisites
- [Foundry](https://book.getfoundry.sh/getting-started/installation) installed.

### 📥 Install dependencies
```bash
forge install
```

### 🛠 Build project
```bash
forge build
```

### 🧪 Run tests
```bash
forge test
```

---

## 📖 Usage

1. **Deploy `StakingToken`**
   ```solidity
   StakingToken stakingToken = new StakingToken("Staking Token", "STK");
   ```

2. **Deploy `StakingApp`**
   ```solidity
   StakingApp stakingApp = new StakingApp(
       address(stakingToken),
       owner,
       stakingPeriod,
       fixedStakingAmount,
       rewardPerPeriod
   );
   ```

3. **Fund the contract with ETH**  
   The owner can send ETH to the contract (via `receive()`) to cover staking rewards.

4. **Stake tokens**
   - Approve the staking contract to spend tokens.
   - Call `depositTokenks(fixedStakingAmount)`.

5. **Claim rewards & withdraw**
   - After the staking period → `claimRewards()`.
   - To exit → `withdrawTokens()`.

---

## 🧪 Tests

- **`StakingTokenTest.t.sol`**
  - Validates ERC20 deployment and minting.
- **`StakingAppTest.t.sol`**
  - Ensures contracts are deployed correctly.

Run with:
```bash
forge test -vv
```

---

## 📜 License

This project is licensed under the **MIT License**.  
Feel free to use, modify, and distribute it.  


