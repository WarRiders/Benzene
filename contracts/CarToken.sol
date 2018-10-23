pragma solidity ^0.4.21;

import "./strings.sol";
import "openzeppelin-solidity/contracts/token/ERC721/ERC721Token.sol";
import "openzeppelin-zos/contracts/ownership/Ownable.sol";

contract CarToken is ERC721Token, Ownable {
    using strings for *;
    
    address factory;

    /*
    * Car Types:
    * 0 - Unknown
    * 1 - SUV
    * 2 - Truck
    * 3 - Hovercraft
    * 4 - Tank
    * 5 - Lambo
    * 6 - Buggy
    * 7 - midgrade type 2
    * 8 - midgrade type 3
    * 9 - Hatchback
    * 10 - regular type 2
    * 11 - regular type 3
    */
    uint public constant UNKNOWN_TYPE = 0;
    uint public constant SUV_TYPE = 1;
    uint public constant TANKER_TYPE = 2;
    uint public constant HOVERCRAFT_TYPE = 3;
    uint public constant TANK_TYPE = 4;
    uint public constant LAMBO_TYPE = 5;
    uint public constant DUNE_BUGGY = 6;
    uint public constant MIDGRADE_TYPE2 = 7;
    uint public constant MIDGRADE_TYPE3 = 8;
    uint public constant HATCHBACK = 9;
    uint public constant REGULAR_TYPE2 = 10;
    uint public constant REGULAR_TYPE3 = 11;
    
    string public constant METADATA_URL = "https://vault.warriders.com/";
    
    //Number of premium type cars
    uint public PREMIUM_TYPE_COUNT = 5;
    //Number of midgrade type cars
    uint public MIDGRADE_TYPE_COUNT = 3;
    //Number of regular type cars
    uint public REGULAR_TYPE_COUNT = 3;

    mapping(uint256 => uint256) public maxBznTankSizeOfPremiumCarWithIndex;
    mapping(uint256 => uint256) public maxBznTankSizeOfMidGradeCarWithIndex;
    mapping(uint256 => uint256) public maxBznTankSizeOfRegularCarWithIndex;

    /**
     * Whether any given car (tokenId) is special
     */
    mapping(uint256 => bool) public isSpecial;
    /**
     * The type of any given car (tokenId)
     */
    mapping(uint256 => uint) public carType;
    /**
     * The total supply for any given type (int)
     */
    mapping(uint => uint256) public carTypeTotalSupply;
    /**
     * The current supply for any given type (int)
     */
    mapping(uint => uint256) public carTypeSupply;
    /**
     * Whether any given type (int) is special
     */
    mapping(uint => bool) public isTypeSpecial;

    /**
    * How much BZN any given car (tokenId) can hold
    */
    mapping(uint256 => uint256) public tankSizes;
    
    /**
     * Given any car type (uint), get the max tank size for that type (uint256)
     */
    mapping(uint => uint256) public maxTankSizes;
    
    mapping (uint => uint[]) public premiumTotalSupplyForCar;
    mapping (uint => uint[]) public midGradeTotalSupplyForCar;
    mapping (uint => uint[]) public regularTotalSupplyForCar;

    modifier onlyFactory {
        require(msg.sender == factory, "Not authorized");
        _;
    }

    constructor(address factoryAddress) public ERC721Token("WarRiders", "WR") {
        factory = factoryAddress;

        carTypeTotalSupply[UNKNOWN_TYPE] = 0; //Unknown
        carTypeTotalSupply[SUV_TYPE] = 20000; //SUV
        carTypeTotalSupply[TANKER_TYPE] = 9000; //Tanker
        carTypeTotalSupply[HOVERCRAFT_TYPE] = 600; //Hovercraft
        carTypeTotalSupply[TANK_TYPE] = 300; //Tank
        carTypeTotalSupply[LAMBO_TYPE] = 100; //Lambo
        carTypeTotalSupply[DUNE_BUGGY] = 40000; //migrade type 1
        carTypeTotalSupply[MIDGRADE_TYPE2] = 50000; //midgrade type 2
        carTypeTotalSupply[MIDGRADE_TYPE3] = 60000; //midgrade type 3
        carTypeTotalSupply[HATCHBACK] = 200000; //regular type 1
        carTypeTotalSupply[REGULAR_TYPE2] = 300000; //regular type 2
        carTypeTotalSupply[REGULAR_TYPE3] = 500000; //regular type 3
        
        maxTankSizes[SUV_TYPE] = 200; //SUV tank size
        maxTankSizes[TANKER_TYPE] = 450; //Tanker tank size
        maxTankSizes[HOVERCRAFT_TYPE] = 300; //Hovercraft tank size
        maxTankSizes[TANK_TYPE] = 200; //Tank tank size
        maxTankSizes[LAMBO_TYPE] = 250; //Lambo tank size
        maxTankSizes[DUNE_BUGGY] = 120; //migrade type 1 tank size
        maxTankSizes[MIDGRADE_TYPE2] = 110; //midgrade type 2 tank size
        maxTankSizes[MIDGRADE_TYPE3] = 100; //midgrade type 3 tank size
        maxTankSizes[HATCHBACK] = 90; //regular type 1 tank size
        maxTankSizes[REGULAR_TYPE2] = 70; //regular type 2 tank size
        maxTankSizes[REGULAR_TYPE3] = 40; //regular type 3 tank size
        
        maxBznTankSizeOfPremiumCarWithIndex[1] = 200; //SUV tank size
        maxBznTankSizeOfPremiumCarWithIndex[2] = 450; //Tanker tank size
        maxBznTankSizeOfPremiumCarWithIndex[3] = 300; //Hovercraft tank size
        maxBznTankSizeOfPremiumCarWithIndex[4] = 200; //Tank tank size
        maxBznTankSizeOfPremiumCarWithIndex[5] = 250; //Lambo tank size
        maxBznTankSizeOfMidGradeCarWithIndex[1] = 100; //migrade type 1 tank size
        maxBznTankSizeOfMidGradeCarWithIndex[2] = 110; //midgrade type 2 tank size
        maxBznTankSizeOfMidGradeCarWithIndex[3] = 120; //midgrade type 3 tank size
        maxBznTankSizeOfRegularCarWithIndex[1] = 40; //regular type 1 tank size
        maxBznTankSizeOfRegularCarWithIndex[2] = 70; //regular type 2 tank size
        maxBznTankSizeOfRegularCarWithIndex[3] = 90; //regular type 3 tank size

        isTypeSpecial[HOVERCRAFT_TYPE] = true;
        isTypeSpecial[TANK_TYPE] = true;
        isTypeSpecial[LAMBO_TYPE] = true;
    }

    function isCarSpecial(uint256 tokenId) public view returns (bool) {
        return isSpecial[tokenId];
    }

    function getCarType(uint256 tokenId) public view returns (uint) {
        return carType[tokenId];
    }

    function mint(uint256 _tokenId, string _metadata, uint cType, uint256 tankSize, address newOwner) public onlyFactory {
        //Since any invalid car type would have a total supply of 0 
        //This require will also enforce that a valid cType is given
        require(carTypeSupply[cType] < carTypeTotalSupply[cType], "This type has reached total supply");
        
        //This will enforce the tank size is less than the max
        require(tankSize <= maxTankSizes[cType], "Tank size provided bigger than max for this type");
        
        if (isPremium(cType)) {
            premiumTotalSupplyForCar[cType].push(_tokenId);
        } else if (isMidGrade(cType)) {
            midGradeTotalSupplyForCar[cType].push(_tokenId);
        } else {
            regularTotalSupplyForCar[cType].push(_tokenId);
        }

        super._mint(newOwner, _tokenId);
        super._setTokenURI(_tokenId, _metadata);

        carType[_tokenId] = cType;
        isSpecial[_tokenId] = isTypeSpecial[cType];
        carTypeSupply[cType] = carTypeSupply[cType] + 1;
        tankSizes[_tokenId] = tankSize;
    }
    
    function isPremium(uint cType) public pure returns (bool) {
        return cType == SUV_TYPE || cType == TANKER_TYPE || cType == HOVERCRAFT_TYPE || cType == TANK_TYPE || cType == LAMBO_TYPE;
    }
    
    function isMidGrade(uint cType) public pure returns (bool) {
        return cType == DUNE_BUGGY || cType == MIDGRADE_TYPE2 || cType == MIDGRADE_TYPE3;
    }
    
    function isRegular(uint cType) public pure returns (bool) {
        return cType == HATCHBACK || cType == REGULAR_TYPE2 || cType == REGULAR_TYPE3;
    }
    
    function getTotalSupplyForType(uint cType) public view returns (uint256) {
        return carTypeSupply[cType];
    }
    
    function getPremiumCarsForVariant(uint variant) public view returns (uint[]) {
        return premiumTotalSupplyForCar[variant];
    }
    
    function getMidgradeCarsForVariant(uint variant) public view returns (uint[]) {
        return midGradeTotalSupplyForCar[variant];
    }

    function getRegularCarsForVariant(uint variant) public view returns (uint[]) {
        return regularTotalSupplyForCar[variant];
    }

    function getPremiumCarSupply(uint variant) public view returns (uint) {
        return premiumTotalSupplyForCar[variant].length;
    }
    
    function getMidgradeCarSupply(uint variant) public view returns (uint) {
        return midGradeTotalSupplyForCar[variant].length;
    }

    function getRegularCarSupply(uint variant) public view returns (uint) {
        return regularTotalSupplyForCar[variant].length;
    }
    
    function exists(uint256 _tokenId) public view returns (bool) {
        return super.exists(_tokenId);
    }
}
