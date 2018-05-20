const AdvisorPool = artifacts.require('AdvisorPool.sol')
const TeamPool = artifacts.require('TeamPool.sol')
const GamePool = artifacts.require('StandbyGamePool.sol')
const BountyPool = artifacts.require('ManagedPool.sol')
const AirdropPool = artifacts.require('ManagedPool.sol')

module.exports = function(callback) {
    var teamPool;
    var yearInSeconds = 31540000; //1 year in seconds
    var vestingTime = yearInSeconds * 3;

    TeamPool.deployed().then(function(instance) {
        teamPool = instance;
        var now = new Date().getTime() / 1000;
        var jaeAddress = "0x2dF687EE97c989e7dc099bB84e9a840663319723";
        var jaeTokenAmount = web3.toBigNumber('300000e18');

        console.log("Adding vestor at address " + jaeAddress + " giving " + jaeTokenAmount + " over three years with one year lockdown");
        return teamPool.addVestor(jaeAddress, now, yearInSeconds, vestingTime, jaeTokenAmount);
    }).then(() => {
        var now = new Date().getTime() / 1000;

        var vladAddress = "0x008fd0F861Fc941E780320b3ca53D6cad0985A5a";
        var vladTokenAmount = web3.toBigNumber('2800000e18');

        console.log("Adding vestor at address " + vladAddress + " giving " + vladTokenAmount + " over three years with one year lockdown");
        return teamPool.addVestor(vladAddress, now, yearInSeconds, vestingTime, vladTokenAmount);
    }).then(() => {
        var now = new Date().getTime() / 1000;

        var jessAddress = "0xE0005fe64173e0F25B9a90D7b89C8e18D05ae298";
        var jessTokenAmount = web3.toBigNumber('2800000e18');

        console.log("Adding vestor at address " + jessAddress + " giving " + jessTokenAmount + " over three years with one year lockdown");
        return teamPool.addVestor(jessAddress, now, yearInSeconds, vestingTime, jessTokenAmount);
    }).then(() => {
        var now = new Date().getTime() / 1000;

        var edkekAddress = "0x176Fca8fAbed57bE158c2DCb8847d6999e1A2855";
        var edkekTokenAmount = web3.toBigNumber('2800000e18');

        console.log("Adding vestor at address " + edkekAddress + " giving " + edkekTokenAmount + " over three years with one year lockdown");
        return teamPool.addVestor(edkekAddress, now, yearInSeconds, vestingTime, edkekTokenAmount);
    }).then(() => {
        callback();
    }).catch(function(error) {
        callback(error);
    })
};