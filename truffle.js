var HDWalletProvider = require("truffle-hdwallet-provider");
var fs = require('fs');
//Deployment address will be 0x4EeABa74D7f51fe3202D7963EFf61D2e7e166cBa

var config = JSON.parse(fs.readFileSync(__dirname + '/.env', 'utf8'));

var mnemonic = config.mnemonic;
var key = config.key;

module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      network_id: "*", // Match any network id
      gas: 0x99999f
   },
   testing: {
    provider: function() {
      return new HDWalletProvider(mnemonic, "https://ropsten.infura.io/" + key)
    },
    network_id: 3,
    gas: 2186549,
    gasPrice: 50
   },
   live: {
    provider: function() {
      return new HDWalletProvider(mnemonic, "https://mainnet.infura.io/" + key)
    },
    network_id: 1,
    gasPrice: 50
   }
  }
};
