pragma solidity ^0.4.21;

import "./StandardBurnableToken.sol";
import "zeppelin-solidity/contracts/token/ERC20/DetailedERC20.sol";
import "./StandbyGamePool.sol";
import "./TeamPool.sol";
import "./AdvisorPool.sol";

contract BenzeneToken is StandardBurnableToken, DetailedERC20 {
    using SafeMath for uint256;

    string public constant name = "Benzene";
    string public constant symbol = "BZN";
    uint8 public constant decimals = 18;
    uint256 public constant INITIAL_SUPPLY = 100000000 * (10 ** uint256(decimals));
    uint256 public constant GAME_POOL_INIT = 75000000 * (10 ** uint256(decimals));
    uint256 public constant TEAM_POOL_INIT = 20000000 * (10 ** uint256(decimals));
    uint256 public constant ADVISOR_POOL_INIT = 5000000 * (10 ** uint256(decimals));

    address public GamePoolAddress;
    address public TeamPoolAddress;
    address public AdvisorPoolAddress;

    constructor(address gamePool,
                address teamPool, //vest
                address advisorPool) public DetailedERC20(name, symbol, decimals) {
                    totalSupply_ = INITIAL_SUPPLY;

                    balances[gamePool] = GAME_POOL_INIT;
                    GamePoolAddress = gamePool;

                    balances[teamPool] = TEAM_POOL_INIT;
                    TeamPoolAddress = teamPool;


                    balances[advisorPool] = ADVISOR_POOL_INIT;
                    AdvisorPoolAddress = advisorPool;

                    StandbyGamePool(gamePool).setToken(this);
                    TeamPool(teamPool).setToken(this);
                    AdvisorPool(advisorPool).setToken(this);
                }
}
