pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/cryptography/ECDSA.sol";

// Implementation of signature and verification by EIP712 for internal circulation token

contract Authentication {
    using ECDSA for bytes32;

    string public constant name = "EIP712Authentication";
    string public constant version = "1.0.0";
    uint256 private _chainId;

    //web3.utils.soliditySha3('https://github.com/godappslab/signature-verification/contracts/Authentication.sol')
    // -> "0xa01f074d1ad91458d94ad63150c916e533ba96e186df5d7b3d3a036e37e5d22a"
    bytes32 public constant salt = 0xa01f074d1ad91458d94ad63150c916e533ba96e186df5d7b3d3a036e37e5d22a;

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
    function verify(bytes memory _signature, uint256 authId, address user, bytes32 key) public view returns (address) {
        Auth memory auth = Auth({authId: authId, user: user, key: key});
        bytes32 hash = hashAuthentication(auth);
        return hash.recover(_signature);
    }

}
