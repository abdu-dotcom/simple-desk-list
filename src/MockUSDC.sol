// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title MockUSDC
 * @dev Mock USDC token untuk testing (6 decimals seperti USDC asli)
 */
contract MockUSDC is ERC20, Ownable {
    /**
     * @dev Constructor - mint 1 juta USDC ke deployer
     */
    constructor() ERC20("Mock USDC", "USDC") Ownable(msg.sender) {
        // Mint 1 million USDC (remember: 6 decimals!)
        _mint(msg.sender, 1_000_000 * 10**6);
    }

    /**
     * @dev Override decimals untuk match USDC asli
     */
    function decimals() public pure override returns (uint8) {
        return 6; // USDC menggunakan 6 decimals, bukan 18
    }

    /**
     * @dev Mint token baru (hanya owner)
     */
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    /**
     * @dev Burn token
     */
    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }
}