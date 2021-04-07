// Utilities
const Utils = require("../utilities/Utils.js");
const {
  impersonates,
  setupCoreProtocol,
  depositVault,
  swapBNBToToken,
  addLiquidity,
  wrapBNB
} = require("../utilities/hh-utils.js");

const { send } = require("@openzeppelin/test-helpers");
const BigNumber = require("bignumber.js");
const IBEP20 = artifacts.require("IBEP20");
const IPancakeRouter02 = artifacts.require("IPancakeRouter02");

//const Strategy = artifacts.require("");
const Strategy = artifacts.require("UraniumStrategyMainnet_RADS_BNB");


// Vanilla Mocha test. Increased compatibility with tools that integrate Mocha.
describe("BSC Mainnet Uranium RADS/BNB", function() {
  let accounts;

  // external contracts
  let underlying;

  // external setup
  let wbnbAddr = "0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c";
  let radsAddr = "0x7ca1eBC56496E3D78E56D71A127ea9d1717c4bE0";
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
    underlying = await IBEP20.at("0x19b6E14D62bf222add5f1D47fCb56Dd973029d00");
    console.log("Fetching Underlying at: ", underlying.address);
  }

  async function setupBalance(){
    rads = await IBEP20.at(radsAddr);
    wbnb = await IBEP20.at(wbnbAddr);

    router = await IPancakeRouter02.at("0x9a04b598CA32D3e9CDF366f34B2B4d41EF5f027F");
    await router.swapExactETHForTokens(
      0,
      [wbnbAddr, radsAddr],
      farmer1,
      Date.now() + 900000,
      { value:"100" + "000000000000000000", from: farmer1 });

    await wrapBNB(farmer1, "100" + "000000000000000000");

    farmerRadsBalance = await rads.balanceOf(farmer1);
    farmerWbnbBalance = await wbnb.balanceOf(farmer1);

    router = await IPancakeRouter02.at("0x9a04b598CA32D3e9CDF366f34B2B4d41EF5f027F");
    await rads.approve(router.address, farmerRadsBalance, { from:farmer1});
    await wbnb.approve(router.address, farmerWbnbBalance, { from:farmer1});
    await router.addLiquidity(
      rads.address,
      wbnb.address,
      farmerRadsBalance,
      farmerWbnbBalance,
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
    [controller, vault, strategy,,feeForwarder] = await setupCoreProtocol({
      "existingVaultAddress": null,
      "strategyArtifact": Strategy,
      "strategyArtifactIsUpgradable": true,
      "underlying": underlying,
      "governance": governance,
    });

    await strategy.setSellFloor(0, {from:governance});
    await feeForwarder.setConversionPath(wbnbAddr, eth, [wbnbAddr, eth], {from:governance});

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
