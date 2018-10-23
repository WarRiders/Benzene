pragma solidity ^0.4.21;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol";

contract TokenPool {
    ERC20Basic public token;

    modifier poolReady {
        require(token != address(0));
        _;
    }

    function setToken(ERC20Basic newToken) public {
        require(token == address(0));

        token = newToken;
    }

    function balance() view public returns (uint256) {
        return token.balanceOf(this);
    }

    function transferTo(address dst, uint256 amount) internal returns (bool) {
        return token.transfer(dst, amount);
    }

    function getFrom() view public returns (address) {
        return this;
    }
}
