pragma solidity >=0.7.6<=0.8.9;

interface ICarFactory {
    function giveawayCar(uint256 tokenId) external view returns (bool);
}