const AdvisorPool = artifacts.require('AdvisorPool.sol')
const TeamPool = artifacts.require('TeamPool.sol')
const GamePool = artifacts.require('StandbyGamePool.sol')
const BountyPool = artifacts.require('ManagedPool.sol')
const AirdropPool = artifacts.require('ManagedPool.sol')

module.exports = function(callback) {
    //var newOwner = "0xb144a79aab20da41339a00b70378cf64f74f1fb8";
    var newOwner = "0x4472A4b8F2194788dbFc717811392E0Aa6b30BF5";

    AdvisorPool.deployed().then(function(instance) {
        console.log("Transfering ownership of " + instance.address);
        return instance.transferOwnership(newOwner);
    }).then(() => {
        return TeamPool.deployed();
    }).then(function(instance) {
        console.log("Transfering ownership of " + instance.address);
        return instance.transferOwnership(newOwner);
    }).then(() => {
        return GamePool.deployed();
    }).then(function(instance) {
        console.log("Transfering ownership of " + instance.address);
        return instance.transferOwnership(newOwner);
    }).then(() => {
        callback();  
    }).catch(function(error) {
        callback(error);
    });
}