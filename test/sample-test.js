const { expect } = require("chai");

describe("NFTMarket", function () {
  it("Should create and execute market sales", async function () {
    const Market = await ethers.getContractFactory("NFTMarket");
    const market = await Market.deploy();
    await market.deployed();
    const marketAddress = market.address;

    const NFT = await ethers.getContractFactory("NFT");
    const nft = await NFT.deploy(marketAddress);
    await nft.deployed();
    const nftAddress = nft.address;

    let listingPrice = await market.getListingPrice();
    listingPrice = listingPrice.toString();

    const auctionPrice = ethers.utils.parseUnits('100', 'ether');

    await nft.createToken("https://www.mytokenlocation.com");
    await nft.createToken("https://www.mytokenlocation2.com");

    await market.createMarketItem(nftAddress, 1, auctionPrice, { value: listingPrice });
    await market.createMarketItem(nftAddress, 2, auctionPrice, { value: listingPrice });

    // can get test accounts from ethers... this array could be longer
    // by default if we are deploying, the first address in this array is used
    // so th  '_' is the address that deployed these contracts which we are ignoring
    // we want a different address to be the test buyer
    const [_, buyerAddress] = await ethers.getSigners();

    // connect to the market using the buyer address 
    await market.connect(buyerAddress).createMarketSale(nftAddress, 1, { value: auctionPrice });

    let items = await market.fetchMarketItems();

    items = await Promise.all(items.map(async i => {
      const tokenUri = await nft.tokenURI(i.tokenId);
      let item = {
        marketItemId: i.marketItemId.toString(),
        nftContractAddress: i.nftContract,
        tokenId: i.tokenId.toString(),
        price: i.price.toString(),
        seller: i.seller,
        owner: i.owner,
        tokenUri,
        sold: i.sold
      }
      return item;
    }));

    console.log('items: ', items);

  });
});
