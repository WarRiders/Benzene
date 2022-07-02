pragma solidity >=0.7.6 <=0.8.9;

import {TokenPool} from "./TokenPool.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IL1ERC20Bridge} from "@eth-optimism/contracts/L1/messaging/IL1ERC20Bridge.sol";

contract BridgedTokenPool is TokenPool, Ownable {
    bytes32 constant L2_DATA_SLOT =
        keccak256("com.warriders.token.pool.bridge");

    struct L2Data {
        address bridge;
        address l2Pool;
        address l2Token;
        uint32 l2GasLimit;
    }

    constructor(address standardBridge) {
        _l2Data().bridge = standardBridge;
    }

    /**
     * @dev The ProxyData struct stored in this registered Extension instance.
     */
    function _l2Data() internal pure returns (L2Data storage ds) {
        bytes32 position = L2_DATA_SLOT;
        assembly {
            ds.slot := position
        }
    }

    function setL2(
        address _l2Token,
        address _l2Pool,
        uint32 _l2GasLimit
    ) external onlyOwner {
        L2Data storage data = _l2Data();

        require(data.l2Pool == address(0), "L2 Already set");
        data.l2Pool = _l2Pool;
        data.l2Token = _l2Token;
        data.l2GasLimit = _l2GasLimit;
    }

    function bridgeTokens(uint256 tokenAmount) external onlyOwner {
        L2Data storage data = _l2Data();

        require(data.l2Pool != address(0), "L2 data not set");

        IL1ERC20Bridge tokenBridge = IL1ERC20Bridge(data.bridge);

        tokenBridge.depositERC20To(
            address(token),
            data.l2Token,
            data.l2Pool,
            tokenAmount,
            data.l2GasLimit,
            ""
        );
    }
}
