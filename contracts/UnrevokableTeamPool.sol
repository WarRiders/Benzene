pragma solidity ^0.4.21;

import "./TeamPool.sol";

contract UnrevokableTeamPool is TeamPool {
  function addUnrevokableVestor(
      address _beneficiary,
      uint256 _start,
      uint256 _cliff,
      uint256 _duration,
      uint256 totalTokens
  ) public onlyOwner poolReady returns (TokenVesting) {
      cache[_beneficiary].push(new TokenVesting(_beneficiary, _start, _cliff, _duration, false));

      uint newIndex = cache[_beneficiary].length - 1;

      transferTo(cache[_beneficiary][newIndex], totalTokens);

      return cache[_beneficiary][newIndex];
  }
}
