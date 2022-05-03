pragma solidity >=0.7.6<=0.8.9;

import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import "./base/ITokenMigratable.sol";

abstract contract TokenUpdate is ERC20Burnable, ITokenMigratable {
    
    mapping(address => bool) internal _legacyTokens;
    
    address internal defaultLegacyToken;

    function _migrate(address token, address account, uint256 amount) internal {
       require(_legacyTokens[token]);
       
       ERC20Burnable legacyToken = ERC20Burnable(token);
       
       legacyToken.burnFrom(account, amount);
       _mint(account, amount); 
    }

    function _migrateAll(address token, address account) internal {
      require(_legacyTokens[token]);
       
      IERC20 legacyToken = IERC20(token);
       
      uint256 balance = legacyToken.balanceOf(account);
      uint256 allowance = legacyToken.allowance(account, address(this));
      uint256 amount = Math.min(balance, allowance);
      _migrate(token, account, amount);
    }
                
    /**
   * @dev Transfers part of an account's balance in the old token to this
   * contract, and mints the same amount of new tokens for that account.
   * @param token The legacy token to migrate from, should be registered under this token
   * @param account whose tokens will be migrated
   * @param amount amount of tokens to be migrated
   */
   function migrate(address token, address account, uint256 amount) external override {
       _migrate(token, account, amount);
   }

  /**
   * @dev Transfers all of an account's allowed balance in the old token to
   * this contract, and mints the same amount of new tokens for that account.
   * @param token The legacy token to migrate from, should be registered under this token
   * @param account whose tokens will be migrated
   */
  function migrateAll(address token, address account) external override {
      _migrateAll(token, account);
  }
  
  function migrateAll(address account) external override {
      _migrateAll(defaultLegacyToken, account);
  }
}