pragma solidity ^0.5.0;

/**
 * @title Elliptic curve signature operations
 * @dev Based on https://gist.github.com/axic/5b33912c6f61ae6fd96d6c4a47afde6d
 * TODO Remove this library once solidity supports passing a signature to ecrecover.
 * See https://github.com/ethereum/solidity/issues/864
 */

library ECDSA {
    /**
     * @dev Recover signer address from a message by using their signature
     * @param hash bytes32 message, the hash is the signed message. What is recovered is the signer address.
     * @param signature bytes signature, the signature is generated using web3.eth.sign()
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        bytes32 r;
        bytes32 s;
        uint8 v;

        // Check the signature length
        if (signature.length != 65) {
            return (address(0));
        }

        // Divide the signature in r, s and v variables
        // ecrecover takes the signature parameters, and the only way to get them
        // currently is to use assembly.
        // solhint-disable-next-line no-inline-assembly
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
        if (v < 27) {
            v += 27;
        }

        // If the version is correct return the signer address
        if (v != 27 && v != 28) {
            return (address(0));
        } else {
            return ecrecover(hash, v, r, s);
        }
    }

    /**
     * toEthSignedMessageHash
     * @dev prefix a bytes32 value with "\x19Ethereum Signed Message:"
     * and hash the result
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}

// Implementation of signature and verification by EIP712 for internal distribution token

contract TokenExchangeVerification {
    using ECDSA for bytes32;

    string public constant name = "TokenExchangeVerification";
    string public constant version = "1.0.0";
    uint256 private _chainId;

    //web3.utils.soliditySha3('https://github.com/godappslab/signature-verification/contracts/TokenExchangeVerification.sol')
    //"0x21e9aa63a90ccdd955a8774d6c1884164cc3b549753ccc1ce262b12959be962e"
    bytes32 public constant salt = 0x21e9aa63a90ccdd955a8774d6c1884164cc3b549753ccc1ce262b12959be962e;

    struct EIP712Domain {
        string name;
        string version;
        uint256 chainId;
        address verifyingContract;
        bytes32 salt;
    }

    string private constant EIP712_DOMAIN_TYPE = "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract,bytes32 salt)";
    bytes32 public constant EIP712_DOMAIN_TYPEHASH = keccak256(abi.encodePacked(EIP712_DOMAIN_TYPE));

    struct Exchange {
        address sender;
        uint256 amount;
        bytes32 key;
    }

    string private constant EXCHANGE_TYPE = "Exchange(address sender,uint256 amount,bytes32 key)";
    bytes32 public constant EXCHANGE_TYPEHASH = keccak256(abi.encodePacked(EXCHANGE_TYPE));

    bytes32 DOMAIN_SEPARATOR;

    constructor(uint256 __chainId) public {
        _chainId = __chainId;
        DOMAIN_SEPARATOR = hashDomain(EIP712Domain({name: name, version: version, chainId: _chainId, verifyingContract: address(this), salt: salt}));
    }

    function chainId() public view returns (uint256) {
        return _chainId;
    }

    function verifyingContract() public view returns (address) {
        return address(this);
    }

    // @title Calculate EIP712Domain TypeHash
    function hashDomain(EIP712Domain memory eip712Domain) internal pure returns (bytes32) {
        return keccak256(
            abi.encode(
                EIP712_DOMAIN_TYPEHASH,
                keccak256(bytes(eip712Domain.name)),
                keccak256(bytes(eip712Domain.version)),
                eip712Domain.chainId,
                eip712Domain.verifyingContract,
                eip712Domain.salt
            )
        );
    }

    // @title Calculate Exchange TypeHash
    function hashExchange(Exchange memory exchange) private view returns (bytes32) {
        return keccak256(
            abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, keccak256(abi.encode(EXCHANGE_TYPEHASH, exchange.sender, exchange.amount, exchange.key)))
        );
    }

    // @title Verify signature: Obtain EOA address from signature
    // @param bytes _signature
    // @param address sender
    // @param uint256 amount
    // @param bytes32 key
    // @return address EOA address obtained from signature
    function verify(bytes memory _signature, address sender, uint256 amount, bytes32 key) public view returns (address) {
        Exchange memory exchange = Exchange({sender: sender, amount: amount, key: key});
        bytes32 hash = hashExchange(exchange);
        return hash.recover(_signature);
    }

}