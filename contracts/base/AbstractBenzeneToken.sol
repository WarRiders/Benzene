pragma solidity >=0.7.6<=0.8.9;

import "./IBenzeneToken.sol";

abstract contract AbstractBenzeneToken is IBenzeneToken {
    string public constant TokenName = "Benzene";
    string public constant TokenSymbol = "BZN";

    address internal _gamePoolAddress;
    address internal _teamPoolAddress;
    address internal _advisorPoolAddress;

    function GamePoolAddress() external override view returns (address) {
        return _gamePoolAddress;
    }

    function TeamPoolAddress() external override view returns (address) {
        return _teamPoolAddress;
    }

    function AdvisorPoolAddress() external override view returns (address) {
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