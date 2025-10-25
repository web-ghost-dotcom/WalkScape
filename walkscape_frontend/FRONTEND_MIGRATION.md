# Frontend Migration: Morph + Privy → Base Sepolia + Reown AppKit

## Overview

The WalkScape frontend has been migrated from:
- **Network**: Morph Holesky (Chain ID: 2810) → **Base Sepolia** (Chain ID: 84532)
- **Wallet Provider**: Privy → **Reown AppKit** with Wagmi

## Changes Made

### 1. Dependencies Updated (`package.json`)

**Removed:**
- `@privy-io/react-auth`

**Added:**
- `@reown/appkit`: ^1.6.2
- `@reown/appkit-adapter-wagmi`: ^1.6.2
- `@tanstack/react-query`: ^5.62.13
- `viem`: ^2.21.57
- `wagmi`: ^2.13.11

### 2. New Files Created

#### `src/config/index.tsx`
AppKit configuration with Wagmi adapter for Base Sepolia network.

#### `src/contexts/AppKitProvider.tsx`
Replaces `PrivyWrapper.tsx` with Reown AppKit provider setup.

#### `.env.example`
Template for environment variables with Base Sepolia configuration.

### 3. Files Modified

#### `src/contexts/WalletContext.tsx`
- Replaced Privy hooks (`usePrivy`, `useWallets`) with Wagmi hooks (`useAccount`, `useWalletClient`, `useDisconnect`)
- Replaced `useAppKit` for modal controls
- Updated from Morph Holesky (2810) to Base Sepolia (84532)
- Renamed `switchToMorphNetwork` → `switchToBaseNetwork`

#### `src/lib/web3.ts`
- Updated `SUPPORTED_CHAIN_IDS` from `[2810]` to `[84532]`
- Renamed `MORPH_HOLESKY_CONFIG` → `BASE_SEPOLIA_CONFIG`
- Updated network configuration:
  - Chain ID: 84532
  - Name: 'Base Sepolia'
  - Explorer: 'https://sepolia.basescan.org'
  - RPC: 'https://sepolia.base.org'

#### `src/app/layout.tsx`
- Replaced `PrivyWrapper` with `AppKitProvider`
- Added cookie handling for SSR support
- Function now async to support Next.js headers

#### `src/components/NetworkSwitcher.tsx`
- Updated chain ID check from `2810` to `84532`
- Updated error message from "Morph Holesky Testnet" to "Base Sepolia"
- Renamed function call from `switchToMorphNetwork` to `switchToBaseNetwork`

#### `src/components/LandingPage.tsx`
- Changed "Built on Morph" → "Built on Base"
- Updated wallet connection description
- Changed footer "Powered by Morph" → "Powered by Base"

#### `next.config.ts`
- Added webpack externals for AppKit SSR support:
  ```typescript
  webpack: (config) => {
    config.externals.push("pino-pretty", "lokijs", "encoding");
    return config;
  }
  ```

### 4. Files Preserved (Backup)

- `src/contexts/WalletContext.old.tsx` - Original Privy-based wallet context
- `src/contexts/PrivyWrapper.tsx` - Can be removed after testing

## Installation & Setup

### Step 1: Install Dependencies

```bash
cd walkscape_frontend
npm install
```

This will install:
- @reown/appkit
- @reown/appkit-adapter-wagmi
- wagmi
- viem
- @tanstack/react-query

### Step 2: Get Reown Project ID

1. Visit: https://dashboard.reown.com
2. Create a new project
3. Copy your Project ID

### Step 3: Configure Environment Variables

Create a `.env.local` file based on `.env.example`:

```bash
cp .env.example .env.local
```

Update with your values:

```env
# REQUIRED: Get from https://dashboard.reown.com
NEXT_PUBLIC_PROJECT_ID=your_project_id_here

# Contract address from deployment
NEXT_PUBLIC_CONTRACT_ADDRESS=0xED9cc4E9aD33CF6dA4D24e715d6a0C51EB4B98BD

# Base Sepolia RPC
NEXT_PUBLIC_RPC_URL=https://sepolia.base.org

# Chain ID
NEXT_PUBLIC_SUPPORTED_CHAIN_IDS=84532

# Optional: For AI features
NEXT_PUBLIC_GOOGLE_AI_API_KEY=your_google_ai_api_key_here
```

