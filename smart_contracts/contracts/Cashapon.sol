// All code examples in this guide have not been audited and should not be used in production.
// If so, it is done at your own risk!

pragma solidity ^0.4.18;

import "./ERC20Interface.sol";
import "./KyberNetworkProxyInterface.sol";
import "./PermissionGroups.sol";


contract Cashapon is PermissionGroups {
    event Played(address indexed sender, uint256 amount, ERC20 destToken);
    event TokenAdded(ERC20 token);

    KyberNetworkProxyInterface public kyber;
    address[] public tokenAddresses;
    ERC20 constant internal ETH_TOKEN_ADDRESS = ERC20(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);

    //@dev Contract contstructor
    //@param _kyber KyberNetworkProxy contract address
    function Cashapon(
        KyberNetworkProxyInterface _kyber,
        address _admin,
        address[] _tokenAddresses
    ) public {
        require(_kyber != address(0));
        require(_admin != address(0));
        require(_tokenAddresses.length > 0);

        kyber = _kyber;
        admin = _admin;
        tokenAddresses = _tokenAddresses;
    }

    //@dev Add a new token to the list to support
    //@param token Address of the token contract to be added
    function addToken(
        ERC20 token
    ) public onlyAdmin {
        require(token != address(0));
        tokenAddresses.push(token);

        // Log the event
        TokenAdded(token);
    }

    //@dev Play the gachapon game
    function play() public payable {
        uint expectedRate;
        uint slippageRate;

        // Get the random destination token
        ERC20 destToken = ERC20(tokenAddresses[random()]);

        // Get the minimum conversion rate
        (expectedRate, slippageRate) = kyber.getExpectedRate(ETH_TOKEN_ADDRESS, destToken, msg.value);

        require(slippageRate > 0);

        // Swap the ERC20 token and send to destAddress
        kyber.tradeWithHint.value(msg.value)(
            ETH_TOKEN_ADDRESS,  // srcToken
            msg.value,          // srcAmount
            destToken,          // destToken
            msg.sender,         // destAddress
            2**255,                  // maxDestAmount
            slippageRate,       // minConversionRate
            0,                  // walletId
            ""                  // hint
        );

        // Log the event
        Played(msg.sender, msg.value, destToken);
    }

    //@dev Generate pseudo random number based on block difficulty and timestamp.
    function random() private view returns (uint8) {
        return uint8(uint256(keccak256(block.timestamp, block.difficulty)) % (tokenAddresses.length + 1));
    }
}
