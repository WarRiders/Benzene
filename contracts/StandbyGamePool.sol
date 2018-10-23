pragma solidity ^0.4.21;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol";
import "openzeppelin-solidity/contracts/token/ERC20/TokenVesting.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./TokenPool.sol";


contract StandbyGamePool is TokenPool, Ownable {
    TokenPool public currentVersion;
    bool public ready = false;

    function update(TokenPool newAddress) onlyOwner public {
        require(!ready);
        ready = true;
        currentVersion = newAddress;
        transferTo(newAddress, balance());
    }

    function() public payable {
        require(ready);
        if(!currentVersion.delegatecall(msg.data)) revert();
    }
}
