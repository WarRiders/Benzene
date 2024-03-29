pragma solidity ^0.4.21;

import "./ApproveAndCallFallBack.sol";
import "./TokenUpdate.sol";
import "./StandbyGamePool.sol";
import "./TeamPool.sol";
import "./AdvisorPool.sol";

contract BenzeneToken is TokenUpdate, ApproveAndCallFallBack {
    using SafeMath for uint256;

    string public constant name = "Benzene";
    string public constant symbol = "BZN";
    uint8 public constant decimals = 18;
    uint256 public constant INITIAL_SUPPLY = 100000000 * (10 ** uint256(decimals));
    uint256 public constant GAME_POOL_INIT = 75000000 * (10 ** uint256(decimals));
    uint256 public constant TEAM_POOL_INIT = 20000000 * (10 ** uint256(decimals));
    uint256 public constant ADVISOR_POOL_INIT = 5000000 * (10 ** uint256(decimals));

    address public GamePoolAddress;
    address public TeamPoolAddress;
    address public AdvisorPoolAddress;

    constructor(address gamePool,
                address teamPool, //vest
                address advisorPool) public DetailedERC20(name, symbol, decimals) {
                    totalSupply_ = INITIAL_SUPPLY;
                    
                    balances[gamePool] = GAME_POOL_INIT;
                    GamePoolAddress = gamePool;

                    balances[teamPool] = TEAM_POOL_INIT;
                    TeamPoolAddress = teamPool;


                    balances[advisorPool] = ADVISOR_POOL_INIT;
                    AdvisorPoolAddress = advisorPool;

                    StandbyGamePool(gamePool).setToken(this);
                    TeamPool(teamPool).setToken(this);
                    AdvisorPool(advisorPool).setToken(this);
                }
  
  function approveAndCall(address spender, uint tokens, bytes memory data) public payable returns (bool success) {
      super.approve(spender, tokens);
      
      ApproveAndCallFallBack toCall = ApproveAndCallFallBack(spender);
      
      require(toCall.receiveApproval.value(msg.value)(msg.sender, tokens, address(this), data));
      
      return true;
  }
  
  function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public payable returns (bool) {
      super.migrate(token, from, tokens);
      
      return true;
  }
}
