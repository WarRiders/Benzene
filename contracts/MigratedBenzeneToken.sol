// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6 <=0.8.9;

import {IApproveAndCallFallBack} from "./base/IApproveAndCallFallBack.sol";
import "./base/AbstractBenzeneToken.sol";
import "./TokenUpdate.sol";
import "./pools/game/StandbyGamePool.sol";
import "./pools//team/TeamPool.sol";
import "./pools/advisor/AdvisorPool.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MigratedBenzeneToken is TokenUpdate, AbstractBenzeneToken {
    using SafeMath for uint256;

    constructor(
        address gamePool,
        address teamPool, //vest
        address advisorPool,
        address oldTeamPool,
        address oldAdvisorPool,
        address[] memory oldBzn
    )
        ERC20(TokenName, TokenSymbol)
        AbstractBenzeneToken(gamePool, teamPool, advisorPool)
    {
        require(oldBzn.length > 0);

        ERC20 _legacyToken; //Save the last token (should be latest version)
        for (uint256 i = 0; i < oldBzn.length; i++) {
            //Ensure this is an actual token
            _legacyToken = ERC20(oldBzn[i]);

            //Now register it for update
            _legacyTokens[oldBzn[i]] = true;
        }

        defaultLegacyToken = address(_legacyToken);

        //Removed legacy openzeppelin code
        /* GamePoolAddress = gamePool;
        
        uint256 teampool_balance =  _legacyToken.balanceOf(oldTeamPool);
        require(teampool_balance > 0); //Ensure the last token actually has a balance
        balances[teamPool] = teampool_balance;
        totalSupply_ = totalSupply_.add(teampool_balance);
        TeamPoolAddress = teamPool;

        
        uint256 advisor_balance =  _legacyToken.balanceOf(oldAdvisorPool);
        require(advisor_balance > 0); //Ensure the last token actually has a balance
        balances[advisorPool] = advisor_balance;
        totalSupply_ = totalSupply_.add(advisor_balance);
        AdvisorPoolAddress = advisorPool; */
        //Old code is above
        //Below is upgraded code
        //In old code, we only set the total supply to the old balance of the teampool/advisorpool
        //So mint that much
        uint256 teampool_balance = _legacyToken.balanceOf(oldTeamPool);
        uint256 advisor_balance = _legacyToken.balanceOf(oldAdvisorPool);
        require(teampool_balance > 0); //Ensure the last token actually has a balance
        require(advisor_balance > 0); //Ensure the last token actually has a balance

        _mint(address(this), teampool_balance + advisor_balance);

        //Then transfer to those tokens
        _transfer(address(this), teamPool, teampool_balance);
        _transfer(address(this), advisorPool, advisor_balance);

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
