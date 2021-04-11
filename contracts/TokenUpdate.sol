pragma solidity ^0.4.21;

import "./StandardBurnableToken.sol";
import "openzeppelin-solidity/contracts/token/ERC20/DetailedERC20.sol";
import "openzeppelin-solidity/contracts/math/Math.sol";

contract TokenUpdate is StandardBurnableToken, DetailedERC20 {
    event Mint(address indexed to, uint256 amount);
    
    mapping(address => bool) internal _legacyTokens;
    
    address internal defaultLegacyToken;
    
    function _mint(address _to, uint256 _amount) internal returns (bool) {
        totalSupply_ = totalSupply_.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Mint(_to, _amount);
        emit Transfer(address(0), _to, _amount);
        return true;
    }
                
    /**
   * @dev Transfers part of an account's balance in the old token to this
   * contract, and mints the same amount of new tokens for that account.
   * @param token The legacy token to migrate from, should be registered under this token
   * @param account whose tokens will be migrated
   * @param amount amount of tokens to be migrated
   */
   function migrate(address token, address account, uint256 amount) public {
       require(_legacyTokens[token]);
       
       StandardBurnableToken legacyToken = StandardBurnableToken(token);
       
       legacyToken.burnFrom(account, amount);
       _mint(account, amount); 
   }

  /**
   * @dev Transfers all of an account's allowed balance in the old token to
   * this contract, and mints the same amount of new tokens for that account.
   * @param token The legacy token to migrate from, should be registered under this token
   * @param account whose tokens will be migrated
   */
  function migrateAll(address token, address account) public {
      require(_legacyTokens[token]);
       
      StandardBurnableToken legacyToken = StandardBurnableToken(token);
       
      uint256 balance = legacyToken.balanceOf(account);
      uint256 allowance = legacyToken.allowance(account, this);
      uint256 amount = Math.min256(balance, allowance);
      migrate(token, account, amount);
  }
  
  function migrateAll(address account) public {
      migrateAll(defaultLegacyToken, account);
  }
}