pragma solidity >=0.7.6<=0.8.9;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ITokenMigratable is IERC20 {
    function migrate(address token, address account, uint256 amount) external;

    function migrateAll(address token, address account) external;

    function migrateAll(address account) external;
}