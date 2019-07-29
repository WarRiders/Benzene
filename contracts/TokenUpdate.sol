pragma solidity ^0.4.21;

import "./StandardBurnableToken.sol";
import "openzeppelin-solidity/contracts/token/ERC20/DetailedERC20.sol";
import "openzeppelin-solidity/contracts/math/Math.sol";

contract TokenUpdate is StandardBurnableToken, DetailedERC20 {
    event Mint(address indexed to, uint256 amount);
    
    DetailedERC20 internal _legacyToken;
    
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
   * @param account whose tokens will be migrated
   * @param amount amount of tokens to be migrated
   */
   function migrate(address account, uint256 amount) public {
       _legacyToken.transferFrom(account, this, amount);
       _mint(account, amount); 
   }

  /**
   * @dev Transfers all of an account's allowed balance in the old token to
   * this contract, and mints the same amount of new tokens for that account.
   * @param account whose tokens will be migrated
   */
  function migrateAll(address account) public {
      uint256 balance = _legacyToken.balanceOf(account);
      uint256 allowance = _legacyToken.allowance(account, this);
      uint256 amount = Math.min256(balance, allowance);
      migrate(account, amount);
  }
}