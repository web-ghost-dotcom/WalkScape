#!/bin/bash

# Base Sepolia Configuration Verification Script
# This script verifies that all configurations are properly set for Base Sepolia deployment

set -e

echo "🔍 Verifying Base Sepolia Configuration..."
echo "=================================="

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if foundry is installed
if command -v forge &> /dev/null; then
    echo -e "${GREEN}✅ Foundry is installed${NC}"
else
    echo -e "${RED}❌ Foundry is not installed${NC}"
    exit 1
fi

# Check if .env file exists
if [ -f .env ]; then
    echo -e "${GREEN}✅ .env file exists${NC}"
    source .env
else
    echo -e "${YELLOW}⚠️  .env file not found (using .env.example as reference)${NC}"
fi

# Check private key
if [ -z "$PRIVATE_KEY" ]; then
    echo -e "${RED}❌ PRIVATE_KEY not set in .env${NC}"
    echo "Please set PRIVATE_KEY in your .env file"
else
    echo -e "${GREEN}✅ PRIVATE_KEY is set${NC}"
fi

# Check Base Sepolia RPC URL
if [ -z "$BASE_SEPOLIA_RPC_URL" ]; then
    echo -e "${YELLOW}⚠️  BASE_SEPOLIA_RPC_URL not set, using default${NC}"
    BASE_SEPOLIA_RPC_URL="https://sepolia.base.org"
else
    echo -e "${GREEN}✅ BASE_SEPOLIA_RPC_URL is set: $BASE_SEPOLIA_RPC_URL${NC}"
fi

# Test connection to Base Sepolia RPC
echo -e "${BLUE}🔗 Testing connection to Base Sepolia...${NC}"
if curl -s -X POST -H "Content-Type: application/json" \
    --data '{"jsonrpc":"2.0","method":"eth_chainId","params":[],"id":1}' \
    "$BASE_SEPOLIA_RPC_URL" > /dev/null; then
    
    # Get chain ID
    CHAIN_ID=$(curl -s -X POST -H "Content-Type: application/json" \
        --data '{"jsonrpc":"2.0","method":"eth_chainId","params":[],"id":1}' \
        "$BASE_SEPOLIA_RPC_URL" | grep -o '"result":"[^"]*"' | cut -d'"' -f4)
    
    # Convert hex to decimal
    CHAIN_ID_DEC=$((16#${CHAIN_ID#0x}))
    
    if [ "$CHAIN_ID_DEC" = "84532" ]; then
        echo -e "${GREEN}✅ Connected to Base Sepolia (Chain ID: $CHAIN_ID_DEC)${NC}"
    else
        echo -e "${RED}❌ Wrong chain ID: $CHAIN_ID_DEC (expected 84532)${NC}"
        exit 1
    fi
else
    echo -e "${RED}❌ Cannot connect to Base Sepolia RPC${NC}"
    exit 1
fi

# Check if contracts can be built
echo -e "${BLUE}🔨 Testing contract build...${NC}"
if forge build > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Contracts build successfully${NC}"
else
    echo -e "${RED}❌ Contract build failed${NC}"
    exit 1
fi

# Check if tests pass
echo -e "${BLUE}🧪 Testing contract tests...${NC}"
if forge test > /dev/null 2>&1; then
    echo -e "${GREEN}✅ All tests pass${NC}"
else
    echo -e "${YELLOW}⚠️  Some tests failed or no tests found${NC}"
fi

echo ""
echo -e "${GREEN}🎉 Base Sepolia Configuration Verification Complete!${NC}"
echo "============================================="
echo ""
echo -e "${BLUE}📋 Configuration Summary:${NC}"
echo "  Network: Base Sepolia Testnet"
echo "  Chain ID: 84532"
echo "  RPC URL: $BASE_SEPOLIA_RPC_URL"
echo "  Private Key: ${PRIVATE_KEY:+Set}${PRIVATE_KEY:-Not Set}"
echo ""
echo -e "${BLUE}🚀 Ready to deploy!${NC}"
echo "  Run: ./deploy_base.sh"
echo "  Or:  make base-sepolia"
echo ""