### Step 4: Run Development Server

```bash
npm run dev
```

Visit: http://localhost:3000

## Testing Checklist

### Wallet Connection
- [ ] AppKit modal opens when clicking "Launch App" or "Connect Wallet"
- [ ] Can connect with MetaMask
- [ ] Can connect with WalletConnect
- [ ] Can connect with Coinbase Wallet
- [ ] Connection persists on page refresh

### Network Management
- [ ] Network switcher shows warning if on wrong network
- [ ] Can switch to Base Sepolia from network modal
- [ ] Contract interactions work on Base Sepolia
- [ ] Chain ID validation works (84532)

### Features
- [ ] Player registration works
- [ ] Can view player stats
- [ ] Artifact scanning works
- [ ] Pet minting works
- [ ] Colony features work
- [ ] Staking features work

### UI/UX
- [ ] No references to "Morph" in the UI
- [ ] All text updated to "Base Sepolia"
- [ ] Icons and branding consistent
- [ ] Mobile responsive

## Key Differences: Privy vs AppKit

| Feature | Privy | Reown AppKit |
|---------|-------|--------------|
| **Social Logins** | ✅ Email, SMS, Social | ❌ Wallet-only |
| **Embedded Wallets** | ✅ Yes | ❌ No |
| **Multi-chain** | ✅ Easy config | ✅ Via adapters |
| **WalletConnect** | ✅ Built-in | ✅ Native |
| **UI Customization** | Limited | ✅ Extensive |
| **React Hooks** | Custom | ✅ Wagmi standard |
| **SSR Support** | ✅ Good | ✅ Excellent |
| **Free Tier** | Limited | ✅ Generous |

## Migration Benefits

1. **Open Source**: AppKit is fully open source
2. **Standard Hooks**: Uses industry-standard Wagmi hooks
3. **Better Performance**: Optimized for Web3 interactions
4. **No Vendor Lock-in**: Can switch providers easily
5. **Cost**: More generous free tier
6. **Community**: Larger developer community

## Troubleshooting

### "Cannot find module '@reown/appkit'" Error
```bash
rm -rf node_modules package-lock.json
npm install
```

### Wallet Not Connecting
1. Check PROJECT_ID is set in `.env.local`
2. Verify you're on Base Sepolia network
3. Clear browser cache and MetaMask permissions
4. Check browser console for errors

### Contract Interaction Fails
1. Verify CONTRACT_ADDRESS is correct
2. Ensure you're connected to Base Sepolia (84532)
3. Check you have Base Sepolia ETH for gas
4. Verify RPC_URL is accessible

### SSR Hydration Errors
- Ensure `AppKitProvider` receives cookies prop
- Check `'use client'` directives are in place
- Verify webpack externals in `next.config.ts`

## Rollback Plan

If you need to rollback to Privy:

1. Restore old files:
   ```bash
   mv src/contexts/WalletContext.old.tsx src/contexts/WalletContext.tsx
   ```

2. Revert package.json changes
3. Run `npm install`
4. Update environment variables back to Privy config

## Resources

- **Reown AppKit Docs**: https://docs.reown.com/appkit
- **Wagmi Docs**: https://wagmi.sh/
- **Base Sepolia Docs**: https://docs.base.org/docs/network-information
- **Basescan Explorer**: https://sepolia.basescan.org
- **Base Sepolia Faucet**: https://www.alchemy.com/faucets/base-sepolia

## Next Steps

1. ✅ Install dependencies
2. ✅ Get Reown Project ID
3. ✅ Configure environment variables
4. ✅ Test wallet connection
5. ✅ Test all features
6. 🔄 Deploy to production
7. 🔄 Update documentation
8. 🔄 Remove old Privy code

## Support

For issues or questions:
- Check the troubleshooting section above
- Review the Reown AppKit documentation
- Check Wagmi documentation for hook usage
- Review the Base Sepolia network documentation
