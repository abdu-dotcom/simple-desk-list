// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Test.sol";
import "../src/CampusCoin.sol";

contract CampusCoinTest is Test {
    CampusCoin public campusCoin;
    address public owner;
    address public user1;
    address public user2;

    function setUp() public {
        owner = address(this);
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");

        campusCoin = new CampusCoin();
    }

    function test_InitialState() public view {
        // Check basic properties
        assertEq(campusCoin.name(), "Campus Coin");
        assertEq(campusCoin.symbol(), "CAMP");
        assertEq(campusCoin.decimals(), 18);

        // Check initial supply (100,000 CAMP)
        uint256 expectedInitial = 100_000 * 10**18;
        assertEq(campusCoin.totalSupply(), expectedInitial);
        assertEq(campusCoin.balanceOf(owner), expectedInitial);
    }

    function test_Mint() public {
        uint256 mintAmount = 1000 * 10**18;

        campusCoin.mint(user1, mintAmount);

        assertEq(campusCoin.balanceOf(user1), mintAmount);
        assertEq(campusCoin.totalSupply(), 100_000 * 10**18 + mintAmount);
    }

    function test_MintFailsWhenNotOwner() public {
        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, user1));
        campusCoin.mint(user2, 1000 * 10**18);
    }

    function test_Burn() public {
        uint256 burnAmount = 1000 * 10**18;

        campusCoin.burn(burnAmount);

        assertEq(campusCoin.balanceOf(owner), 100_000 * 10**18 - burnAmount);
    }
}