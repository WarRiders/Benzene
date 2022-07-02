pragma solidity >=0.7.6 <=0.8.9;

import {BridgedTokenPool} from "../BridgedTokenPool.sol";
import {AdvisorPool} from "./AdvisorPool.sol";

contract BridgedAdvisorPool is AdvisorPool, BridgedTokenPool {
    constructor(address standardBridge) BridgedTokenPool(standardBridge) {}
}
