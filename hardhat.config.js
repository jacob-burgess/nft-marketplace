require("@nomiclabs/hardhat-waffle");
const fs = require("fs");

// private key for account read in from .secret file
const privateKey = fs.readFileSync(".secret").toString();

// put projectID here!
const projectId = "";

module.exports = {
  // we can deploy to both polygons's networks (main, mumbai) 
  // https://docs.matic.network/docs/develop/network-details/network
  networks: {
    hardhat: {
      chainId: 1337 //specific to hardhat docs
      // hardhat makes accounts for you locally
    },
    mumbai: {
      url: `https://polygon-mumbai.infura.io/v3/${projectId}`,
      accounts: [privateKey]
    },
    mainnet: {
      url: `https://polygon-mainnet.infura.io/v3/${projectId}`,
      accounts: [privateKey]
    }
  },
  solidity: "0.8.4",
};
