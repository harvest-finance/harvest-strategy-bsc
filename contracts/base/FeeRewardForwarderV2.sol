// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "./inheritance/Governable.sol";
import "./interface/IRewardPool.sol";
import "@pancakeswap/pancake-swap-lib/contracts/token/BEP20/SafeBEP20.sol";
import "@pancakeswap/pancake-swap-lib/contracts/token/BEP20/IBEP20.sol";
import "@pancakeswap/pancake-swap-lib/contracts/math/SafeMath.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

// FeeRewardForwarder with no grain config
contract FeeRewardForwarderV2 is Governable {
  using SafeBEP20 for IBEP20;
  using SafeMath for uint256;

  // yield farming
  address constant public cake = address(0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82);
  address constant public xvs = address(0xcF6BB5389c92Bdda8a3747Ddb454cB7a64626C63);
  address constant public egg = address(0xF952Fc3ca7325Cc27D15885d37117676d25BfdA6);
  address constant public sbdo = address(0x0d9319565be7f53CeFE84Ad201Be3f40feAE2740);
  address constant public space = address(0x0abd3E3502c15ec252f90F64341cbA74a24fba06);
  address constant public belt = address(0xE0e514c71282b6f4e823703a39374Cf58dc3eA4f);
  address constant public eps = address(0xA7f552078dcC247C2684336020c03648500C6d9F);
  // wbnb
  address constant public wbnb = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
  address constant public busd = address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
  address constant public eth = address(0x2170Ed0880ac9A755fd29B2688956BD959F933F8);

  mapping (address => mapping (address => address[])) public routes;
  mapping (address => mapping (address => address)) public routers;

  address constant public pancakeswapRouterOld = address(0x05fF2B0DB69458A0750badebc4f9e13aDd608C7F);
  address constant public pancakeswapRouterNew = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);

  // the targeted reward token to convert everything to
  address public targetToken = eth;
  address public profitSharingPool;

  event TokenPoolSet(address token, address pool);

  constructor(address _storage) public Governable(_storage) {
    profitSharingPool = governance();

    routes[cake][eth] = [cake, wbnb, eth];
    routes[xvs][eth] = [xvs, wbnb, eth];
    routes[egg][eth] = [egg, wbnb, eth];
    routes[sbdo][eth] = [sbdo, busd, wbnb, eth];
    routes[space][eth] = [space, wbnb, eth];
    routes[belt][eth] = [belt, wbnb, eth];
    routes[eps][eth] = [eps, wbnb, eth];
    routes[wbnb][eth] = [wbnb, eth];
    routes[busd][eth] = [busd, wbnb, eth];

    routers[cake][eth] = pancakeswapRouterNew;
    routers[xvs][eth] = pancakeswapRouterNew;
    routers[egg][eth] = pancakeswapRouterOld;
    routers[sbdo][eth] = pancakeswapRouterOld;
    routers[space][eth] = pancakeswapRouterOld;
    routers[belt][eth] = pancakeswapRouterNew;
    routers[eps][eth] = pancakeswapRouterNew;
    routers[wbnb][eth] = pancakeswapRouterNew;
    routers[busd][eth] = pancakeswapRouterNew;
  }

  /*
  *   Set the pool that will receive the reward token
  *   based on the address of the reward Token
  */
  function setEOA(address _eoa) public onlyGovernance {
    profitSharingPool = _eoa;
    targetToken = eth;
    emit TokenPoolSet(targetToken, _eoa);
  }

  /**
  * Sets the path for swapping tokens to the to address
  * The to address is not validated to match the targetToken,
  * so that we could first update the paths, and then,
  * set the new target
  */
  function setConversionPath(address from, address to, address[] memory _route, address _router)
    public
    onlyGovernance
  {
    require(
      from == _route[0],
      "The first token of the Pancakeswap route must be the from token"
    );
    require(
      to == _route[_route.length - 1],
      "The last token of the Pancakeswap route must be the to token"
    );

    routes[from][to] = _route;
    routers[from][to] = _router;
  }

  // Transfers the funds from the msg.sender to the pool
  // under normal circumstances, msg.sender is the strategy
  function poolNotifyFixedTarget(address _token, uint256 _amount) external {
    uint256 remainingAmount = _amount;
    // Note: targetToken could only be FARM or NULL.
    // it is only used to check that the rewardPool is set.
    if (targetToken == address(0)) {
      return; // a No-op if target pool is not set yet
    }

    if (_token == eth) {
      // this is already the right token
      // Note: Under current structure, this would be FARM.
      // This would pass on the grain buy back as it would be the special case
      // designed for NotifyHelper calls
      // This is assuming that NO strategy would notify profits in FARM

      IBEP20(_token).safeTransferFrom(msg.sender, profitSharingPool, _amount);
      //IRewardPool(profitSharingPool).notifyRewardAmount(_amount);

      // send the _amount of wbnb to the cross-chain converter
    } else {

      // we need to convert _token to FARM
      if (routes[_token][eth].length > 1) {
        IBEP20(_token).safeTransferFrom(msg.sender, address(this), remainingAmount);
        uint256 balanceToSwap = IBEP20(_token).balanceOf(address(this));
        liquidate(_token, eth, balanceToSwap);

        // now we can send this token forward
        uint256 convertedRewardAmount = IBEP20(eth).balanceOf(address(this));

        IBEP20(eth).safeTransfer(profitSharingPool, convertedRewardAmount);
        // IRewardPool(profitSharingPool).notifyRewardAmount(convertedRewardAmount);

        // send the token to the cross-chain converter address
      } else {
        // else the route does not exist for this token
        // do not take any fees and revert.
        // It's better to set the liquidation path then perform it again,
        // rather then leaving the funds in controller
        revert("FeeRewardForwarder: liquidation path doesn't exist");
      }
    }
  }

  function liquidate(address _from, address _to, uint256 balanceToSwap) internal {
    if(balanceToSwap > 0){
      address router = routers[_from][_to];
      IBEP20(_from).safeApprove(router, 0);
      IBEP20(_from).safeApprove(router, balanceToSwap);

      IUniswapV2Router02(router).swapExactTokensForTokens(
        balanceToSwap,
        0,
        routes[_from][_to],
        address(this),
        block.timestamp
      );
    }
  }
}
