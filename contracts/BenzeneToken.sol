// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6 <=0.8.9;

import "./base/AbstractBenzeneToken.sol";
import "./base/IApproveAndCallFallBack.sol";
import "./TokenUpdate.sol";
import "./pools/game/StandbyGamePool.sol";
import "./pools//team/TeamPool.sol";
import "./pools/advisor/AdvisorPool.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract BenzeneToken is AbstractBenzeneToken, TokenUpdate {
    using SafeMath for uint256;

    uint256 public constant GAME_POOL_INIT = 75000000000000000000000000;
    uint256 public constant TEAM_POOL_INIT = 20000000000000000000000000;
    uint256 public constant ADVISOR_POOL_INIT = 5000000000000000000000000;
    uint256 public constant INITIAL_SUPPLY =
        GAME_POOL_INIT + TEAM_POOL_INIT + ADVISOR_POOL_INIT;

    constructor(
        address gamePool,
        address teamPool, //vest
        address advisorPool
    )
        ERC20(TokenName, TokenSymbol)
        AbstractBenzeneToken(gamePool, teamPool, advisorPool)
    {
        /*
        totalSupply = INITIAL_SUPPLY;
        
        balances[gamePool] = GAME_POOL_INIT;
        _gamePoolAddress = gamePool;

        balances[teamPool] = TEAM_POOL_INIT;
        _teamPoolAddress = teamPool;


        balances[advisorPool] = ADVISOR_POOL_INIT;
        _advisorPoolAddress = advisorPool;
        */
        //Above is original code
        //Below is upgraded code
        _mint(address(this), INITIAL_SUPPLY);

        _transfer(address(this), _gamePoolAddress, GAME_POOL_INIT);
        _transfer(address(this), _teamPoolAddress, TEAM_POOL_INIT);
        _transfer(address(this), _advisorPoolAddress, ADVISOR_POOL_INIT);

        StandbyGamePool(payable(gamePool)).setToken(this);
        TeamPool(teamPool).setToken(this);
        AdvisorPool(advisorPool).setToken(this);
    }

    function approveAndCall(
        address spender,
        uint256 tokens,
        bytes memory data
    ) external payable returns (bool success) {
        super.approve(spender, tokens);

        IApproveAndCallFallBack toCall = IApproveAndCallFallBack(spender);

        bool result = toCall.receiveApproval{value: msg.value}(
            msg.sender,
            tokens,
            address(this),
            data
        );
        require(result, "approveAndCall response was failed");

        return true;
    }

    function receiveApproval(
        address from,
        uint256 tokens,
        address token,
        bytes memory //data - not used
    ) external payable override returns (bool) {
        _migrate(token, from, tokens);

        return true;
    }
}
