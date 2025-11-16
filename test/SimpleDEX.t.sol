// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Test.sol";
import "../src/CampusCoin.sol";
import "../src/MockUSDC.sol";
import "../src/SimpleDEX.sol";

contract SimpleDEXTest is Test {
    CampusCoin public campusCoin;
    MockUSDC public usdc;
    SimpleDEX public dex;

    address public owner;
    address public alice;
    address public bob;

    uint256 public constant CAMP_AMOUNT = 1000 * 10**18; // 1000 CAMP
    uint256 public constant USDC_AMOUNT = 2000 * 10**6;  // 2000 USDC

    function setUp() public {
        owner = address(this);
        alice = makeAddr("alice");
        bob = makeAddr("bob");

        // Deploy contracts
        campusCoin = new CampusCoin();
        usdc = new MockUSDC();
        dex = new SimpleDEX(address(campusCoin), address(usdc));

        // Setup balances
        campusCoin.mint(alice, 10_000 * 10**18);
        campusCoin.mint(bob, 5_000 * 10**18);

        usdc.mint(alice, 20_000 * 10**6);
        usdc.mint(bob, 10_000 * 10**6);

        // Approve DEX
        vm.prank(alice);
        campusCoin.approve(address(dex), type(uint256).max);
        vm.prank(alice);
        usdc.approve(address(dex), type(uint256).max);

        vm.prank(bob);
        campusCoin.approve(address(dex), type(uint256).max);
        vm.prank(bob);
        usdc.approve(address(dex), type(uint256).max);
    }

    function test_AddLiquidity() public {
        vm.prank(alice);
        uint256 liquidity = dex.addLiquidity(CAMP_AMOUNT, USDC_AMOUNT);

        // Check LP tokens minted
        assertGt(liquidity, 0);
        assertEq(dex.balanceOf(alice), liquidity);

        // Check reserves updated
        assertEq(dex.reserveA(), CAMP_AMOUNT);
        assertEq(dex.reserveB(), USDC_AMOUNT);

        // Check tokens transferred
        assertEq(campusCoin.balanceOf(address(dex)), CAMP_AMOUNT);
        assertEq(usdc.balanceOf(address(dex)), USDC_AMOUNT);
    }

    function test_SwapAforB() public {
        // Add liquidity first
        vm.prank(alice);
        dex.addLiquidity(CAMP_AMOUNT, USDC_AMOUNT);

        // Bob swaps CAMP for USDC
        uint256 swapAmount = 100 * 10**18; // 100 CAMP
        uint256 expectedOut = dex.getAmountOut(swapAmount, CAMP_AMOUNT, USDC_AMOUNT);

        uint256 bobUsdcBefore = usdc.balanceOf(bob);

        vm.prank(bob);
        dex.swapAforB(swapAmount, expectedOut);

        // Check USDC received
        assertEq(usdc.balanceOf(bob), bobUsdcBefore + expectedOut);

        // Check reserves updated
        assertEq(dex.reserveA(), CAMP_AMOUNT + swapAmount);
        assertEq(dex.reserveB(), USDC_AMOUNT - expectedOut);
    }

    function test_CompleteScenario() public {
        console.log("=== Complete DEX Scenario ===");

        // Alice adds liquidity
        vm.prank(alice);
        uint256 liquidity = dex.addLiquidity(CAMP_AMOUNT, USDC_AMOUNT);
        console.log("Alice LP tokens:", liquidity);

        // Bob swaps
        uint256 swapAmount = 50 * 10**18;
        uint256 expectedOut = dex.getAmountOut(swapAmount, CAMP_AMOUNT, USDC_AMOUNT);

        vm.prank(bob);
        dex.swapAforB(swapAmount, expectedOut);
        console.log("Bob swapped 50 CAMP for", expectedOut / 10**6, "USDC");

        // Alice removes liquidity
        vm.prank(alice);
        (uint256 campOut, uint256 usdcOut) = dex.removeLiquidity(liquidity / 2);
        // console.log("Alice removed liquidity:", campOut / 10**18, "CAMP,", usdcOut / 10**6, "USDC");

        assertGt(campOut, 0);
        assertGt(usdcOut, 0);
    }
}