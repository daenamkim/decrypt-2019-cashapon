// All code examples in this guide have not been audited and should not be used in production.
// If so, it is done at your own risk!

pragma solidity ^0.4.18;

import "./ERC20.sol";
import "./KyberNetworkProxy.sol";
import "./PermissionGroups.sol";


contract Cashapon {
    event Played(address indexed sender, uint256 amount, ERC20 destToken);
    event TokenAdded(ERC20 token);

    KyberNetworkProxy public kyber;
    mapping (uint8 => address) public tokenAddresses;
    ERC20 constant internal ETH_TOKEN_ADDRESS = ERC20(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);

    //@dev Contract contstructor
    //@param _kyber KyberNetworkProxy contract address
    function Cashapon(KyberNetworkProxy _kyber, address _admin, address[] _tokenAddresses) public {
        require(_proxy != address(0));
        require(_admin != address(0));
        require(_tokenAddresses.length) > 0;

        kyber = _kyber;
        admin = _admin;
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
    };

    //@dev Play the gachapon game
    function play() public payable {
        uint minConversionRate;

        // Get the random destination token
        ERC20 destToken = tokenAddresses[random()];

        // Get the minimum conversion rate
        (_, minConversionRate) = proxy.getExpectedRate(ETH_TOKEN_ADDRESS, destToken, msg.value);

        require(minConversionRate > 0);

        // Swap the ERC20 token and send to destAddress
        proxy.trade.value(msg.value)(
            ETH_TOKEN_ADDRESS,
            msg.value,
            destToken,
            msg.sender,
            0,
            minConversionRate,
            0
        );

        // Log the event
        Play(msg.sender, msg.value, destToken);
    }

    //@dev Generate pseudo random number based on block difficulty and timestamp.
    function random() private view returns (uint8) {
        return uint8(uint256(keccak256(block.timestamp, block.difficulty)) % (tokenAddresses.length + 1));
    }
}
