pragma solidity 0.6.12;

import "./BeltVenusStrategy.sol";

contract BeltVenusStrategyMainnet is BeltVenusStrategy {

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address underlying = address(0x86aFa7ff694Ab8C985b79733745662760e454169);
    address belt = address(0xE0e514c71282b6f4e823703a39374Cf58dc3eA4f);
    address wbnb = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    address depositHelp = address(0xf157A4799bE445e3808592eDd7E7f72150a7B050);
    BeltVenusStrategy.initializeStrategy(
      _storage,
      underlying,
      _vault,
      address(0xD4BbC80b9B102b77B21A06cb77E954049605E6c1), // stakingPool
      belt,
      depositHelp,
      0  // Pool id
    );
    pancake_BELT2BUSD = [belt, wbnb, busd];
  }
}
