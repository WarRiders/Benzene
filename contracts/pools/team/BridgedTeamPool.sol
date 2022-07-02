pragma solidity >=0.7.6 <=0.8.9;

import {BridgedTokenPool} from "../BridgedTokenPool.sol";
import {TeamPool} from "./TeamPool.sol";

contract BridgedTeamPool is TeamPool, BridgedTokenPool {
    constructor(address standardBridge) BridgedTokenPool(standardBridge) {}
}
