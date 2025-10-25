# Manual Contract Verification Guide

## Deployment Information

- **Contract Address**: `0xED9cc4E9aD33CF6dA4D24e715d6a0C51EB4B98BD`
- **Network**: Base Sepolia Testnet
- **Chain ID**: 84532
- **Admin Address**: `0xeD6c9f2573343043DD443bc633f9071ABDF688Fd`
- **Explorer**: https://sepolia.basescan.org/address/0xED9cc4E9aD33CF6dA4D24e715d6a0C51EB4B98BD

## Option 1: Wait and Retry (Recommended)

The API key has been rate-limited. Wait 10-15 minutes and try again:

```bash
forge verify-contract \
    0xED9cc4E9aD33CF6dA4D24e715d6a0C51EB4B98BD \
    src/WalkScapeCore.sol:WalkScapeCore \
    --chain-id 84532 \
    --constructor-args $(cast abi-encode "constructor(address)" 0xeD6c9f2573343043DD443bc633f9071ABDF688Fd) \
    --etherscan-api-key $BASESCAN_API_KEY \
    --watch
```

## Option 2: Verify via Basescan UI

1. Go to: https://sepolia.basescan.org/address/0xED9cc4E9aD33CF6dA4D24e715d6a0C51EB4B98BD#code

2. Click "Verify and Publish"

3. Enter the following details:
   - **Compiler Type**: Solidity (Single file)
   - **Compiler Version**: v0.8.20+commit.a1b79de6
   - **Open Source License Type**: MIT
   - **Optimization**: Yes
   - **Runs**: 200
   - **EVM Version**: shanghai

4. In "Enter the Solidity Contract Code" section:
   - You'll need to flatten the contract first:
   
   ```bash
   forge flatten src/WalkScapeCore.sol > WalkScapeCore_flat.sol
   ```
   
   - Then paste the contents of `WalkScapeCore_flat.sol`

5. **Constructor Arguments ABI-encoded**:
   ```
   000000000000000000000000ed6c9f2573343043dd443bc633f9071abdf688fd
   ```

## Option 3: Get a New API Key

1. Visit: https://basescan.org/myapikey
2. Create a new API key
3. Update your `.env` file with the new key:
   ```bash
   BASESCAN_API_KEY=your_new_api_key
   ```
4. Wait a few minutes and retry the forge verify command

## Option 4: Verify Using Foundry Script

Create a verification script:

```bash
forge script script/Deploy.s.sol:DeployWalkScapeCore \
    --rpc-url https://sepolia.base.org \
    --verify \
    --etherscan-api-key $BASESCAN_API_KEY \
    --resume
```

## Verification Status Check

Once verified, you can check the contract on Basescan:
- Contract: https://sepolia.basescan.org/address/0xED9cc4E9aD33CF6dA4D24e715d6a0C51EB4B98BD
- Transactions: https://sepolia.basescan.org/address/0xED9cc4E9aD33CF6dA4D24e715d6a0C51EB4B98BD#transactions

## Frontend Integration

Update your frontend `.env` file with:

```bash
NEXT_PUBLIC_CONTRACT_ADDRESS=0xED9cc4E9aD33CF6dA4D24e715d6a0C51EB4B98BD
NEXT_PUBLIC_RPC_URL=https://sepolia.base.org
NEXT_PUBLIC_CHAIN_ID=84532
NEXT_PUBLIC_ADMIN_ADDRESS=0xeD6c9f2573343043DD443bc633f9071ABDF688Fd
```

## Testing the Deployment

You can interact with your deployed contract using cast:

```bash
# Check owner
cast call 0xED9cc4E9aD33CF6dA4D24e715d6a0C51EB4B98BD "owner()" --rpc-url https://sepolia.base.org

# Check artifact counter
cast call 0xED9cc4E9aD33CF6dA4D24e715d6a0C51EB4B98BD "artifactCounter()" --rpc-url https://sepolia.base.org

# Check pet counter
cast call 0xED9cc4E9aD33CF6dA4D24e715d6a0C51EB4B98BD "petCounter()" --rpc-url https://sepolia.base.org
```

## Notes

- The contract is deployed and working, verification is just for making the source code public on the explorer
- You can interact with the contract even without verification
- The verification can be done later when the rate limit is lifted
