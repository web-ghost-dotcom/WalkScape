#!/bin/bash

# WalkScape Base Sepolia Deployment Script
# This script deploys the WalkScapeCore contract to Base Sepolia network

set -e

# Load environment variables
if [ -f .env ]; then
    source .env
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 WalkScape Base Sepolia Deployment Script${NC}"
echo "===================================="

# Check required environment variables
if [ -z "$PRIVATE_KEY" ]; then
    echo -e "${RED}❌ Error: PRIVATE_KEY not set in environment${NC}"
    echo "Please set PRIVATE_KEY in your .env file"
    exit 1
fi

# Default to Base Sepolia Testnet if not specified
if [ -z "$BASE_SEPOLIA_RPC_URL" ]; then
    export BASE_SEPOLIA_RPC_URL="https://sepolia.base.org"
    echo -e "${YELLOW}⚠️  Using default Base Sepolia RPC: $BASE_SEPOLIA_RPC_URL${NC}"
fi

# Base Sepolia network configuration
NETWORK="Base Sepolia Testnet"
EXPECTED_CHAIN_ID=84532

echo -e "${BLUE}📡 Network: $NETWORK${NC}"
echo -e "${BLUE}🔗 RPC URL: $BASE_SEPOLIA_RPC_URL${NC}"

# Verify network connection
echo -e "${YELLOW}🔍 Verifying network connection...${NC}"
if ! curl -s -X POST -H "Content-Type: application/json" \
    --data '{"jsonrpc":"2.0","method":"eth_chainId","params":[],"id":1}' \
    "$BASE_SEPOLIA_RPC_URL" > /dev/null; then
    echo -e "${RED}❌ Error: Cannot connect to Base Sepolia RPC${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Network connection verified${NC}"

# Build contracts
echo -e "${YELLOW}🔨 Building contracts...${NC}"
forge build

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Error: Contract build failed${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Contracts built successfully${NC}"

# Deploy contract
echo -e "${YELLOW}🚢 Deploying WalkScapeCore contract...${NC}"
echo "Admin address: ${ADMIN_ADDRESS:-$DEPLOYER_ADDRESS}"

DEPLOY_CMD="forge script script/Deploy.s.sol:DeployWalkScapeCore \
    --rpc-url $BASE_SEPOLIA_RPC_URL \
    --private-key $PRIVATE_KEY \
    --broadcast"

# Add verification if API key is provided (Basescan)
if [ ! -z "$BASESCAN_API_KEY" ]; then
    DEPLOY_CMD="$DEPLOY_CMD --verify --etherscan-api-key $BASESCAN_API_KEY"
fi

echo -e "${BLUE}📝 Running deployment command...${NC}"
eval $DEPLOY_CMD

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Contract deployed successfully!${NC}"
    
    # Extract contract address from deployment output
    CONTRACT_ADDRESS=$(forge script script/Deploy.s.sol:DeployWalkScapeCore --rpc-url $BASE_SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast 2>/dev/null | grep "WalkScapeCore deployed at:" | awk '{print $4}')
    
    if [ ! -z "$CONTRACT_ADDRESS" ]; then
        echo -e "${GREEN}📍 Contract Address: $CONTRACT_ADDRESS${NC}"
        
        # Update .env file with contract address
        if [ -f .env ]; then
            sed -i.bak "s/CONTRACT_ADDRESS=.*/CONTRACT_ADDRESS=$CONTRACT_ADDRESS/" .env
            echo -e "${GREEN}✅ Updated .env file with contract address${NC}"
        fi
        
        # Create deployment info JSON
        cat > deployment_info.json << EOF
{
  "contractAddress": "$CONTRACT_ADDRESS",
  "network": "$NETWORK",
  "rpcUrl": "$BASE_SEPOLIA_RPC_URL",
  "chainId": $EXPECTED_CHAIN_ID,
  "deployedAt": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "adminAddress": "${ADMIN_ADDRESS:-$DEPLOYER_ADDRESS}"
}
EOF
        echo -e "${GREEN}✅ Created deployment_info.json${NC}"
        
        # Setup instructions
        echo -e "${BLUE}📋 Next Steps:${NC}"
        echo "1. Update your frontend .env file:"
        echo "   NEXT_PUBLIC_CONTRACT_ADDRESS=$CONTRACT_ADDRESS"
        echo "   NEXT_PUBLIC_RPC_URL=$BASE_SEPOLIA_RPC_URL"
        echo ""
        echo "2. Test your deployment:"
        echo "   forge script script/Deploy.s.sol:VerifyDeployment --rpc-url $BASE_SEPOLIA_RPC_URL"
        echo ""
        echo "3. Setup test players (optional):"
        echo "   forge script script/Deploy.s.sol:RegisterTestPlayers --rpc-url $BASE_SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast"
        
    else
        echo -e "${YELLOW}⚠️  Could not extract contract address from deployment output${NC}"
    fi
else
    echo -e "${RED}❌ Error: Contract deployment failed${NC}"
    exit 1
fi

echo -e "${GREEN}🎉 Deployment completed successfully!${NC}"
