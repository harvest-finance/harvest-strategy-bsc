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
const IMooniswap = artifacts.require("IMooniswap");

//const Strategy = artifacts.require("");
const Strategy = artifacts.require("OneInchStrategyMainnet_1INCH_BNB");


// Vanilla Mocha test. Increased compatibility with tools that integrate Mocha.
describe("BSC Mainnet 1INCH 1INCH/BNB", function() {
  let accounts;

  // external contracts
  let underlying;

  // external setup
  let wbnb = "0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c";
  let oneInchAddr = "0x111111111117dC0aa78b770fA6A738034120C302";
  let eth = "0x2170Ed0880ac9A755fd29B2688956BD959F933F8";
  let zeroAddr = "0x0000000000000000000000000000000000000000";

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
    underlying = await IBEP20.at("0xdaF66c0B7e8E2FC76B15B07AD25eE58E04a66796");
    console.log("Fetching Underlying at: ", underlying.address);
  }

  async function setupBalance(){
    oneInch = await IBEP20.at(oneInchAddr);
    pair = await IMooniswap.at(underlying.address);
    await pair.swap(zeroAddr, oneInchAddr, "100" + "000000000000000000", 0, zeroAddr, {from: farmer1, value: "100" + "000000000000000000"})
    farmerOneInchBalance = await oneInch.balanceOf(farmer1);
    await oneInch.approve(pair.address, farmerOneInchBalance, {from: farmer1});
    await pair.deposit(
      ["100" + "000000000000000000", farmerOneInchBalance],
      [0,0],
      {
        from: farmer1,
        value: "100" + "000000000000000000"
      }
    );
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
      "underlying": underlying,
      "governance": governance,
    });

    await strategy.setSellFloorAndSlippages(0, 1, 10, {from:governance});
    await feeForwarder.setConversionPath(wbnb, eth, [wbnb, eth], {from:governance});

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
