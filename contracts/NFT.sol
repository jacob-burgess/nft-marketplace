// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "hardhat/console.sol";

// ERC721URIStorage inherits from ERC721
contract NFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // address of the marketplace that we want to interact with
    address contractAddress;

    constructor(address marketplaceAddress) ERC721("NiftyBoogie", "NFB") {
        contractAddress = marketplaceAddress;
    }

    function createToken(string memory tokenURI) public returns (uint) {

        // first token will be '1'
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();

        // mint a new token with the owner as the address that invoked this function
        // and the id the  next in the counter
        _mint(msg.sender, newItemId);
        // The string passed to the function will be the uri mapped to this id
        _setTokenURI(newItemId, tokenURI);

        // allows the contract address (Marketplace) to access/exchange these tokens between users
        setApprovalForAll(contractAddress, true);
        return newItemId;
    }
}
