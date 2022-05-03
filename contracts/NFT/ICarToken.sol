pragma solidity >=0.7.6<=0.8.9;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC721Metadata} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import {IERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

interface ICarToken is IERC721, IERC721Metadata, IERC721Enumerable {
    function getCarType(uint256 currentCar) external returns (uint);
    function tankSizes(uint256 currentCar) external returns (uint256);
    function isPremium(uint ctype) external returns (bool);
}