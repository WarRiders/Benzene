// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6 <=0.8.9;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenPool {
    IERC20 public token;

    modifier poolReady() {
        require(address(token) != address(0));
        _;
    }

    function setToken(IERC20 newToken) public {
        require(address(token) == address(0));

        token = newToken;
    }

    function balance() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function transferTo(address dst, uint256 amount) internal returns (bool) {
        return token.transfer(dst, amount);
    }

    function getFrom() public view returns (address) {
        return address(this);
    }
}
