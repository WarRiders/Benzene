require("@nomiclabs/hardhat-waffle");
//require('@eth-optimism/hardhat-ovm');
require("dotenv").config();

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

const forkBlockNumber = process.env.FORK_BLOCK_NUMBER;
const shouldFork =
  process.env.SHOULD_FORK.toLowerCase() === "true" ||
  process.env.SHOULD_FORK.toLowerCase() === "yes";

const hardhatNetwork = shouldFork
  ? {
      forking: {
        url: process.env.FORK_URL,
        blockNumber: forkBlockNumber,
      },
    }
  : {};

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: {
    version: '0.8.9',
    settings: {
      optimizer: {
        enabled: true,
        runs: 1000
      }
    }
  },
  networks: {
    hardhat: hardhatNetwork,
    kovan: {
      url: process.env.KOVAN_URL || "",
      accounts: {
        mnemonic: process.env.MNEMONIC,
      },
    },
    'optimistic-kovan': {
      chainId: 69,
      url: 'https://kovan.optimism.io',
      accounts: {
        mnemonic: process.env.MNEMONIC,
      },
      gasPrice: 10000,
    }
  },
};
