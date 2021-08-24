

## Getting Started

First, let's run the blockchain node using hardhats command. From the base directory, run:

```npx hardhat node```

Now that we have a node up and running, we can deploy our two solidity contracts:

```npx hardhat run scripts/deploy.js --environment localhost```

Before running the web application, it is important that you copy the address that each of the two contracts was deployed to and paste them into their corresponding variables in the ```config.js``` file.

Lastly, we need to start the development server. To do this, run thefollowing command:

```npm run dev```

Create some NFTs!
