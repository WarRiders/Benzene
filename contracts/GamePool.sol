pragma solidity ^0.4.24;

import "./TokenUpdate.sol";
import "zos-lib/contracts/migrations/Migratable.sol";
import "openzeppelin-zos/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/DetailedERC20.sol";
import "./TokenPool.sol";
import "./CarToken.sol";
import "./CarFactory.sol";

contract GamePool is Migratable, TokenPool, Ownable {
    
    mapping (uint256 => bool) public BZNclaimed;
    
    address internal factoryAdr;
    

    CarToken public carToken;
    
    uint8 public constant decimals = 18;
    uint256 public constant FILL_LIMIT = 160;
    
    event Redeem(address indexed user, uint256 indexed _tokenId, uint256 amount);
    
    
    function initialize(address tokenAdr,
                        address carAdr,
                        address factory)
                        isInitializer("GamePool", "0.1") public {
        ERC20Basic token = ERC20Basic(tokenAdr);
        super.setToken(token);
        
        CarToken erc721Token = CarToken(carAdr);
        carToken = erc721Token;
        
        factoryAdr = factory;
    }
    
    function _preorderFill() public {
        CarFactory factory = CarFactory(factoryAdr);
        
        address user = msg.sender;
        uint256 carCount = carToken.balanceOf(user);
        
        uint256 total = 0;
        uint256 fillCount = 0;
        
        for (uint256 i = 0; i < carCount; i++) {
            
            if (fillCount >= FILL_LIMIT) break;
            
            uint256 currentCar = carToken.tokenOfOwnerByIndex(user, i);
            uint cType = carToken.getCarType(currentCar);
            
            if (BZNclaimed[currentCar]) continue;
            
            if (!carToken.isPremium(cType)) {
                if (!factory.giveawayCar(currentCar)) continue;
            }
            
            uint256 amount = carToken.tankSizes(currentCar) * (10 ** uint256(decimals));
            
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
        DetailedERC20(token).approve(newToken, balance());
        
        TokenUpdate tokenUpdate = TokenUpdate(newToken);
        
        token = tokenUpdate;
        
        tokenUpdate.migrateAll(address(this));
    }
}