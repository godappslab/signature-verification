const HDWalletProvider = require('truffle-hdwallet-provider');

const networkConfig = require('./private_file/network-config.js');
/*
module.exports = {
    ropsten: {
        infuraKey: 'xxxxxx_infula.io's "PROJECT ID"_xxxxxx',
        privateKey: 'xxxxxx_your_eth_address_private_key_xxxxxx',
    },
    private: {
        url: 'http://127.0.0.1:8545/',
        privateKey: 'xxxxxx_your_eth_address_private_key_xxxxxx',
        id: 1234567,
    },
};
 */

module.exports = {
    networks: {
        ropsten: {
            provider: () => new HDWalletProvider(networkConfig.ropsten.privateKey, `https://ropsten.infura.io/v3/${networkConfig.ropsten.infuraKey}`),
            network_id: 3,
            gas: 5500000,
            confirmations: 2,
            timeoutBlocks: 200,
            skipDryRun: true,
        },

        private: {
            provider: () => new HDWalletProvider(networkConfig.private.privateKey, networkConfig.private.url),
            network_id: networkConfig.private.id,
            gas: 5651873,
        },
    },

    mocha: {},

    compilers: {
        solc: {
            version: '0.5.0',
        },
    },
};
