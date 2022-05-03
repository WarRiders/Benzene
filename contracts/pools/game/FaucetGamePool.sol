pragma solidity >=0.7.6<=0.8.9;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "../TokenPool.sol";

contract FaucetGamePool is TokenPool, Ownable {
    uint256 public maxRequestAmount;

    function setMaxRequestAmount(uint256 amount) external onlyOwner {
        maxRequestAmount = amount;
    }

    function requestBZN(address dst, uint256 amount) external {
        require(amount <= maxRequestAmount, "Cannot request more than the max");

        transferTo(dst, amount);
    }
}
