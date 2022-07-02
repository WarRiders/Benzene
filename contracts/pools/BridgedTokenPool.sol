pragma solidity >=0.7.6 <=0.8.9;

import {TokenPool} from "./TokenPool.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IL1ERC20Bridge} from "@eth-optimism/contracts/L1/messaging/IL1ERC20Bridge.sol";

contract BridgedTokenPool is TokenPool, Ownable {
    IL1ERC20Bridge public bridge;
    address public l2Pool;
    address public l2Token;
    uint32 private l2GasLimit;

    constructor(address standardBridge) {
        bridge = IL1ERC20Bridge(standardBridge);
    }

    function setL2(
        address _l2Token,
        address _l2Pool,
        uint32 _l2GasLimit
    ) external onlyOwner {
        require(l2Pool == address(0), "L2 Already set");
        l2Pool = _l2Pool;
        l2Token = _l2Token;
        l2GasLimit = _l2GasLimit;
    }

    function bridgeTokens(uint256 tokenAmount) external onlyOwner {
        require(l2Pool != address(0), "L2 data not set");

        bridge.depositERC20To(
            address(token),
            l2Token,
            l2Pool,
            tokenAmount,
            l2GasLimit,
            ""
        );
    }
}
