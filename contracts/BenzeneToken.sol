pragma solidity ^0.4.21;

import "./ApproveAndCallFallBack.sol";
import "./TokenUpdate.sol";
import "./StandbyGamePool.sol";
import "./TeamPool.sol";
import "./AdvisorPool.sol";

contract BenzeneToken is TokenUpdate {
    using SafeMath for uint256;

    string public constant name = "Benzene";
    string public constant symbol = "BZN";
    uint8 public constant decimals = 18;

    address public GamePoolAddress;
    address public TeamPoolAddress;
    address public AdvisorPoolAddress;

    constructor(address gamePool,
                address teamPool, //vest
                address advisorPool,
                address oldBzn,
                address oldTeamPool,
                address oldAdvisorPool) public DetailedERC20(name, symbol, decimals) {
        
        _legacyToken = DetailedERC20(oldBzn);
        
        GamePoolAddress = gamePool;

        balances[teamPool] = _legacyToken.balanceOf(oldTeamPool);
        TeamPoolAddress = teamPool;


        balances[advisorPool] = _legacyToken.balanceOf(oldAdvisorPool);
        AdvisorPoolAddress = advisorPool;
                    
        TeamPool(teamPool).setToken(this);
        AdvisorPool(advisorPool).setToken(this);
    }
  
  function approveAndCall(address spender, uint tokens, bytes memory data) public returns (bool success) {
      super.approve(spender, tokens);
      
      ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);
      return true;
  }
}
