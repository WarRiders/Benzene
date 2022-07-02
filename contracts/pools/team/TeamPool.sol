// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6 <=0.8.9;

import "../../tools/TokenVesting.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "../TokenPool.sol";

contract TeamPool is TokenPool, Ownable {
    mapping(address => TokenVesting[]) cache;

    function addVestor(
        address _beneficiary,
        uint256 _start,
        uint256 _cliff,
        uint256 _duration,
        uint256 totalTokens,
        bool revokable
    ) public onlyOwner poolReady returns (TokenVesting) {
        cache[_beneficiary].push(
            new TokenVesting(_beneficiary, _start, _cliff, _duration, revokable)
        );

        uint256 newIndex = cache[_beneficiary].length - 1;

        transferTo(address(cache[_beneficiary][newIndex]), totalTokens);

        return cache[_beneficiary][newIndex];
    }

    function vestingCount(address _beneficiary)
        public
        view
        poolReady
        returns (uint256)
    {
        return cache[_beneficiary].length;
    }

    function revoke(address _beneficiary, uint256 index)
        public
        onlyOwner
        poolReady
    {
        require(index < vestingCount(_beneficiary));
        require(address(cache[_beneficiary][index]) != address(0));

        cache[_beneficiary][index].revoke(address(token));
    }
}
