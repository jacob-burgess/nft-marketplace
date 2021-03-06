import { ethers } from 'ethers';
import { useEffect, useState } from 'react';
import { Image } from 'next/image';
import axios from 'axios';
import Web3Modal from "web3modal";

import { nftmarketaddress, nftaddress } from '../config';

import NFTMarket from '../artifacts/contracts/NFTMarket.sol/NFTMarket.json';
import NFT from '../artifacts/contracts/NFT.sol/NFT.json';

export default function MyAssets() {
    const [loading, setLoading] = useState('not-loading');
    const [nfts, setNfts] = useState([]);

    useEffect(() => {
        loadNFTs()
    }, []);

    async function loadNFTs() {
        const web3Modal = new Web3Modal();
        const connection = await web3Modal.connect();
        const provider = new ethers.providers.Web3Provider(connection);
        const signer = provider.getSigner();

        const tokenContract = new ethers.Contract(nftaddress, NFT.abi, provider);
        const marketContract = new ethers.Contract(nftmarketaddress, NFTMarket.abi, signer);

        const data = await marketContract.fetchMyNFTs();

        const items = await Promise.all(data.map(async i => {
            const tokenUri = await tokenContract.tokenURI(i.tokenId);
            const meta = await axios.get(tokenUri);
            let price = ethers.utils.formatUnits(i.price.toString(), 'ether');
            let item = {
                price,
                tokenId: i.tokenId.toNumber(),
                seller: i.seller,
                owner: i.owner,
                image: meta.data.image
            }
            return item;
        }));

        setNfts(items);
        setLoading('loaded');
    }

    if (loading === 'loaded' && !nfts.length) return (
        <h1 className="px-20 py-10 text-3xl">You dont have any NFTs, loser</h1>
    );

    return (
        <div className="flex justify-center">
          <div className="p-4">
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 pt-4">
              {
                nfts.map((nft, i) => (
                  <div key={i} className="border shadow rounded-xl overflow-hidden">
                    <Image src={nft.image} alt="Nifty image" className="rounded" />
                    <div className="p-4 bg-black">
                      <p className="text-2xl font-bold text-white">Price - {nft.price} Eth</p>
                    </div>
                  </div>
                ))
              }
            </div>
          </div>
        </div>
      )
}
