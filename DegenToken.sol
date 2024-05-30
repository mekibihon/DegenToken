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
