pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/cryptography/ECDSA.sol";

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
