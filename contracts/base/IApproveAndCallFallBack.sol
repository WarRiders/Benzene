pragma solidity >=0.7.6<=0.8.9;

interface IApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes memory data) external payable returns (bool);
}