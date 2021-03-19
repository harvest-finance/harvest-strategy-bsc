# Binance Smart Chain: Harvest Strategy Development

This [Hardhat](https://hardhat.org/) environment is configured to use Mainnet fork by default and provides templates and utilities for strategy development and testing.

## Installation

1. Run `npm install` to install all the dependencies.

## Run

All tests are located under the `test` folder.

1. Run `npx hardhat test [test file location]`: `npx hardhat test ./test/pancakeswap/cake.js`. This will produce the following output:
  ```
      BSC Mainnet Pancake CAKE
  Impersonating...
  0xf00dD244228F51547f0563e60bCa65a30FBF5f7f
  0x863c2d2b24c405f00a8051a53a7a895c71ba4aa3
  Fetching Underlying at:  0xA527a61703D82139F8a06Bc30097cC9CAA2df5A6
  Vault governance: 0xf00dD244228F51547f0563e60bCa65a30FBF5f7f
  Vault controller: 0xEF08A639cAc2009fdAD3773CC9F56D6a8feB1153
  New Vault Deployed:  0xF8ce90c2710713552fb564869694B2505Bfc0846
  Strategy Deployed:  0x4ed7c70F96B99c776995fB64377f0d4aB3B0e1C1
  Strategy and vault added to Controller.
      Happy path
  loop  0
  old shareprice:  1000000000000000000
  new shareprice:  1000000000000000000
  growth:  1
  loop  1
  old shareprice:  1000000000000000000
  new shareprice:  1000160008271341407
  growth:  1.0001600082713415
  loop  2
  old shareprice:  1000160008271341407
  new shareprice:  1000320154120072702
  growth:  1.0001601202281702
  loop  3
  old shareprice:  1000320154120072702
  new shareprice:  1000480325663279196
  growth:  1.0001601202800392
  loop  4
  old shareprice:  1000480325663279196
  new shareprice:  1000640522826689802
  growth:  1.0001601202535435
  loop  5
  old shareprice:  1000640522826689802
  new shareprice:  1000800745614401603
  growth:  1.0001601202270514
  loop  6
  old shareprice:  1000800745614401603
  new shareprice:  1000960994030446757
  growth:  1.0001601202004968
  loop  7
  old shareprice:  1000960994030446757
  new shareprice:  1001121268078918229
  growth:  1.0001601201739403
  loop  8
  old shareprice:  1001121268078918229
  new shareprice:  1001281567763969927
  growth:  1.0001601201474415
  loop  9
  old shareprice:  1001281567763969927
  new shareprice:  1001441893089635973
  growth:  1.0001601201208807
  earned!
        √ Farmer should earn money (45407ms)

    1 passing (1m)
  ```

## Develop

Under `contracts/strategies`, there are plenty of examples to choose from in the repository already, therefore, creating a strategy is no longer a complicated task. Copy-pasting existing strategies with minor modifications is acceptable.

Under `contracts/base`, there are existing base interfaces and contracts that can speed up development.
Base contracts currently exist for developing SNX and MasterChef-based strategies.

Note that the Universal Liquidator will not be available on BSC until a later stage of this project.

## Contribute

When ready, open a pull request with the following information:
1. Instructions on how to run the test and at which block number
2. A **mainnet fork test output** (like the one above in the README) clearly showing the increases of share price
3. Info about the protocol, including:
   - Live farm page(s)
   - GitHub link(s)
   - Etherscan link(s)
   - Start/end dates for rewards
   - Any limitations (e.g., maximum pool size)
   - Current pool sizes used for liquidation (to make sure they are not too shallow)

   The first few items can be omitted for well-known protocols (such as `curve.fi`).

5. A description of **potential value** for Harvest: why should your strategy be live? High APYs, decent pool sizes, longevity of rewards, well-secured protocols, high-potential collaborations, etc.

## Deployment

If your pull request is merged and given a green light for deployment, the Harvest team will take care of on-chain deployment.
