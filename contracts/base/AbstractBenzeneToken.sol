// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6 <=0.8.9;

import "./IBenzeneToken.sol";

abstract contract AbstractBenzeneToken is IBenzeneToken {
    uint256 public constant GAME_POOL_INIT = 75000000000000000000000000;
    uint256 public constant TEAM_POOL_INIT = 20000000000000000000000000;
    uint256 public constant ADVISOR_POOL_INIT = 5000000000000000000000000;
    uint256 public constant INITIAL_SUPPLY =
        GAME_POOL_INIT + TEAM_POOL_INIT + ADVISOR_POOL_INIT;
    string public constant TokenName = "Benzene";
    string public constant TokenSymbol = "BZN";

    address internal _gamePoolAddress;
    address internal _teamPoolAddress;
    address internal _advisorPoolAddress;

    function GamePoolAddress() external view override returns (address) {
        return _gamePoolAddress;
    }

    function TeamPoolAddress() external view override returns (address) {
        return _teamPoolAddress;
    }

    function AdvisorPoolAddress() external view override returns (address) {
        return _advisorPoolAddress;
    }

    constructor(
        address gamePool,
        address teamPool,
        address advisorPool
    ) {
        _gamePoolAddress = gamePool;
        _teamPoolAddress = teamPool;
        _advisorPoolAddress = advisorPool;
    }
}
