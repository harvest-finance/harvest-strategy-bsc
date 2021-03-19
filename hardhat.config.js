require("@nomiclabs/hardhat-etherscan");
require("@nomiclabs/hardhat-truffle5");

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      chainId: 56,
      forking: {
        url: "https://bsc-dataseed1.ninicoin.io/",
      },
    },
  },
  solidity: {
    compilers: [
      {version: "0.6.12",
       settings: {
         optimizer: {
           enabled: true,
           runs: 150
         }
       }},
    ]
  },
  mocha: {
    timeout: 2000000
  }
};
