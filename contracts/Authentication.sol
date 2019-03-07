pragma solidity >=0.4.24<0.6.0;

import "zeppelin-solidity/contracts/ECRecovery.sol";

// Implementation of signature and verification by EIP712 for internal circulation token

contract Authentication {
    using ECRecovery for bytes32;

    string public constant name = "EIP712Authentication";
    string public constant version = "1.0.0";

    struct EIP712Domain {
        string name;
        string version;
        uint256 chainId;
        address verifyingContract;
        bytes32 salt;
    }

    string private constant EIP712_DOMAIN_TYPE = "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract,bytes32 salt)";
    bytes32 public constant EIP712_DOMAIN_TYPEHASH = keccak256(abi.encodePacked(EIP712_DOMAIN_TYPE));

    struct Auth {
        uint256 authId;
        address user;
        bytes32 key;
    }

    string private constant AUTH_TYPE = "Auth(uint256 authId,address user,bytes32 key)";
    bytes32 public constant AUTH_TYPEHASH = keccak256(abi.encodePacked(AUTH_TYPE));

    bytes32 DOMAIN_SEPARATOR;

    constructor(uint256 _chainId, address _verifyingContract, bytes32 _salt) public {
        DOMAIN_SEPARATOR = hashDomain(
            EIP712Domain({name: "EIP712Authentication", version: "1.0.0", chainId: _chainId, verifyingContract: _verifyingContract, salt: _salt})
        );
    }

    // @title Calculate EIP712Domain TypeHash
    function hashDomain(EIP712Domain eip712Domain) internal pure returns (bytes32) {
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

    // @title Calculate Auth TypeHash
    function hashAuthentication(Auth memory auth) private view returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, keccak256(abi.encode(AUTH_TYPEHASH, auth.authId, auth.user, auth.key))));
    }

    // @title Verify signature: Obtain EOA address from signature
    // @param bytes _signature
    // @param uint256 authId
    // @param address user
    // @param bytes32 key
    // @return address EOA address obtained from signature
    function verify(bytes _signature, uint256 authId, address user, bytes32 key) public view returns (address) {
        Auth memory auth = Auth({authId: authId, user: user, key: key});
        bytes32 hash = hashAuthentication(auth);
        return hash.recover(_signature);
    }

}
