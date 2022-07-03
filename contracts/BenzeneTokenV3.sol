// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6 <=0.8.9;

import {MigratedBenzeneToken} from "./MigratedBenzeneToken.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "./base/ITokenMigratable.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

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
        require(_legacyTokens[token]);

        ERC20Burnable legacyToken = ERC20Burnable(token);

        legacyToken.burnFrom(account, amount);
    }

    function _migrateAll(address token, address account) internal override {
        require(
            addressAllowedMigration[account],
            "Address is not allowed to migrate tokens"
        );
        require(_legacyTokens[token]);

        IERC20 legacyToken = IERC20(token);

        uint256 balance = legacyToken.balanceOf(account);
        uint256 allowance = legacyToken.allowance(account, address(this));
        uint256 amount = Math.min(balance, allowance);

        _migrate(token, account, amount);
    }

    function toggleTokenMigrationAccess(address account, bool access)
        external
        onlyOwner
    {
        addressAllowedMigration[account] = access;
    }

    function batchAirdrop(bytes calldata airdropBlob) external onlyOwner {
        (address[] memory accounts, uint256[] memory balances) = abi.decode(
            airdropBlob,
            (address[], uint256[])
        );
        require(accounts.length == balances.length, "Invalid blob data");

        for (uint256 i = 0; i < accounts.length; i++) {
            uint256 balance = balances[i];
            address account = accounts[i];

            _mint(account, balance);
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
