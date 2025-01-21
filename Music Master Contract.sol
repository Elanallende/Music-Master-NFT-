// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract MasterOwnershipNFT is ERC721Enumerable, ERC721Royalty, Ownable, ReentrancyGuard {
    struct OwnershipShare {
        uint256 tokenId;
        uint256 percentage;
    }

    mapping(uint256 => uint256) public ownershipShares; // tokenId => percentage
    uint256 public totalShares;
    string private _baseTokenURI;
    IERC20 public usdcToken;
    uint256 public totalRevenue;
    uint256 public nftPrice;  // Price of each NFT in USDC
    address public revenueManager; // Address authorized to update revenue

    event RevenueUpdated(uint256 amount);
    event RevenueDistributed(uint256 totalRevenue);
    event NFTPurchased(address indexed buyer, uint256 tokenId, uint256 percentage);
    event RevenueManagerUpdated(address indexed newManager);

    modifier onlyRevenueManager() {
        require(msg.sender == revenueManager || msg.sender == owner(), "Not authorized");
        _;
    }

    constructor(
        string memory name,
        string memory symbol,
        string memory baseTokenURI,
        address usdcAddress,
        address royaltyReceiver,
        uint96 royaltyFeeNumerator,
        uint256 pricePerNFT
    ) ERC721(name, symbol) {
        _baseTokenURI = baseTokenURI;
        usdcToken = IERC20(usdcAddress);
        _setDefaultRoyalty(royaltyReceiver, royaltyFeeNumerator);
        nftPrice = pricePerNFT;
        revenueManager = msg.sender;  // Set contract deployer as initial revenue manager
    }

    function purchaseNFT(uint256 percentage) external nonReentrant {
        require(percentage > 0 && percentage <= 100, "Invalid percentage");
        require(totalShares + percentage <= 100, "Exceeds total ownership limit");
        require(usdcToken.transferFrom(msg.sender, address(this), nftPrice), "USDC payment failed");

        uint256 tokenId = totalSupply() + 1;
        _safeMint(msg.sender, tokenId);
        ownershipShares[tokenId] = percentage;
        totalShares += percentage;

        emit NFTPurchased(msg.sender, tokenId, percentage);
    }

    function setBaseURI(string memory baseTokenURI) external onlyOwner {
        _baseTokenURI = baseTokenURI;
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    function getOwnershipPercentage(uint256 tokenId) external view returns (uint256) {
        require(_exists(tokenId), "Token does not exist");
        return ownershipShares[tokenId];
    }

    function transferOwnershipShare(address to, uint256 tokenId) external {
        require(ownerOf(tokenId) == msg.sender, "Not token owner");
        _transfer(msg.sender, to, tokenId);
    }

    function burn(uint256 tokenId) external {
        require(ownerOf(tokenId) == msg.sender, "Not token owner");
        totalShares -= ownershipShares[tokenId];
        delete ownershipShares[tokenId];
        _burn(tokenId);
    }

    function updateRevenue(uint256 amount) external onlyRevenueManager nonReentrant {
        require(amount > 0, "Amount must be greater than zero");
        require(usdcToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        totalRevenue += amount;
        emit RevenueUpdated(amount);
    }

    function distributeRevenue() external onlyOwner nonReentrant {
        require(totalRevenue > 0, "No revenue to distribute");
        for (uint256 i = 0; i < totalSupply(); i++) {
            uint256 tokenId = tokenByIndex(i);
            address owner = ownerOf(tokenId);
            uint256 shareAmount = (totalRevenue * ownershipShares[tokenId]) / 100;
            require(usdcToken.transfer(owner, shareAmount), "Transfer to owner failed");
        }
        emit RevenueDistributed(totalRevenue);
        totalRevenue = 0;
    }

    function setRevenueManager(address newManager) external onlyOwner {
        require(newManager != address(0), "Invalid address");
        revenueManager = newManager;
        emit RevenueManagerUpdated(newManager);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Royalty) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
