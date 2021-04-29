// Utilities
const Utils = require("../utilities/Utils.js");
const {
  impersonates,
  setupCoreProtocol,
  depositVault,
  swapBNBToToken
} = require("../utilities/hh-utils.js");

const ethers = require("ethers");

const { send } = require("@openzeppelin/test-helpers");
const BigNumber = require("bignumber.js");
const IBEP20 = artifacts.require("IBEP20");

//const Strategy = artifacts.require("");
const Strategy = artifacts.require("VenusVAIStrategyMainnet");


// Vanilla Mocha test. Increased compatibility with tools that integrate Mocha.
describe("BSC Mainnet Venus VAI", function() {
  let accounts;

  // external contracts
  let underlying;

  // external setup
  let wbnb = "0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c";
  let busd = "0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56";
  let xvsDistributor = "0x631Fc1EA2270e98fbD9D92658eCe0F5a269Aa161";

  // parties in the protocol
  let governance;
  let farmer1;

  // numbers used in tests
  let farmerBalance;

  // Core protocol contracts
  let controller;
  let vault;
  let strategy;

  let venus = "0xcF6BB5389c92Bdda8a3747Ddb454cB7a64626C63";
  let vvaiVault = "0x0667Eed0a0aAb930af74a3dfeDD263A73994f216";

  async function setupExternalContracts() {
    underlying = await IBEP20.at("0x4BD17003473389A42DAF6a0a729f6Fdb328BbBd7");
    console.log("Fetching Underlying at: ", underlying.address);
  }

  async function setupBalance(){
    await swapBNBToToken(farmer1, [wbnb, busd, underlying.address], "100" + "000000000000000000", true);
    farmerBalance = await underlying.balanceOf(farmer1);
  }

  before(async function() {
    governance = "0xf00dD244228F51547f0563e60bCa65a30FBF5f7f";
    accounts = await web3.eth.getAccounts();

    farmer1 = accounts[1];

    // impersonate accounts
    await impersonates([governance, xvsDistributor]);

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

      let venusToken = await IBEP20.at(venus);

      // Using half days is to simulate how we doHardwork in the real world
      let hours = 10;
      let blocksPerHour = 2400;
      let oldSharePrice;
      let newSharePrice;
      let distributionAmount = 1250/(24*1200)*blocksPerHour;
      let distributionAmountBN = ethers.utils.parseEther(distributionAmount.toString())
      for (let i = 0; i < hours; i++) {
        console.log("loop ", i);

        await venusToken.approve(vvaiVault, distributionAmountBN, {from:xvsDistributor});
        await venusToken.transfer(vvaiVault, distributionAmountBN, {from:xvsDistributor});

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

    });
  });
});
