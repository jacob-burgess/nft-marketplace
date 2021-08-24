// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "hardhat/console.sol";

// ReentrantGuard is for security purposes.
// We want to use it in any function that talks to another conrtact
contract NFTMarket is ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _marketItemIds;
    Counters.Counter private _itemsSold;

    address payable owner;

    // gets confusing bc we're deploying to Matic... so this evaluates to Matic, not ether
    uint256 listingPrice = 0.025 ether;

    // The owner of this contract (Marketplace) is the one who deploys it
    constructor() {
        owner = payable(msg.sender);
    }

    struct MarketItem {
        uint marketItemId;       // Id given from marketplace
        address nftContract;     // type of NFT
        uint256 tokenId;         // Id given from NFT contract
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;               // true if sold
    }

    // get a market item by its marketItemId
    mapping(uint256 => MarketItem) private idToMarketItem;

    // will emit upon MarketItem creation
    event MarketItemCreated (
        uint indexed marketItemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold
    );

    /* Returns the listing price of the contract */
    function getListingPrice() public view returns (uint256) {
        return listingPrice;
    }

    /* Places an item for sale on the marketplace */
    // nftContract = contract address for the nft
    // tokenId = the specific Id for the NFT token
    // price = sale price desired by user
    function createMarketItem(address nftContract, uint256 tokenId, uint256 price) public payable nonReentrant {
        require(price > 0, "Price must be at least 1 wei");

        // if this request was not sent with the $$, no bueno
        require(msg.value == listingPrice, "Price must be equal to listing price");

        _marketItemIds.increment();
        uint256 marketItemId = _marketItemIds.current();

        // create a new MarketItem that can be fetched by its marketItemId
        idToMarketItem[marketItemId] = MarketItem(
            marketItemId,
            nftContract,
            tokenId,
            payable(msg.sender),
            payable(address(0)), // nobody owns this now, its up for sale
            price,
            false
        );

        // ownership of the specific token of this NFT transfers from the seller to the contract
        // the 'setApprovalForAll()' from the NFT contract allows this contract to do this
        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

        // emit event
        emit MarketItemCreated(
            marketItemId,
            nftContract,
            tokenId,
            msg.sender,
            address(0),
            price,
            false
        );
    }

    /* Creates the sale of a marketplace item */
    /* Transfers ownership of the item, as well as funds between parties */
    // nftContract = contract address for the nft
    // marketItemId = the marketItem wished to purchase
    function createMarketSale(address nftContract, uint256 marketItemId) public payable nonReentrant {
        uint price = idToMarketItem[marketItemId].price;
        uint tokenId = idToMarketItem[marketItemId].tokenId;
        require(msg.value == price, "Please submit the asking price in order to complete the purchase");

        // Give the sale price to the seller
        idToMarketItem[marketItemId].seller.transfer(msg.value);

        // ownership of the token goes from this contract to the buyer
        IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);

        // locally track who owns this NFT now
        idToMarketItem[marketItemId].owner = payable(msg.sender);
        idToMarketItem[marketItemId].sold = true;
        _itemsSold.increment();

        // owner of this contract (marketplace) gets the commission
        payable(owner).transfer(listingPrice);
    }

    /* Returns the balance in this contract. This will be equivalent to the value that
       the owner of this marketplace would recieve if all items got sold
       (i.e. listingPrice * unsoldItemCount) */
    function fetchContractBalance() public view returns (uint) {
        return address(this).balance;
    }


    /* Returns all unsold market items */
    function fetchMarketItems() public view returns (MarketItem[] memory) {
        uint itemCount = _marketItemIds.current();
        uint unsoldItemCount = _marketItemIds.current() - _itemsSold.current();
        uint currentIndex = 0;

        MarketItem[] memory items = new MarketItem[](unsoldItemCount);
        for (uint i = 0; i < itemCount; i++) {
            if (idToMarketItem[i+1].owner == address(0)) {
                MarketItem storage currentItem = idToMarketItem[i+1];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    /* Returns only items that a user has purchased */
    function fetchMyNFTs() public view returns (MarketItem[] memory) {
        uint totalItemCount = _marketItemIds.current();
        uint itemCount = 0;
        uint currentIndex = 0;

        for (uint i = 0; i < totalItemCount; i++) {
                if (idToMarketItem[i+1].owner == msg.sender) {
                    itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i+1].owner == msg.sender) {
                MarketItem storage currentItem = idToMarketItem[i+1];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    /* Returns only items a user has created */
    function fetchItemsCreated() public view returns (MarketItem[] memory) {
        uint totalItemCount = _marketItemIds.current();
        uint itemCount = 0;
        uint currentIndex = 0;

        for (uint i = 0; i < totalItemCount; i++) {
                if (idToMarketItem[i+1].seller == msg.sender) {
                    itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint i = 0; i < totalItemCount; i++) {
                if (idToMarketItem[i+1].seller == msg.sender) {
                    MarketItem storage currentItem = idToMarketItem[i+1];
                    items[currentIndex] = currentItem;
                    currentIndex += 1;
            }
        }
        return items;
    }
}
