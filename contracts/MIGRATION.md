# Migration from Morph to Base Sepolia

## Summary

The WalkScape contracts have been migrated from Morph Holesky network to Base Sepolia testnet.

## Changes Made

### 1. Network Configuration
- **Old Network**: Morph Holesky Testnet (Chain ID: 2810)
- **New Network**: Base Sepolia Testnet (Chain ID: 84532)
- **Old RPC**: `https://rpc-holesky.morphl2.io`
- **New RPC**: `https://sepolia.base.org`
- **Old Explorer**: `https://explorer-holesky.morphl2.io`
- **New Explorer**: `https://sepolia.basescan.org`

### 2. Files Updated

#### Renamed Files
- `deploy_morph.sh` → `deploy_base.sh`
- `verify_morph_config.sh` → `verify_base_config.sh`

#### Modified Files
- **foundry.toml**: Updated RPC endpoints from `morph_holesky_testnet` to `base_sepolia`
- **Makefile**: 
  - Changed default network from `morph-holesky` to `base-sepolia`
  - Updated all make targets (`make base-sepolia` instead of `make morph-holesky`)
  - Updated help text and examples
- **README.md**: 
  - Updated all references to Base Sepolia
  - Changed network configuration details
  - Updated deployment commands and examples
- **deployment_info.json**: Cleared old deployment data and set Base Sepolia defaults
- **deploy_base.sh**: 
  - Updated for Base Sepolia deployment
  - Changed environment variable from `MORPH_HOLESKY_RPC_URL` to `BASE_SEPOLIA_RPC_URL`
  - Changed API key from `MORPH_API_KEY` to `BASESCAN_API_KEY`
- **verify_base_config.sh**: Updated verification script for Base Sepolia

#### New Files
- **.env.example**: Created with Base Sepolia configuration template

#### Removed
- Old broadcast data: `broadcast/Deploy.s.sol/2810/` (Morph chain ID folder)

### 3. Environment Variables

#### Old Variables
```bash
PRIVATE_KEY=...
MORPH_HOLESKY_RPC_URL=https://rpc-holesky.morphl2.io
MORPH_API_KEY=...
ADMIN_ADDRESS=...
```

#### New Variables
```bash
PRIVATE_KEY=...
BASE_SEPOLIA_RPC_URL=https://sepolia.base.org
BASESCAN_API_KEY=...
ADMIN_ADDRESS=...
```

### 4. Deployment Commands

#### Old Commands
```bash
make morph-holesky
make morph
```

#### New Commands
```bash
make base-sepolia
make base
```

## Migration Steps

### For Developers

1. **Update Environment Variables**
   ```bash
   # Copy the example file
   cp .env.example .env
   
   # Edit .env and add your:
   # - PRIVATE_KEY (required)
   # - BASE_SEPOLIA_RPC_URL (optional, defaults to https://sepolia.base.org)
   # - BASESCAN_API_KEY (optional, for verification)
   # - ADMIN_ADDRESS (optional, defaults to deployer)
   ```

2. **Get Base Sepolia ETH**
   - Visit: https://www.alchemy.com/faucets/base-sepolia
   - Or: https://docs.base.org/docs/tools/network-faucets/

3. **Verify Configuration**
   ```bash
   ./verify_base_config.sh
   ```

4. **Deploy Contracts**
   ```bash
   # Build and test first
   make build test
   
   # Deploy to Base Sepolia
   make base-sepolia
   
   # Or with test data
   make test-deploy
   ```

### For Frontend Integration

Update your frontend `.env` file:

```bash
# Old
NEXT_PUBLIC_CONTRACT_ADDRESS=0xba9d85b720966B41d05310f235576891C85221D0
NEXT_PUBLIC_RPC_URL=https://rpc-holesky.morphl2.io
NEXT_PUBLIC_CHAIN_ID=2810

# New
NEXT_PUBLIC_CONTRACT_ADDRESS=<new_contract_address>
NEXT_PUBLIC_RPC_URL=https://sepolia.base.org
NEXT_PUBLIC_CHAIN_ID=84532
```

## Verification

After deployment, verify your contract on Basescan:

```bash
# The deployment script will automatically verify if BASESCAN_API_KEY is set
# Or manually verify later:
make verify CONTRACT_ADDRESS=0x... NETWORK=base-sepolia
```

## Testing

All existing tests remain compatible. Run them with:

```bash
make test
make test-verbose
make gas-report
make coverage
```

## Resources

- **Base Sepolia Docs**: https://docs.base.org/docs/network-information
- **Basescan**: https://sepolia.basescan.org
- **Faucets**: https://www.alchemy.com/faucets/base-sepolia
- **Base Bridge**: https://bridge.base.org/

## Support

If you encounter any issues during migration:

1. Run the configuration verification script: `./verify_base_config.sh`
2. Check the environment variables are correctly set
3. Ensure you have Base Sepolia ETH in your wallet
4. Review the deployment logs for any errors

## Next Steps

1. Deploy the contracts to Base Sepolia testnet
2. Update the frontend to use the new contract address
3. Test all functionality on Base Sepolia
4. Once stable, prepare for mainnet deployment on Base
