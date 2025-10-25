'use client';

import React, { createContext, useContext, useState, useEffect, useCallback } from 'react';
import { BrowserProvider } from 'ethers';
import { useAccount, useWalletClient, useDisconnect } from 'wagmi';
import { useAppKit } from '@reown/appkit/react';
import { getContract, PlayerStats } from '@/lib/web3';

interface WalletContextType {
    isLoading: boolean;
    provider: BrowserProvider | null;
    address: string | null;
    isConnected: boolean;
    isRegistered: boolean;
    playerStats: PlayerStats | null;
    connect: () => Promise<void>;
    disconnect: () => Promise<void>;
    checkRegistration: () => Promise<void>;
    refreshPlayerStats: () => Promise<void>;
    retryRegistrationCheck: () => Promise<void>;
    switchToBaseNetwork: () => Promise<boolean>;
}

const WalletContext = createContext<WalletContextType | null>(null);

export function WalletProvider({ children }: { children: React.ReactNode }) {
    const { address, isConnected, chain } = useAccount();
    const { data: walletClient } = useWalletClient();
    const { disconnect: wagmiDisconnect } = useDisconnect();
    const { open } = useAppKit();

    const [provider, setProvider] = useState<BrowserProvider | null>(null);
    const [isRegistered, setIsRegistered] = useState(false);
    const [playerStats, setPlayerStats] = useState<PlayerStats | null>(null);
    const [isLoading, setIsLoading] = useState(true);

    // Add retry mechanism for registration checks
    const [registrationRetryCount, setRegistrationRetryCount] = useState(0);
    const maxRegistrationRetries = 3;

    // Initialize provider when wallet is connected
    useEffect(() => {
        const initializeProvider = async () => {
            if (isConnected && walletClient) {
                try {
                    console.log('Initializing provider for wallet');

                    // Get the transport from wallet client
                    const transport = walletClient.transport;

                    // Create ethers provider from wallet client
                    const ethersProvider = new BrowserProvider(walletClient as any, {
                        name: 'Base Sepolia',
                        chainId: 84532,
                    });

                    // Verify we're on the correct network
                    const network = await ethersProvider.getNetwork();
                    console.log('Connected to network:', network);

                    if (network.chainId !== BigInt(84532)) {
                        console.warn(`Connected to wrong network: ${network.chainId}. Expected: 84532`);
                        setProvider(null);
                        return;
                    }

                    console.log('Created Ethers provider successfully');
                    setProvider(ethersProvider);
                } catch (error) {
                    console.error('Error initializing provider:', error);
                    setProvider(null);
                }
            } else {
                console.log('Not connected or no wallet client available');
                setProvider(null);
            }
        };

        initializeProvider();
    }, [isConnected, walletClient]);

    const checkPlayerRegistration = useCallback(async (playerAddress: string) => {
        if (!provider) return;

        try {
            setIsLoading(true);

            // First, verify we're on the right network
            const network = await provider.getNetwork();
            if (network.chainId !== BigInt(84532)) {
                console.error(`Connected to wrong network: ${network.chainId}. Expected: 84532`);
                throw new Error(`Wrong network: ${network.chainId}. Please connect to Base Sepolia (84532)`);
            }

            // Get contract
            const contract = getContract(provider);

            // Check if player is registered
            const isPlayerRegistered = await contract.registeredPlayers(playerAddress);

            console.log('Registration check for:', playerAddress, 'Result:', isPlayerRegistered);
            setIsRegistered(isPlayerRegistered);

            if (isPlayerRegistered) {
                await fetchPlayerStats(playerAddress);
                setRegistrationRetryCount(0);
            } else {
                setPlayerStats(null);
            }
        } catch (error) {
            console.error('Error checking player registration:', error);

            if (registrationRetryCount < maxRegistrationRetries) {
                console.log(`Registration check failed, retrying... (${registrationRetryCount + 1}/${maxRegistrationRetries})`);
                setRegistrationRetryCount(prev => prev + 1);
                setTimeout(() => checkPlayerRegistration(playerAddress), 2000);
            } else {
                console.error('Max registration check retries reached');
                setIsRegistered(false);
                setPlayerStats(null);
            }
        } finally {
            setIsLoading(false);
        }
    }, [provider, registrationRetryCount, maxRegistrationRetries]);

    // Check registration status when address changes
    useEffect(() => {
        if (address && provider) {
            checkPlayerRegistration(address as string);
        } else {
            setIsRegistered(false);
            setPlayerStats(null);
            setRegistrationRetryCount(0);
        }
    }, [address, provider, checkPlayerRegistration]);

    const fetchPlayerStats = async (playerAddress: string) => {
        if (!provider) return;

        try {
            // Verify network before fetching stats
            const network = await provider.getNetwork();
            if (network.chainId !== BigInt(84532)) {
                console.error(`Connected to wrong network: ${network.chainId}. Expected: 84532`);
                throw new Error(`Wrong network: ${network.chainId}. Please connect to Base Sepolia (84532)`);
            }

            const contract = getContract(provider);
            const stats = await contract.getPlayerStats(playerAddress);

            const playerStatsFormatted: PlayerStats = {
                walksXp: stats.walksXp,
                healthScore: stats.healthScore,
                lastCheckin: Number(stats.lastCheckin),
                totalArtifacts: stats.totalArtifacts,
                currentColony: stats.currentColony,
                petsOwned: stats.petsOwned,
                grassTouchStreak: stats.grassTouchStreak
            };

            console.log('Player stats fetched:', playerStatsFormatted);
            setPlayerStats(playerStatsFormatted);
        } catch (error) {
            console.error('Error fetching player stats:', error);
            setPlayerStats(null);
        }
    };

    const connect = async () => {
        try {
            await open();
        } catch (error) {
            console.error('Failed to connect wallet:', error);
        }
    };

    const disconnect = async () => {
        try {
            wagmiDisconnect();
            // Clear local state
            setProvider(null);
            setIsRegistered(false);
            setPlayerStats(null);
            setRegistrationRetryCount(0);
        } catch (error) {
            console.error('Failed to disconnect wallet:', error);
        }
    };

    const checkRegistration = async () => {
        if (address) {
            await checkPlayerRegistration(address as string);
        }
    };

    const refreshPlayerStats = async () => {
        if (address && provider) {
            await fetchPlayerStats(address as string);
        }
    };

    const retryRegistrationCheck = async () => {
        if (address) {
            setRegistrationRetryCount(0);
            await checkPlayerRegistration(address as string);
        }
    };

    // Helper function to switch to Base Sepolia
    const switchToBaseNetwork = async () => {
        if (!isConnected) {
            console.error('Not connected to any wallet');
            return false;
        }

        try {
            // Open network modal
            await open({ view: 'Networks' });
            return true;
        } catch (error) {
            console.error('Error switching network:', error);
            return false;
        }
    };

    // Initialize loading state
    useEffect(() => {
        if (!isConnected) {
            setIsLoading(false);
        }
    }, [isConnected]);

    const contextValue: WalletContextType = {
        isLoading,
        provider,
        address: address || null,
        isConnected,
        isRegistered,
        playerStats,
        connect,
        disconnect,
        checkRegistration,
        refreshPlayerStats,
        retryRegistrationCheck,
        switchToBaseNetwork
    };

    return (
        <WalletContext.Provider value={contextValue}>
            {children}
        </WalletContext.Provider>
    );
}

export function useWallet() {
    const context = useContext(WalletContext);
    if (!context) {
        throw new Error('useWallet must be used within a WalletProvider');
    }
    return context;
}
