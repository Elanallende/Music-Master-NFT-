# Music-Master-NFT-

This Solidity smart contract, MasterOwnershipNFT, is an ERC-721 (NFT) contract that represents fractional ownership of a music master (or other assets) with built-in revenue distribution and royalty tracking. Here's a breakdown of its key features and functionalities:

Key Functionalities:
1. ERC-721 Token with Enumerable and Royalty Extensions:
    * Implements ERC721Enumerable to allow tracking of all NFT tokens.
    * Implements ERC721Royalty to support royalty payments on secondary sales.
2. Ownership Shares Tracking:
    * The contract allows fractional ownership by assigning a percentage of ownership to each NFT (mapping(uint256 => uint256) public ownershipShares).
    * The total shares cannot exceed 100%.
3. Purchase NFTs in USDC:
    * Users can purchase ownership NFTs by paying a set price in USDC (IERC20 public usdcToken).
    * The function purchaseNFT(uint256 percentage) mints an NFT and assigns an ownership share.
4. Revenue Management:
    * The contract allows a designated revenueManager to update the total revenue (updateRevenue(uint256 amount)).
    * Revenue is stored in USDC and distributed proportionally to NFT holders based on their ownership share.
    * Owners can call distributeRevenue() to pay out earnings.
5. Burning NFTs:
    * Owners can burn their NFTs to remove their ownership (burn(uint256 tokenId)), updating the total ownership percentage.
6. Ownership Transfers:
    * NFT owners can transfer their tokens to others using transferOwnershipShare(address to, uint256 tokenId).
7. Access Control:
    * The contract includes ownership controls (Ownable) to restrict sensitive functions to the owner.
    * A revenue manager can be set or changed to handle revenue updates.
8. Royalty System:
    * Default royalty settings are established during deployment.
    * Ensures that royalties are paid on secondary sales using the _setDefaultRoyalty() function.

Key Functions:
1. purchaseNFT(uint256 percentage)
    * Allows users to buy an NFT with a specific ownership percentage.
    * Ensures that the total ownership does not exceed 100%.
2. updateRevenue(uint256 amount)
    * Updates the revenue balance by transferring USDC from the revenue manager to the contract.
3. distributeRevenue()
    * Distributes accumulated revenue proportionally to NFT holders.
4. getOwnershipPercentage(uint256 tokenId)
    * Retrieves the ownership percentage for a specific NFT.
5. burn(uint256 tokenId)
    * Removes an NFT from circulation and updates the total ownership calculation.
6. setRevenueManager(address newManager)
    * Allows the contract owner to change the revenue manager.
7. _baseURI()
    * Returns the base URI for token metadata.

Deployment Parameters:
When deploying the contract, the following parameters are required:
* name: Name of the NFT collection.
* symbol: Symbol for the NFT.
* baseTokenURI: Base URL for metadata storage.
* usdcAddress: USDC token contract address for payments.
* royaltyReceiver: Address to receive royalties.
* royaltyFeeNumerator: Royalty fee (e.g., 500 = 5%).
* pricePerNFT: Price per NFT in USDC.

Security Considerations:
* Reentrancy Protection: The contract uses nonReentrant to prevent reentrancy attacks on functions dealing with funds.
* Access Controls: Revenue updates are restricted to an authorized revenue manager or contract owner.
* Input Validation: Functions check percentage limits and payment failures to ensure data integrity.

Use Case in Your Context:
This contract aligns with your goal of representing master rights ownership for songs on Sound.xyz via NFTs. It allows:
1. Fractional ownership distribution through NFTs
2. Revenue tracking and automated USDC payouts to NFT holders
3. Easy transferability and burnability of ownership stakes
4. Integration with royalty mechanisms for secondary market earnings
