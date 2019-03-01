pragma solidity >=0.4.24<0.6.0;

import "zeppelin-solidity/contracts/ECRecovery.sol";

// Implementation of signature and verification by EIP712 for internal circulation token

contract SignatureVerification {
    using ECRecovery for bytes32;

    struct EIP712Domain {
        string name;
        string version;
        uint256 chainId;
        address verifyingContract;
        bytes32 salt;
    }

    string private constant EIP712_DOMAIN_TYPE = "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract,bytes32 salt)";
    bytes32 public constant EIP712_DOMAIN_TYPE_HASH = keccak256(abi.encodePacked(EIP712_DOMAIN_TYPE));

    struct Exchange {
        address sender;
        uint256 amount;
        bytes32 key;
    }

    string private constant EXCHANGE_TYPE = "Exchange(address sender,uint256 amount,bytes32 key)";
    bytes32 public constant EXCHANGE_TYPE_HASH = keccak256(abi.encodePacked(EXCHANGE_TYPE));

    bytes32 DOMAIN_SEPARATOR;

    constructor(string _name, string _version, uint256 _chainId, address _verifyingContract, bytes32 _salt) public {
        DOMAIN_SEPARATOR = hashDomain(
            EIP712Domain({name: _name, version: _version, chainId: _chainId, verifyingContract: _verifyingContract, salt: _salt})
        );
    }

    function hashDomain(EIP712Domain eip712Domain) internal pure returns (bytes32) {
        return keccak256(
            abi.encode(
                EIP712_DOMAIN_TYPE_HASH,
                keccak256(bytes(eip712Domain.name)),
                keccak256(bytes(eip712Domain.version)),
                eip712Domain.chainId,
                eip712Domain.verifyingContract,
                eip712Domain.salt
            )
        );
    }

    function hashExchange(Exchange memory exchange) private view returns (bytes32) {
        return keccak256(
            abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, keccak256(abi.encode(EXCHANGE_TYPE_HASH, exchange.sender, exchange.amount, exchange.key)))
        );
    }

    function verify(bytes _signature, address sender, uint256 amount, bytes32 key) public view returns (address) {
        Exchange memory exchange = Exchange({sender: sender, amount: amount, key: key});
        bytes32 hash = hashExchange(exchange);
        return hash.recover(_signature);
    }

}
