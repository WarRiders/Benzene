pragma solidity >=0.7.6<=0.8.9;

import {TokenVesting} from "../../tools/TokenVesting.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "../TokenPool.sol";

contract AdvisorPool is TokenPool, Ownable {

    function addVestor(
        address _beneficiary,
        uint256 _start,
        uint256 _cliff,
        uint256 _duration,
        uint256 totalTokens
    ) public onlyOwner poolReady returns (TokenVesting) {
        TokenVesting vesting = new TokenVesting(_beneficiary, _start, _cliff, _duration, false);

        transferTo(address(vesting), totalTokens);

        return vesting;
    }

    function transfer(address _beneficiary, uint256 amount) public onlyOwner poolReady returns (bool) {
        return transferTo(_beneficiary, amount);
    }
}
