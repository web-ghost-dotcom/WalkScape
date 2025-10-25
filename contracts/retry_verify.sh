#!/bin/bash

# Retry Contract Verification Script
# This script retries verification after rate limit cooldown

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 WalkScape Contract Verification Retry${NC}"
echo "=========================================="

# Load environment variables
if [ -f .env ]; then
    source .env
fi

# Contract details
CONTRACT_ADDRESS="0xED9cc4E9aD33CF6dA4D24e715d6a0C51EB4B98BD"
CONSTRUCTOR_ARGS="000000000000000000000000ed6c9f2573343043dd443bc633f9071abdf688fd"

echo -e "${BLUE}📍 Contract: $CONTRACT_ADDRESS${NC}"
echo -e "${BLUE}🌐 Network: Base Sepolia (Chain ID: 84532)${NC}"
echo ""

# Check if API key is set
if [ -z "$BASESCAN_API_KEY" ]; then
    echo -e "${RED}❌ Error: BASESCAN_API_KEY not set in .env${NC}"
    echo ""
    echo "Please set BASESCAN_API_KEY in your .env file"
    echo "Get one from: https://basescan.org/myapikey"
    exit 1
fi

echo -e "${YELLOW}⏳ Attempting verification...${NC}"
echo ""

# Run verification
forge verify-contract \
    $CONTRACT_ADDRESS \
    src/WalkScapeCore.sol:WalkScapeCore \
    --chain-id 84532 \
    --constructor-args $CONSTRUCTOR_ARGS \
    --etherscan-api-key $BASESCAN_API_KEY \
    --watch

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ Contract verified successfully!${NC}"
    echo ""
    echo -e "${BLUE}📋 View on Basescan:${NC}"
    echo "https://sepolia.basescan.org/address/$CONTRACT_ADDRESS#code"
    echo ""
else
    echo ""
    echo -e "${RED}❌ Verification failed${NC}"
    echo ""
    echo -e "${YELLOW}Possible solutions:${NC}"
    echo "1. Wait 10-15 minutes if rate limited"
    echo "2. Get a new API key from https://basescan.org/myapikey"
    echo "3. Use manual verification via Basescan UI"
    echo ""
    echo "See VERIFY_MANUAL.md for detailed instructions"
    exit 1
fi
