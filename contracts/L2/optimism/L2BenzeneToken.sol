// SPDX-License-Identifier: MIT
pragma solidity >=0.5.16 <0.9.0;

import "../../pools/game/StandbyGamePool.sol";
import "../../pools//team/TeamPool.sol";
import "../../pools/advisor/AdvisorPool.sol";
import {TokenUpdate} from "../../TokenUpdate.sol";
import {IApproveAndCallFallBack} from "../../base/IApproveAndCallFallBack.sol";
import {AbstractBenzeneToken} from "../../base/AbstractBenzeneToken.sol";
import {L2StandardERC20} from "@eth-optimism/contracts/standards/L2StandardERC20.sol";

contract L2BenzeneToken is L2StandardERC20, AbstractBenzeneToken, TokenUpdate {
    constructor(
        address _l2Bridge,
        address _l1Token,
        address gamePool,
        address teamPool,
        address advisorPool
    )
        L2StandardERC20(_l2Bridge, _l1Token, TokenName, TokenSymbol)
        AbstractBenzeneToken(gamePool, teamPool, advisorPool)
    {
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
        bytes memory
    ) external payable override returns (bool) {
        _migrate(token, from, tokens);

        return true;
    }
}
