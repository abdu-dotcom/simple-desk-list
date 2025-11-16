// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Script, console} from "forge-std/Script.sol";
import {CampusCoin} from "../src/CampusCoin.sol";
import {MockUSDC} from "../src/MockUSDC.sol";
import {SimpleDEX} from "../src/SimpleDEX.sol";

contract DeployDEX is Script {
    // Contract instances
    CampusCoin public campusCoin;
    MockUSDC public usdc;
    SimpleDEX public dex;

    // Initial liquidity amounts
    uint256 public constant INITIAL_CAMP_LIQUIDITY = 1000 * 10**18;  // 1,000 CAMP
    uint256 public constant INITIAL_USDC_LIQUIDITY = 2000 * 10**6;   // 2,000 USDC

    function run() public returns (address, address, address) {
        console.log("========================================");
        console.log("Deploying Simple DEX to Lisk Sepolia...");
        console.log("========================================");
        console.log("");

        // Get deployer info
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        console.log("Deployer address:", deployer);
        console.log("Network: Lisk Sepolia Testnet");
        console.log("Chain ID: 4202");
        console.log("");

        // Check balance
        uint256 balance = deployer.balance;
        console.log("Deployer balance:", balance / 1e18, "ETH");

        if (balance < 0.01 ether) {
            console.log("");
            console.log("WARNING: Low balance!");
            console.log("Get test ETH from faucet:");
            console.log("https://sepolia-faucet.lisk.com");
            console.log("");
        }

        vm.startBroadcast(deployerPrivateKey);

        // Step 1: Deploy tokens
        console.log("Step 1: Deploying tokens...");
        console.log("----------------------------");

        campusCoin = new CampusCoin();
        console.log("CampusCoin deployed at:", address(campusCoin));

        usdc = new MockUSDC();
        console.log("MockUSDC deployed at  :", address(usdc));
        console.log("");

        // Step 2: Deploy DEX
        console.log("Step 2: Deploying DEX...");
        console.log("-------------------------");

        dex = new SimpleDEX(address(campusCoin), address(usdc));
        console.log("SimpleDEX deployed at :", address(dex));
        console.log("");

        // Step 3: Setup initial liquidity
        console.log("Step 3: Setting up initial liquidity...");
        console.log("----------------------------------------");

        // Mint additional tokens untuk liquidity + testing
        campusCoin.mint(deployer, INITIAL_CAMP_LIQUIDITY + 5000 * 10**18);
        usdc.mint(deployer, INITIAL_USDC_LIQUIDITY + 10000 * 10**6);

        // Approve DEX
        campusCoin.approve(address(dex), type(uint256).max);
        usdc.approve(address(dex), type(uint256).max);

        // Add initial liquidity
        uint256 liquidity = dex.addLiquidity(INITIAL_CAMP_LIQUIDITY, INITIAL_USDC_LIQUIDITY);
        console.log("Initial liquidity added");
        console.log("LP tokens minted:", liquidity);
        console.log("");

        vm.stopBroadcast();

        // Step 4: Verification
        console.log("Step 4: Deployment verification...");
        console.log("------------------------------------");
        _verifyDeployment();
        console.log("");

        // Step 5: Instructions
        console.log("Step 5: Next steps...");
        console.log("----------------------");
        _printInstructions();

        return (address(campusCoin), address(usdc), address(dex));
    }

    function _verifyDeployment() internal view {
        // Token info
        console.log("CampusCoin:");
        console.log("  Name        :", campusCoin.name());
        console.log("  Symbol      :", campusCoin.symbol());
        console.log("  Total Supply:", campusCoin.totalSupply() / 10**18, "CAMP");
        console.log("");

        console.log("MockUSDC:");
        console.log("  Name        :", usdc.name());
        console.log("  Symbol      :", usdc.symbol());
        console.log("  Total Supply:", usdc.totalSupply() / 10**6, "USDC");
        console.log("");

        // DEX info
        (uint256 reserveA, uint256 reserveB, uint256 totalLiquidity, uint256 price) = dex.getPoolInfo();
        console.log("SimpleDEX Pool:");
        console.log("  CAMP Reserve:", reserveA / 10**18, "CAMP");
        console.log("  USDC Reserve:", reserveB / 10**6, "USDC");
        console.log("  Total LP    :", totalLiquidity);
        console.log("  Price       :", price / 1e18, "USDC per CAMP");
    }

    function _printInstructions() internal view {
        console.log("Contract Addresses:");
        console.log("  CampusCoin :", address(campusCoin));
        console.log("  MockUSDC   :", address(usdc));
        console.log("  SimpleDEX  :", address(dex));
        console.log("");

        console.log("Block Explorer:");
        console.log("  https://sepolia-blockscout.lisk.com/address/%s", address(dex));
        console.log("");

        console.log("How to interact:");
        console.log("  1. Add liquidity: dex.addLiquidity(campAmount, usdcAmount)");
        console.log("  2. Swap CAMP->USDC: dex.swapAforB(campAmount, minUsdcOut)");
        console.log("  3. Swap USDC->CAMP: dex.swapBforA(usdcAmount, minCampOut)");
        console.log("  4. Remove liquidity: dex.removeLiquidity(lpAmount)");
        console.log("");

        console.log("Save these addresses for later use!");
    }
}