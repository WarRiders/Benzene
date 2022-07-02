pragma solidity >=0.7.6 <=0.8.9;

import {MigratedBenzeneToken} from "./MigratedBenzeneToken.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";

contract BenzeneTokenV3 is MigratedBenzeneToken, ERC20Permit, Ownable {
    mapping(address => bool) public addressAllowedMigration;
    mapping(address => bool) public addressBlocked;

    constructor(
        address gamePool,
        address teamPool, //vest
        address advisorPool,
        address oldTeamPool,
        address oldAdvisorPool,
        address[] memory oldBzn
    )
        ERC20Permit(TokenName)
        MigratedBenzeneToken(
            gamePool,
            teamPool,
            advisorPool,
            oldTeamPool,
            oldAdvisorPool,
            oldBzn
        )
    {}

    function _migrate(
        address token,
        address account,
        uint256 amount
    ) internal override {
        require(
            addressAllowedMigration[account],
            "Address is not allowed to migrate tokens"
        );
        super._migrate(token, account, amount);
    }

    function _migrateAll(address token, address account) internal override {
        require(
            addressAllowedMigration[account],
            "Address is not allowed to migrate tokens"
        );
        super._migrateAll(token, account);
    }

    function toggleTokenMigrationAccess(address account, bool access)
        external
        onlyOwner
    {
        addressAllowedMigration[account] = access;
    }

    function batchToggleTokenMigrationAccess(
        address[] calldata accounts,
        bool access
    ) external onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            addressAllowedMigration[accounts[i]] = access;
        }
    }

    function blocklistAddress(address account) external onlyOwner {
        addressBlocked[account] = true;
    }

    function removeBlocklistedAddress(address account) external onlyOwner {
        addressBlocked[account] = false;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 //amount - not used
    ) internal virtual override {
        bool fromAllowed = from == address(0) || !addressBlocked[from];
        bool toAllowed = to == address(0) || !addressBlocked[to];

        require(fromAllowed && toAllowed, "Address block listed");
    }
}
