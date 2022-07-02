// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6 <=0.8.9;

import {BridgedTokenPool} from "../BridgedTokenPool.sol";
import {AdvisorPool} from "./AdvisorPool.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract BridgedAdvisorPool is AdvisorPool, BridgedTokenPool {
    constructor(address standardBridge) BridgedTokenPool(standardBridge) {}

    function _checkOwner() internal view override(BridgedTokenPool, Ownable) {
        Ownable._checkOwner();
    }

    function l1Token() internal view override returns (address) {
        return address(token);
    }
}
