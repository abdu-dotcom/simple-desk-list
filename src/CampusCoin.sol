// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title CampusCoin
 * @dev Token ERC-20 sederhana dengan supply maksimum
 */
contract CampusCoin is ERC20, Ownable {
    // Total supply maksimum: 1 juta token
    uint256 public constant MAX_SUPPLY = 1_000_000 * 10**18;

    // Event untuk tracking mint
    event TokensMinted(address indexed to, uint256 amount);

    /**
     * @dev Constructor - mint initial supply ke deployer
     */
    constructor() ERC20("Campus Coin", "CAMP") Ownable(msg.sender) {
        // Mint 100 ribu token initial supply
        uint256 initialSupply = 100_000 * 10**18;
        _mint(msg.sender, initialSupply);

        emit TokensMinted(msg.sender, initialSupply);
    }

    /**
     * @dev Mint token baru (hanya owner)
     * @param to Address penerima token
     * @param amount Jumlah token yang di-mint
     */
    function mint(address to, uint256 amount) external onlyOwner {
        require(to != address(0), "Cannot mint to zero address");
        require(totalSupply() + amount <= MAX_SUPPLY, "Exceeds max supply");

        _mint(to, amount);
        emit TokensMinted(to, amount);
    }

    /**
     * @dev Burn token milik caller
     * @param amount Jumlah token yang diburn
     */
    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    /**
     * @dev Cek sisa supply yang bisa dimint
     */
    function remainingSupply() external view returns (uint256) {
        return MAX_SUPPLY - totalSupply();
    }
}