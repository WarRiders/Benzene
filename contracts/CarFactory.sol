pragma solidity ^0.4.24;

import "openzeppelin-zos/contracts/ownership/Ownable.sol";
import "./CarToken.sol";

contract CarFactory is Ownable {
    uint256 public constant MAX_CARS = 30000 + 150000 + 1000000;
    uint256 public mintedCars = 0;

    mapping(uint256 => uint256) public tankSizes;
    mapping(uint256 => uint) public savedTypes;
    mapping(uint256 => bool) public giveawayCar;

    mapping(uint => uint256[]) public availableIds;
    mapping(uint => uint256) public idCursor;
}