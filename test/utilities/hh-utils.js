const makeVault = require("./make-vault.js");
const addresses = require("../test-config.js");
const IController = artifacts.require("IController");
const IFeeRewardForwarder = artifacts.require("IFeeRewardForwarder");
const IPancakeRouter02 = artifacts.require("IPancakeRouter02");
const IBEP20 = artifacts.require("IBEP20");
const WBNB = artifacts.require("WBNB")

const Utils = require("./Utils.js");

const Storage = artifacts.require("Storage");
const Controller = artifacts.require("Controller");
const FeeRewardForwarder = artifacts.require("FeeRewardForwarder");
const Vault = artifacts.require("Vault");

async function impersonates(targetAccounts){
  console.log("Impersonating...");
  for(i = 0; i < targetAccounts.length ; i++){
    console.log(targetAccounts[i]);
    await hre.network.provider.request({
      method: "hardhat_impersonateAccount",
      params: [
        targetAccounts[i]
      ]
    });
  }
}

async function setupCoreProtocol(config) {
  const storageNew = await Storage.new({from: config.governance});
  const feeRewardForwarderNew = await FeeRewardForwarder.new(storageNew.address, {from: config.governance});
  const controllerNew = await Controller.new(storageNew.address, feeRewardForwarderNew.address, {from: config.governance});
  await storageNew.setController(controllerNew.address,{from: config.governance});
  const vaultNew = await Vault.new({from: config.governance});

  // Set vault (or Deploy new vault), underlying, underlying Whale,
  // amount the underlying whale should send to farmers
  if(config.existingVaultAddress != null){
    vault = await Vault.at(config.existingVaultAddress);
    console.log("Fetching Vault at: ", vault.address);
  } else {
    const implAddress = config.vaultImplementationOverride || vaultNew.address;
    vault = await makeVault(implAddress, storageNew.address, config.underlying.address, 100, 100, {
      from: config.governance,
    });
    console.log("New Vault Deployed: ", vault.address);
  }

  controller = await IController.at(controllerNew.address);

  if (config.feeRewardForwarder) {/*
    const FeeRewardForwarder = artifacts.require("FeeRewardForwarder");
    const feeRewardForwarder = await FeeRewardForwarder.new(
      addresses.Storage,
      addresses.FARM,
      addresses.IFARM,
      addresses.UniversalLiquidatorRegistry
    );

    config.feeRewardForwarder = feeRewardForwarder.address;*/
    console.log("Setting up a custom fee reward forwarder...");
    await controller.setFeeRewardForwarder(
      config.feeRewardForwarder,
      { from: config.governance }
    );

    const NoMintRewardPool = artifacts.require("NoMintRewardPool");
    const farmRewardPool = await NoMintRewardPool.at("0x8f5adC58b32D4e5Ca02EAC0E293D35855999436C");
    await farmRewardPool.setRewardDistribution(config.feeRewardForwarder, {from: config.governance});

    console.log("Done setting up fee reward forwarder!");
  }

  let rewardPool = null;

  if (!config.rewardPoolConfig) {
    config.rewardPoolConfig = {};
  }
  // if reward pool is required, then deploy it
  if(config.rewardPool != null && config.existingRewardPoolAddress == null) {
    const rewardTokens = config.rewardPoolConfig.rewardTokens || [addresses.FARM];
    const rewardDistributions = [config.governance];
    if (config.feeRewardForwarder) {
      rewardDistributions.push(config.feeRewardForwarder);
    }

    if (config.rewardPoolConfig.type === 'PotPool') {
      const PotPool = artifacts.require("PotPool");
      console.log("reward pool needs to be deployed");
      rewardPool = await PotPool.new(
        rewardTokens,
        vault.address,
        64800,
        rewardDistributions,
        storageNew.address,
        "fPool",
        "fPool",
        18,
        {from: config.governance }
      );
      console.log("New PotPool deployed: ", rewardPool.address);
    } else {
      const NoMintRewardPool = artifacts.require("NoMintRewardPool");
      console.log("reward pool needs to be deployed");
      rewardPool = await NoMintRewardPool.new(
        rewardTokens[0],
        vault.address,
        64800,
        rewardDistributions,
        storageNew.address,
        "0x0000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000",
        {from: config.governance }
      );
      console.log("New NoMintRewardPool deployed: ", rewardPool.address);
    }
  } else if(config.existingRewardPoolAddress != null) {
    const NoMintRewardPool = artifacts.require("NoMintRewardPool");
    rewardPool = await NoMintRewardPool.at(config.existingRewardPoolAddress);
    console.log("Fetching Reward Pool deployed: ", rewardPool.address);
  }

  // default arguments are storage and vault addresses
  config.strategyArgs = config.strategyArgs || [
    storageNew.address,
    vault.address
  ];

  for(i = 0; i < config.strategyArgs.length ; i++){
    if(config.strategyArgs[i] == "storageAddr") {
      config.strategyArgs[i] = storageNew.address;
    } else if(config.strategyArgs[i] == "vaultAddr") {
      config.strategyArgs[i] = vault.address;
    } else if(config.strategyArgs[i] == "poolAddr" ){
      config.strategyArgs[i] = rewardPool.address;
    } else if(config.strategyArgs[i] == "universalLiquidatorRegistryAddr"){
      config.strategyArgs[i] = universalLiquidatorRegistry.address;
    }
  }

  if (!config.strategyArtifactIsUpgradable) {
    strategy = await config.strategyArtifact.new(
      ...config.strategyArgs,
      { from: config.governance }
    );
  } else {
    const strategyImpl = await config.strategyArtifact.new();
    const StrategyProxy = artifacts.require("StrategyProxy");

    const strategyProxy = await StrategyProxy.new(strategyImpl.address);
    strategy = await config.strategyArtifact.at(strategyProxy.address);
    await strategy.initializeStrategy(
      ...config.strategyArgs,
      { from: config.governance }
    );
  }

  console.log("Strategy Deployed: ", strategy.address);

  // if (config.feeRewardForwarderLiquidationPath) {
  //   // legacy path support
  //   const path = config.feeRewardForwarderLiquidationPath;
  //   await universalLiquidatorRegistry.setPath(
  //     web3.utils.keccak256("uni"),
  //     path[0],
  //     path[path.length - 1],
  //     path
  //   );
  // }

  if (config.announceStrategy === true) {
    // Announce switch, time pass, switch to strategy
    await vault.announceStrategyUpdate(strategy.address, { from: config.governance });
    console.log("Strategy switch announced. Waiting...");
    await Utils.waitHours(13);
    await vault.setStrategy(strategy.address, { from: config.governance });
    await vault.setVaultFractionToInvest(100, 100, { from: config.governance });
    console.log("Strategy switch completed.");
  } else {
    await controller.addVaultAndStrategy(
      vault.address,
      strategy.address,
      { from: config.governance }
    );
    console.log("Strategy and vault added to Controller.");
  }

  return [controller, vault, strategy, rewardPool, feeRewardForwarderNew];
}

async function depositVault(_farmer, _underlying, _vault, _amount) {
  await _underlying.approve(_vault.address, _amount, { from: _farmer });
  await _vault.deposit(_amount, { from: _farmer });
}

async function swapBNBToToken(_farmer, _path, _amountBNB) {
  router = await IPancakeRouter02.at("0x05fF2B0DB69458A0750badebc4f9e13aDd608C7F");
  await router.swapExactETHForTokens(
    0,
    _path,
    _farmer,
    Date.now() + 900000,
    { value:_amountBNB, from: _farmer });
}

async function wrapBNB(_farmer, _amount) {
  wbnb = await WBNB.at("0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c");
  await wbnb.deposit({value:_amount, from:_farmer});
}

async function addLiquidity(_farmer, _token0, _token1, _amount0, _amount1) {
  router = await IPancakeRouter02.at("0x05fF2B0DB69458A0750badebc4f9e13aDd608C7F");
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
}

module.exports = {
  impersonates,
  setupCoreProtocol,
  depositVault,
  swapBNBToToken,
  wrapBNB,
  addLiquidity
};
