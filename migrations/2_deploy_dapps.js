/* global artifacts, contract, before, it, assert */
const fs = require('fs');
const TokenExchangeVerification = artifacts.require('./TokenExchangeVerification.sol');
const Authentication = artifacts.require('./Authentication.sol');

const getChainId = (network) => {
    switch (network) {
        case 'develop':
            return 4447;
        case 'ropsten':
            return 3;
    }
};

module.exports = function(deployer, network) {
    const chainId = getChainId(network);

    console.log('** network', network);
    console.log('** chainId', chainId);

    deployer.deploy(TokenExchangeVerification, chainId).then(() => {
        // Save ABI to file
        fs.mkdirSync('deploy/abi/', { recursive: true });
        fs.writeFileSync('deploy/abi/TokenExchangeVerification.json', JSON.stringify(TokenExchangeVerification.abi), { flag: 'w' });
    });
    deployer.deploy(Authentication, chainId).then(() => {
        // Save ABI to file
        fs.mkdirSync('deploy/abi/', { recursive: true });
        fs.writeFileSync('deploy/abi/Authentication.json', JSON.stringify(Authentication.abi), { flag: 'w' });
    });
};
