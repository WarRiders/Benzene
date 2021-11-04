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

    address public GamePoolAddress;
    address public TeamPoolAddress;
    address public AdvisorPoolAddress;

    constructor(address gamePool,
                address teamPool, //vest
                address advisorPool,
                address oldTeamPool,
                address oldAdvisorPool,
                address[] oldBzn) public DetailedERC20(name, symbol, decimals) {
        
        require(oldBzn.length > 0);
        
        DetailedERC20 _legacyToken; //Save the last token (should be latest version)
        for (uint i = 0; i < oldBzn.length; i++) {
            //Ensure this is an actual token
            _legacyToken = DetailedERC20(oldBzn[i]);
            
            //Now register it for update
            _legacyTokens[oldBzn[i]] = true;
        }
        
        defaultLegacyToken = _legacyToken;
        
        GamePoolAddress = gamePool;
        
        uint256 teampool_balance =  _legacyToken.balanceOf(oldTeamPool);
        require(teampool_balance > 0); //Ensure the last token actually has a balance
        balances[teamPool] = teampool_balance;
        totalSupply_ = totalSupply_.add(teampool_balance);
        TeamPoolAddress = teamPool;

        
        uint256 advisor_balance =  _legacyToken.balanceOf(oldAdvisorPool);
        require(advisor_balance > 0); //Ensure the last token actually has a balance
        balances[advisorPool] = advisor_balance;
        totalSupply_ = totalSupply_.add(advisor_balance);
        AdvisorPoolAddress = advisorPool;
                    
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
