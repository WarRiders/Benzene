pragma solidity ^0.4.21;

import "zeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol";
import "zeppelin-solidity/contracts/token/ERC20/TokenVesting.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "./TokenPool.sol";

contract TeamPool is TokenPool, Ownable {

    mapping(address => TokenVesting[]) cache;

    function addVestor(
        address _beneficiary,
        uint256 _start,
        uint256 _cliff,
        uint256 _duration,
        uint256 totalTokens
    ) public onlyOwner poolReady returns (TokenVesting) {
        cache[_beneficiary].push(new TokenVesting(_beneficiary, _start, _cliff, _duration, true));

        uint newIndex = cache[_beneficiary].length - 1;

        transferTo(cache[_beneficiary][newIndex], totalTokens);

        return cache[_beneficiary][newIndex];
    }

    function vestingCount(address _beneficiary) public view poolReady returns (uint) {
        return cache[_beneficiary].length;
    }

    function revoke(address _beneficiary, uint index) public onlyOwner poolReady {
        require(index < vestingCount(_beneficiary));
        require(cache[_beneficiary][index] != address(0));

        cache[_beneficiary][index].revoke(token);
    }
}
