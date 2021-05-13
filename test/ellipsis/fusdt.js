// Utilities
const Utils = require("../utilities/Utils.js");
const {
  impersonates,
  setupCoreProtocol,
  depositVault,
  swapBNBToToken
} = require("../utilities/hh-utils.js");

const { send } = require("@openzeppelin/test-helpers");
const BigNumber = require("bignumber.js");
const IBEP20 = artifacts.require("IBEP20");
const ILiquidityPool = artifacts.require("IFUSDTPoolDeposit");

//const Strategy = artifacts.require("");
const Strategy = artifacts.require("EllipsisFUSDTStrategyMainnet");


// Vanilla Mocha test. Increased compatibility with tools that integrate Mocha.
describe("BSC Mainnet Ellipsis FUSDT", function() {
  let accounts;

  // external contracts
  let underlying;

  // external setup
  let eps = "0xA7f552078dcC247C2684336020c03648500C6d9F";
  let eth = "0x2170Ed0880ac9A755fd29B2688956BD959F933F8";
  let wbnb = "0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c";
  let busdAddr = "0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56";
  let depositorAddr = "0xf17814d515d3128753befd56cCeCEC2a0A41015F";

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
    underlying = await IBEP20.at("0x373410A99B64B089DFE16F1088526D399252dacE");
    console.log("Fetching Underlying at: ", underlying.address);
  }

  async function setupBalance(){
    busd = await IBEP20.at(busdAddr);
    liquidityPool = await ILiquidityPool.at(depositorAddr);
    await swapBNBToToken(farmer1, [wbnb, busdAddr], "100" + "000000000000000000", true);
    farmerBusdBalance = await busd.balanceOf(farmer1);
    await busd.approve(depositorAddr, farmerBusdBalance, {from: farmer1});
    await liquidityPool.add_liquidity([0, farmerBusdBalance, 0, 0], 0, {from: farmer1});
    farmerBalance = await underlying.balanceOf(farmer1);
  }

  before(async function() {
    governance = "0xf00dD244228F51547f0563e60bCa65a30FBF5f7f";
    accounts = await web3.eth.getAccounts();

    farmer1 = accounts[1];

    // impersonate accounts
    await impersonates([governance]);

    let etherGiver = accounts[9];
    await send.ether(etherGiver, governance, "100" + "000000000000000000")

    await setupExternalContracts();
    [controller, vault, strategy] = await setupCoreProtocol({
      "existingVaultAddress": null,
      "strategyArtifact": Strategy,
      "strategyArtifactIsUpgradable": true,
      "underlying": underlying,
      "governance": governance,
    });

    await strategy.setSellFloor(0, {from:governance});

    // whale send underlying to farmers
    await setupBalance();
  });

  describe("Happy path", function() {
    it("Farmer should earn money", async function() {
      let farmerOldBalance = new BigNumber(await underlying.balanceOf(farmer1));
      await depositVault(farmer1, underlying, vault, farmerBalance);

      // Using half days is to simulate how we doHardwork in the real world
      let hours = 10;
      let blocksPerHour = 2400;
      let oldSharePrice;
      let newSharePrice;
      for (let i = 0; i < hours; i++) {
        console.log("loop ", i);

        oldSharePrice = new BigNumber(await vault.getPricePerFullShare());
        await controller.doHardWork(vault.address, { from: governance });
        newSharePrice = new BigNumber(await vault.getPricePerFullShare());

        console.log("old shareprice: ", oldSharePrice.toFixed());
        console.log("new shareprice: ", newSharePrice.toFixed());
        console.log("growth: ", newSharePrice.toFixed() / oldSharePrice.toFixed());

        await Utils.advanceNBlock(blocksPerHour);
      }
      await vault.withdraw(new BigNumber(await vault.balanceOf(farmer1)).toFixed(), { from: farmer1 });
      let farmerNewBalance = new BigNumber(await underlying.balanceOf(farmer1));
      Utils.assertBNGt(farmerNewBalance, farmerOldBalance);

      apr = (farmerNewBalance.toFixed()/farmerOldBalance.toFixed()-1)*(24/(blocksPerHour*hours/1200))*365;
      apy = ((farmerNewBalance.toFixed()/farmerOldBalance.toFixed()-1)*(24/(blocksPerHour*hours/1200))+1)**365;

      console.log("earned!");
      console.log("APR:", apr*100, "%");
      console.log("APY:", (apy-1)*100, "%");

      await strategy.withdrawAllToVault({from:governance}); // making sure can withdraw all for a next switch

    });
  });
});
