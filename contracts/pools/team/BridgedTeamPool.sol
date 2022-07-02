// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6 <=0.8.9;

import {BridgedTokenPool} from "../BridgedTokenPool.sol";
import {TeamPool} from "./TeamPool.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract BridgedTeamPool is TeamPool, BridgedTokenPool {
    constructor(address standardBridge) BridgedTokenPool(standardBridge) {}

    function _checkOwner() internal view override(BridgedTokenPool, Ownable) {
        Ownable._checkOwner();
    }

    function l1Token() internal view override returns (address) {
        return address(token);
    }
}
