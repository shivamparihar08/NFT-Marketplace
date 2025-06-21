// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFTMarketplace is ERC721URIStorage {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;

    struct ListedNFT {
        uint256 tokenId;
        address payable owner;
        uint256 price;
        bool isListed;
    }

    mapping(uint256 => ListedNFT) public listedNFTs;

    constructor() ERC721("CoreNFT", "CNFT") {}

    function mintNFT(string memory tokenURI, uint256 price) external {
        require(price > 0, "Price must be greater than zero");
        _tokenIds.increment();

        uint256 newTokenId = _tokenIds.current();
        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI);

        listedNFTs[newTokenId] = ListedNFT({
            tokenId: newTokenId,
            owner: payable(msg.sender),
            price: price,
            isListed: true
        });
    }

    function buyNFT(uint256 tokenId) external payable {
        ListedNFT storage nft = listedNFTs[tokenId];
        require(nft.isListed, "NFT not for sale");
        require(msg.value >= nft.price, "Insufficient payment");

        nft.owner.transfer(msg.value);
        _transfer(nft.owner, msg.sender, tokenId);
        nft.owner = payable(msg.sender);
        nft.isListed = false;
    }

    function relistNFT(uint256 tokenId, uint256 newPrice) external {
        ListedNFT storage nft = listedNFTs[tokenId];
        require(ownerOf(tokenId) == msg.sender, "Not the owner");
        require(newPrice > 0, "Price must be greater than zero");

        nft.price = newPrice;
        nft.isListed = true;
    }
}
