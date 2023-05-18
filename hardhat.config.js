require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */

const mnemonic = "";

module.exports = {
  networks: {
    hardhat: {
      accounts: { mnemonic: mnemonic },
    },
    bnb: {
      url: `https://data-seed-prebsc-1-s1.binance.org:8545/`,
      network_id: 97,
      confirmations: 1,
      gas: 20000000,
      timeoutBlocks: 20000000,
      skipDryRun: true,
      accounts: { mnemonic: mnemonic },
    },
    bnbMainNet: {
      url: `https://bsc-dataseed.binance.org`,
      network_id: 56,
      confirmations: 1,
      gas: 20000000,
      timeoutBlocks: 20000000,
      skipDryRun: true,
      accounts: { mnemonic: mnemonic },
    },
  },
  etherscan: {
    apiKey: "", //bnb
  },
  solidity: "0.8.0",
};
