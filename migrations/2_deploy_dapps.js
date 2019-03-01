const dapps = artifacts.require('./SignatureVerification.sol');

const name = 'Implementation of signature and verification by EIP712 for internal circulation token';
const version = '1';
const chainId = 4447;
const verifyingContract = '0x1C56346CD2A2Bf3202F771f50d3D14a367B48070';
const salt = '0x70025b6296bdcff22008111bb2928efc4adc9f87ee2021277007fafd8e59aba8';

module.exports = function(deployer) {
    deployer.deploy(dapps, name, version, chainId, verifyingContract, salt);
};
