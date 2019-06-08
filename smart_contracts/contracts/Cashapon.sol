// All code examples in this guide have not been audited and should not be used in production.
// If so, it is done at your own risk!

pragma solidity ^0.4.18;

import "./ERC20Interface.sol";
import "./KyberNetworkProxyInterface.sol";
import "./PermissionGroups.sol";


library SafeMath {
    function mul(uint a, uint b) internal pure returns (uint) {
        uint c = a * b;
        require(a == 0 || c / a == b);
        return c;
    }

    function div(uint a, uint b) internal pure returns (uint) {
        require(b > 0);
        uint c = a / b;
        require(a == b * c + a % b);
        return c;
    }

    function sub(uint a, uint b) internal pure returns (uint) {
        require(b <= a);
        return a - b;
    }

    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a);
        return c;
    }

    function max64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a >= b ? a : b;
    }

    function min64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a < b ? a : b;
    }

    function max256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}


contract Cashapon is PermissionGroups {
    using SafeMath for uint;

    event Played(address indexed sender, uint256 amount, ERC20 destToken);
    event TokenAdded(ERC20 token);
    event TokenRemoved(ERC20 token);

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
    ) public onlyAdmin returns (address[]) {
        require(token != address(0));
        tokenAddresses.push(token);

        // Log the event
        TokenAdded(token);

        return tokenAddresses;
    }

    //@dev Remove an existing token from the list to support
    //@param index Index of the token in the array to be removed
    function removeToken(
        uint8 index
    ) public onlyAdmin returns (address[]) {
        if (index >= tokenAddresses.length) return;

        ERC20 token = ERC20(tokenAddresses[index]);

        // Loop through array, remove the token, and readjust indexes
        for (uint i = index; i < tokenAddresses.length - 1; i++) {
            tokenAddresses[i] = tokenAddresses[i + 1];
        }
        tokenAddresses.length--;

        // Log the event
        TokenRemoved(token);

        return tokenAddresses;
    }

    //@dev Play the gachapon game
    function play() public payable {
        uint expectedRate;
        uint slippageRate;

        // Get the random destination token
        ERC20 destToken = ERC20(tokenAddresses[random(0)]);

        // Get the minimum conversion rate
        (expectedRate, slippageRate) = kyber.getExpectedRate(
            ETH_TOKEN_ADDRESS,
            destToken,
            msg.value
        );

        require(slippageRate > 0);

        // Swap the ERC20 token and send to destAddress
        kyber.tradeWithHint.value(msg.value)(
            ETH_TOKEN_ADDRESS,  // srcToken
            msg.value,          // srcAmount
            destToken,          // destToken
            msg.sender,         // destAddress
            2**255,             // maxDestAmount
            slippageRate,       // minConversionRate
            0,                  // walletId
            ""                  // hint
        );

        // Log the event
        Played(msg.sender, msg.value, destToken);
    }

    //@dev Play the gachapon game for multiple tokens
    function playMultiple(uint numTokens) public payable {
        uint expectedRate;
        uint slippageRate;
        ERC20 destToken;

        uint amount = msg.value.div(numTokens);

        for (uint i = 0; i < numTokens; i++) {
            // Get the random destination token
            destToken = ERC20(tokenAddresses[random(i)]);

            // Get the minimum conversion rate
            (expectedRate, slippageRate) = kyber.getExpectedRate(ETH_TOKEN_ADDRESS, destToken, amount);

            require(slippageRate > 0);

            // Swap the ERC20 token and send to destAddress
            kyber.tradeWithHint.value(amount)(
                ETH_TOKEN_ADDRESS,  // srcToken
                amount,             // srcAmount
                destToken,          // destToken
                msg.sender,         // destAddress
                2**255,             // maxDestAmount
                slippageRate,       // minConversionRate
                0,                  // walletId
                ""                  // hint
            );

            // Log the event
            Played(msg.sender, amount, destToken);
        }
    }

    //@dev Generate pseudo random number based on block difficulty and timestamp.
    //@param index Index of token to add to randomness
    function random(uint index) private view returns (uint8) {
        return uint8(uint256(keccak256(block.timestamp, block.difficulty, index)) % tokenAddresses.length);
    }
}
