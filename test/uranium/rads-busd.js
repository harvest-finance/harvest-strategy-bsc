// Utilities
const Utils = require("../utilities/Utils.js");
const {
  impersonates,
  setupCoreProtocol,
  depositVault,
  swapBNBToToken,
  addLiquidity
} = require("../utilities/hh-utils.js");

const { send } = require("@openzeppelin/test-helpers");
const BigNumber = require("bignumber.js");
const IBEP20 = artifacts.require("IBEP20");
const IPancakeRouter02 = artifacts.require("IPancakeRouter02");

//const Strategy = artifacts.require("");
const Strategy = artifacts.require("UraniumStrategyMainnet_RADS_BUSD");


// Vanilla Mocha test. Increased compatibility with tools that integrate Mocha.
describe("BSC Mainnet Uranium RADS/BUSD", function() {
  let accounts;

  // external contracts
  let underlying;

  // external setup
  let wbnb = "0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c";
  let radsAddr = "0x670De9f45561a2D02f283248F65cbd26EAd861C8";
  let sRadsAddr= "0x28d2E3BB1Ec54A6eE8b3Bee612F03A85d3Ec0C0c";
  let busdAddr = "0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56";
  let eth = "0x2170Ed0880ac9A755fd29B2688956BD959F933F8";

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
    underlying = await IBEP20.at("0xA08c4571b395f81fBd3755d44eaf9a25C9399a4a");
    console.log("Fetching Underlying at: ", underlying.address);
  }

  async function setupBalance(){
    rads = await IBEP20.at(radsAddr);
    busd = await IBEP20.at(busdAddr);

    router = await IPancakeRouter02.at("0xF4EE46Ac2BA83121F79c778ed0D950ffF11a18Ed");
    await router.swapExactETHForTokens(
      0,
      [wbnb, radsAddr],
      farmer1,
      Date.now() + 900000,
      { value:"100" + "000000000000000000", from: farmer1 });

    await swapBNBToToken(farmer1, [wbnb, busd.address], "100" + "000000000000000000");

    farmerRadsBalance = await rads.balanceOf(farmer1);
    farmerBusdBalance = await busd.balanceOf(farmer1);

    router = await IPancakeRouter02.at("0xF4EE46Ac2BA83121F79c778ed0D950ffF11a18Ed");
    await rads.approve(router.address, farmerRadsBalance, { from:farmer1});
    await busd.approve(router.address, farmerBusdBalance, { from:farmer1});
    await router.addLiquidity(
      rads.address,
      busd.address,
      farmerRadsBalance,
      farmerBusdBalance,
      0,
      0,
      farmer1,
      Date.now() + 900000,
      { from: farmer1 });

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
      "liquidationPath": [busdAddr, wbnb, eth],
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