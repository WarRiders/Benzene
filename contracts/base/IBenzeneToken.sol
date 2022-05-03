pragma solidity >=0.7.6<=0.8.9;

import "./ITokenMigratable.sol";
import "./IApproveAndCallFallBack.sol";

interface IBenzeneToken is ITokenMigratable, IApproveAndCallFallBack {
    function GamePoolAddress() external view returns (address);
    function TeamPoolAddress() external view returns (address);
    function AdvisorPoolAddress() external view returns (address);
}