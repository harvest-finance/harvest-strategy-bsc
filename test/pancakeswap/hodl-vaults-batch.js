// Utilities
const Utils = require("../utilities/Utils.js");
const {
  impersonates,
  setupCoreProtocol,
  depositVault,
  swapBNBToToken,
  addLiquidity
} = require("../utilities/hh-utils.js");

const addresses = require("../test-config.js");
const { send } = require("@openzeppelin/test-helpers");
const BigNumber = require("bignumber.js");
const IBEP20 = artifacts.require("IBEP20");

//const Strategy = artifacts.require("");
const StrategyBTCB = artifacts.require("PancakeHodlStrategyMainnet_BTCB_BNB");
const StrategyBUSD = artifacts.require("PancakeHodlStrategyMainnet_BUSD_BNB");
const StrategyCAKE = artifacts.require("PancakeHodlStrategyMainnet_CAKE_BNB");
const StrategyETH = artifacts.require("PancakeHodlStrategyMainnet_ETH_BNB");
const StrategyLINK = artifacts.require("PancakeHodlStrategyMainnet_LINK_BNB");
const StrategyUNI = artifacts.require("PancakeHodlStrategyMainnet_UNI_BNB");
const StrategyUSDT = artifacts.require("PancakeHodlStrategyMainnet_USDT_BNB");
const StrategyXVS = artifacts.require("PancakeHodlStrategyMainnet_XVS_BNB");

// Vanilla Mocha test. Increased compatibility with tools that integrate Mocha.
function test(underlyingAddr, token1Addr, Strategy){
  describe("Cake vault test", function() {
    let accounts;

    // external contracts
    let underlying;
    let fSushi;

    // external setup
    let wbnb = "0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c";

    // parties in the protocol
    let governance;
    let farmer1;

    // numbers used in tests
    let farmerBalance;

    // Core protocol contracts
    let controller;
    let vault;
    let strategy;

    async function setupExternalContracts() {
      underlying = await IBEP20.at(underlyingAddr);
      fCake = await IBEP20.at("0x3D5B0a8CD80e2A87953525fC136c33112E4b885a");
      console.log("Fetching Underlying at: ", underlying.address);
    }

    async function setupBalance(){
      token1 = await IBEP20.at(token1Addr);
      await swapBNBToToken(farmer1, [wbnb, token1.address], "100" + "000000000000000000");
      farmerToken1Balance = await token1.balanceOf(farmer1);
      await addLiquidity(farmer1, "BNB", token1, "100" + "000000000000000000", farmerToken1Balance);
      farmerBalance = await underlying.balanceOf(farmer1);
    }

    before(async function() {
      governance = "0xf00dD244228F51547f0563e60bCa65a30FBF5f7f";
      accounts = await web3.eth.getAccounts();

      farmer1 = accounts[1];

      // impersonate accounts
      await impersonates([governance]);

      await setupExternalContracts();
      [controller, vault, strategy, potPool] = await setupCoreProtocol({
        "existingVaultAddress": null,
        "strategyArtifact": Strategy,
        "strategyArtifactIsUpgradable": true,
        "underlying": underlying,
        "governance": governance,
        "rewardPool" : true,
        "rewardPoolConfig": {
          type: 'PotPool',
          rewardTokens: [
            "0x3D5B0a8CD80e2A87953525fC136c33112E4b885a" // fCake
          ]
        },
      });
      await strategy.setPotPool(potPool.address, {from: governance});
      await potPool.setRewardDistribution([strategy.address], true, {from: governance});
      console.log(await strategy.potPool());

      // whale send underlying to farmers
      await setupBalance();
    });

    describe("Happy path", function() {
      it("Farmer should earn money", async function() {
        let farmerOldBalance = new BigNumber(await underlying.balanceOf(farmer1));
        let farmerOldFCake = new BigNumber(await fCake.balanceOf(farmer1));

        await depositVault(farmer1, underlying, vault, farmerBalance);
        const vaultBalance = new BigNumber(await vault.balanceOf(farmer1));

        let erc20Vault = await IBEP20.at(vault.address);

        await erc20Vault.approve(potPool.address, vaultBalance, {from: farmer1});
        await potPool.stake(vaultBalance, {from: farmer1});

        // Using half days is to simulate how we doHardwork in the real world
        let hours = 10;
        let oldSharePrice;
        let newSharePrice;
        for (let i = 0; i < hours; i++) {
          console.log("loop ", i);
          let blocksPerHour = 2400;
          oldSharePrice = new BigNumber(await vault.getPricePerFullShare());
          await controller.doHardWork(vault.address, { from: governance });
          newSharePrice = new BigNumber(await vault.getPricePerFullShare());

          console.log("old shareprice: ", oldSharePrice.toFixed());
          console.log("new shareprice: ", newSharePrice.toFixed());
          console.log("growth: ", newSharePrice.toFixed() / oldSharePrice.toFixed());

          console.log("fCake in potpool: ", (new BigNumber(await fCake.balanceOf(potPool.address))).toFixed() );

          await Utils.advanceNBlock(blocksPerHour);
        }

        // withdrawAll to make sure no doHardwork is called when we do withdraw later.
        await vault.withdrawAll({ from: governance });

        // wait until all reward can be claimed by the farmer
        await Utils.waitTime(86400 * 30 * 1000);
        console.log("vaultBalance: ", vaultBalance.toFixed());
        await potPool.exit({from: farmer1});
        await vault.withdraw(vaultBalance.toFixed(), { from: farmer1 });
        let farmerNewBalance = new BigNumber(await underlying.balanceOf(farmer1));
        let farmerNewFCake = new BigNumber(await fCake.balanceOf(farmer1));
        Utils.assertBNEq(farmerNewBalance, farmerOldBalance);
        Utils.assertBNGt(farmerNewFCake, farmerOldFCake);

        console.log("potpool totalShare: ", (new BigNumber(await potPool.totalSupply())).toFixed());
        console.log("fCake in potpool: ", (new BigNumber(await fCake.balanceOf(potPool.address))).toFixed() );
        console.log("Farmer got fCake from potpool: ", farmerNewFCake.toFixed());
        console.log("earned!");
      });
    });
  });
}

// underlying, token1, artifact
test("0x7561EEe90e24F3b348E1087A005F78B4c8453524", "0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c", StrategyBTCB);
test("0x1B96B92314C44b159149f7E0303511fB2Fc4774f", "0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56", StrategyBUSD);
test("0xA527a61703D82139F8a06Bc30097cC9CAA2df5A6", "0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82", StrategyCAKE);
test("0x70D8929d04b60Af4fb9B58713eBcf18765aDE422", "0x2170Ed0880ac9A755fd29B2688956BD959F933F8", StrategyETH);
test("0xaeBE45E3a03B734c68e5557AE04BFC76917B4686", "0xF8A0BF9cF54Bb92F17374d9e9A321E6a111a51bD", StrategyLINK);
test("0x4269e7F43A63CEA1aD7707Be565a94a9189967E9", "0xBf5140A22578168FD562DCcF235E5D43A02ce9B1", StrategyUNI);
test("0x20bCC3b8a0091dDac2d0BC30F68E6CBb97de59Cd", "0x55d398326f99059fF775485246999027B3197955", StrategyUSDT);
test("0x41182c32F854dd97bA0e0B1816022e0aCB2fc0bb", "0xcF6BB5389c92Bdda8a3747Ddb454cB7a64626C63", StrategyXVS);
