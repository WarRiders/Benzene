// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const BenzeneToken = await hre.ethers.getContractFactory("BenzeneToken");
  const StandbyGamePool = await hre.ethers.getContractFactory("StandbyGamePool");
  const AdvisorPool = await hre.ethers.getContractFactory("AdvisorPool");
  const TeamPool = await hre.ethers.getContractFactory("TeamPool");

  console.log("Deploying TeamPool");
  const teamPool = await TeamPool.deploy();
  await teamPool.deployed();

  console.log("Deploying GamePool");
  const gamePool = await StandbyGamePool.deploy();
  await gamePool.deployed();

  console.log("Deploying AdvisorPool");
  const advisorPool = await AdvisorPool.deploy();
  await advisorPool.deployed();

  console.log("GamePool: " + gamePool.address);
  console.log("TeamPool: " + teamPool.address);
  console.log("Advisor Pool: " + advisorPool.address);

  console.log("Deploying BZN");
  const bzn = await BenzeneToken.deploy(gamePool.address, teamPool.address, advisorPool.address);

  await bzn.deployed();

  console.log("BZN: " + bzn.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
