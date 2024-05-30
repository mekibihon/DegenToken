# DegenToken

DegenToken is an ERC20 token contract that allows users to mint, transfer, burn tokens, and redeem tokens for non-fungible tokens (NFTs). The contract includes functionality for managing NFT types, limits, and claiming.

### Executing program

To run this program, you can use Remix, an online Solidity IDE. To get started, go to the Remix website at https://remix.ethereum.org/.

Once you are on the Remix website, create a new file by clicking on the "+" icon in the left-hand sidebar. Save the file with a .sol extension (e.g., DegenToken.sol). Copy and paste the following code into the file:

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract DegenToken is ERC20, Ownable, ERC20Burnable {

    mapping(address => uint256) private _claimedNFTs;

    enum NFTType {Gold, Silver, Bronze}

    struct NFT {
        uint256 value;
        uint256 limit;
        uint256 claimedCount;
    }

    mapping(uint256 => NFT) private _nfts;

    event NFTClaimed(address indexed recipient, NFTType nftType, uint256 amount);

    constructor() ERC20("Degen", "DGN") {
        _nfts[uint256(NFTType.Gold)] = NFT(100, 3, 0);
        _nfts[uint256(NFTType.Silver)] = NFT(50, 10, 0);
        _nfts[uint256(NFTType.Bronze)] = NFT(10, 12, 0);
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function transferTokens(address recipient, uint256 amount) external {
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        _transfer(_msgSender(), recipient, amount);
    }

    function checkBalance() external view returns(uint256) {
        return balanceOf(msg.sender);
    }

    function burnTokens(uint256 amount) external {
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        _burn(msg.sender, amount);
    }

    function claimNFT(NFTType nftType) external {
        uint256 tokenId = uint256(nftType);
        require(tokenId >= 0 && tokenId < 3, "Invalid selection.");

        NFT storage nft = _nfts[tokenId];
        require(nft.claimedCount < nft.limit, "NFT limit reached.");

        uint256 requiredAmount = nft.value;
        require(balanceOf(msg.sender) >= requiredAmount, "Insufficient balance.");

        _transfer(msg.sender, owner(), requiredAmount);
        _claimedNFTs[msg.sender] = tokenId;

        nft.claimedCount++;
        emit NFTClaimed(msg.sender, nftType, requiredAmount);
    }

    function getNFTClaimed(address recipient) external view returns (NFTType) {
        uint256 tokenId = _claimedNFTs[recipient];
        require(tokenId >= 0 && tokenId < 3, "No NFT claimed.");
        return NFTType(tokenId);
    }

    function getNFTStats(NFTType nftType) external view returns (uint256, uint256, uint256) {
        uint256 tokenId = uint256(nftType);
        require(tokenId >= 0 && tokenId < 3, "Invalid selection.");
        NFT storage nft = _nfts[tokenId];
        return (nft.value, nft.limit, nft.claimedCount);
    }
}

To compile the code, click on the "Solidity Compiler" tab in the left-hand sidebar. Make sure the "Compiler" option is set to "0.8.18" (or another compatible version), and then click on the "Compile DegenToken.sol" button.

Once the code is compiled, you can deploy the contract by clicking on the "Deploy & Run Transactions" tab in the left-hand sidebar. Select the "DegenToken.sol" contract from the dropdown menu, and then click on the "Deploy" button.

Once the contract is deployed, you can interact with it.

NAME: Mekael Bustos


## License

This project is licensed under the MIT License - see the LICENSE.md file for details
