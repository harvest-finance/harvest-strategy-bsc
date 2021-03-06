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
const Strategy = artifacts.require("PopsicleStrategtMainnet_ICE_BNBv2");


// Vanilla Mocha test. Increased compatibility with tools that integrate Mocha.
describe("BSC Mainnet Popsicle ICE/BNB V2", function() {
  let accounts;

  // external contracts
  let underlying;

  // external setup
  let wbnb = "0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c";
  let iceAddr = "0xf16e81dce15B08F326220742020379B855B87DF9";
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
    underlying = await IBEP20.at("0x51F914a192a97408D991FddDAFB8F8537C5Ffb0a");
    console.log("Fetching Underlying at: ", underlying.address);
  }

  async function setupBalance(){
    ice = await IBEP20.at(iceAddr);
    router = await IPancakeRouter02.at("0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506"); //sushi router
    await router.swapExactETHForTokens(
      0,
      [wbnb, iceAddr],
      farmer1,
      Date.now() + 900000,
      { value:"100" + "000000000000000000", from: farmer1 });
    farmerIceBalance = await ice.balanceOf(farmer1);
    _farmer = farmer1;
    _token0 = "BNB";
    _token1 = ice;
    _amount0 = "100" + "000000000000000000";
    _amount1 = farmerIceBalance;
    if (_token0 == "BNB") {
      wrapBNB(_farmer, _amount0);
      _token0 = await IBEP20.at("0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c");
    }
    await _token0.approve(router.address, _amount0, { from:_farmer});
    await _token1.approve(router.address, _amount1, { from:_farmer});
    await router.addLiquidity(
      _token0.address,
      _token1.address,
      _amount0,
      _amount1,
      0,
      0,
      _farmer,
      Date.now() + 900000,
      { from: _farmer });
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

    oldStrategy = await Strategy.at("0xBcDf4EAec6166b94e54e2b1F0A4C2c30Cea834CA");
    await oldStrategy.setSellFloor(1, {from:governance});

    await setupExternalContracts();
    [controller, vault, strategy] = await setupCoreProtocol({
      "existingVaultAddress": "0x1c4ADFf419F6b91E51D0aDe953C9BBf5D16A583F",
      "strategyArtifact": Strategy,
      "announceStrategy": true,
      "strategyArtifactIsUpgradable": true,
      "underlying": underlying,
      "governance": governance,
    });

    await strategy.setSellFloor(1, {from:governance});

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
