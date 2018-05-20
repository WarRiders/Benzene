pragma solidity ^0.4.21;

import "zeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol";
import "zeppelin-solidity/contracts/token/ERC20/TokenVesting.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "./TokenPool.sol";

contract AdvisorPool is TokenPool, Ownable {

    function addVestor(
        address _beneficiary,
        uint256 _start,
        uint256 _cliff,
        uint256 _duration,
        uint256 totalTokens
    ) public onlyOwner poolReady returns (TokenVesting) {
        TokenVesting vesting = new TokenVesting(_beneficiary, _start, _cliff, _duration, false);

        transferTo(vesting, totalTokens);

        return vesting;
    }

    function transfer(address _beneficiary, uint256 amount) public onlyOwner poolReady returns (bool) {
        return transferTo(_beneficiary, amount);
    }
}
