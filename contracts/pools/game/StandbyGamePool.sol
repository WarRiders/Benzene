pragma solidity >=0.7.6 <=0.8.9;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "../TokenPool.sol";

contract StandbyGamePool is TokenPool, Ownable {
    TokenPool public currentVersion;
    bool public ready = false;

    function update(TokenPool newAddress) public onlyOwner {
        require(!ready);
        ready = true;
        currentVersion = newAddress;
        transferTo(address(newAddress), balance());
    }

    fallback() external payable {
        require(ready);
        bool success;
        (success, ) = address(currentVersion).delegatecall(msg.data);
        if (!success) revert();
    }

    receive() external payable {}
}
