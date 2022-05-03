// @unsupported: ovm

pragma solidity >=0.7.6<=0.8.9;

import "../../TokenUpdate.sol";
import "../../base/lib/upgrades/Migratable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../TokenPool.sol";
import "../../NFT/ICarToken.sol";
import "../../NFT/ICarFactory.sol";

contract GamePool is Migratable, TokenPool, Ownable {
    
    mapping (uint256 => bool) public BZNclaimed;
    
    address internal factoryAdr;
    

    ICarToken public carToken;
    
    uint8 public constant decimals = 18;
    uint256 public constant FILL_LIMIT = 160;
    
    event Redeem(address indexed user, uint256 indexed _tokenId, uint256 amount);
    
    address public gameBalance;
    uint256 public tokensRedeemed;
    uint256 public limitAmount;
    uint256 public limitStart;
    
    function initialize(address tokenAdr,
                        address carAdr,
                        address factory)
                        isInitializer("GamePool", "0.1") public {
        IERC20 token = IERC20(tokenAdr);
        super.setToken(token);
        
        ICarToken erc721Token = ICarToken(carAdr);
        carToken = erc721Token;
        
        factoryAdr = factory;
    }
    
    function _preorderFill() public {
        ICarFactory factory = ICarFactory(factoryAdr);
        
        address user = msg.sender;
        uint256 carCount = carToken.balanceOf(user);
        
        uint256 total = 0;
        uint256 fillCount = 0;
        uint256 currentCar = 0;
        uint256 amount = 0;
        
        for (uint256 i = 0; i < carCount; i++) {
            
            if (fillCount >= FILL_LIMIT) break;
            
            currentCar = carToken.tokenOfOwnerByIndex(user, i);
            uint cType = carToken.getCarType(currentCar);
            
            if (BZNclaimed[currentCar]) continue;
            
            if (!carToken.isPremium(cType)) {
                if (!factory.giveawayCar(currentCar)) continue;
            }
            
            amount = carToken.tankSizes(currentCar) * (10 ** uint256(decimals));
            
            total = total + amount;
            BZNclaimed[currentCar] = true;
            fillCount++;
        }
        
        if (total > 0) {
            transferTo(user, total);
            
            emit Redeem(user, currentCar, amount);
        }
    }
    
    function migrate(address newToken) public onlyOwner {
        //First approve all to transfer
        IERC20(token).approve(newToken, balance());
        
        TokenUpdate tokenUpdate = TokenUpdate(newToken);
        
        token = tokenUpdate;
        
        tokenUpdate.migrateAll(address(this));
    }

    function setGameBalance(address _gameBalance) public onlyOwner {
        gameBalance = _gameBalance;
    }
    function setLimitAndStart(uint256 amount) public onlyOwner {
        limitAmount = amount;
        limitStart = block.timestamp;
    }
    function dailyLimit() public view returns (uint256) {
        uint256 totalLimit = (((block.timestamp - limitStart) / 86400) + 1) * limitAmount;
        uint256 limitLeft = totalLimit - tokensRedeemed;
        return limitLeft;
    }
    function rewardPlayer(address player, uint256 amount) public {
        require(msg.sender == gameBalance);
        require(amount <= dailyLimit());
        transferTo(player, amount);
        tokensRedeemed += amount;
    }
}