const BenzeneToken = artifacts.require('BenzeneToken.sol')
const AdvisorPool = artifacts.require('AdvisorPool.sol')
const TeamPool = artifacts.require('TeamPool.sol')
const GamePool = artifacts.require('StandbyGamePool.sol')
const BountyPool = artifacts.require('ManagedPool.sol')
const AirdropPool = artifacts.require('ManagedPool.sol')

module.exports = deployer => {

  

  deployer.deploy(AdvisorPool).then(() => {
    return deployer.deploy(TeamPool);
  }).then(() => {
    return deployer.deploy(GamePool);
  }).then(() => {
    return deployer.deploy(BenzeneToken, GamePool.address, TeamPool.address, AdvisorPool.address);
  });
}