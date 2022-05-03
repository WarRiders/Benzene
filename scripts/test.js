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
  const FaucetGamePool = await hre.ethers.getContractFactory("FaucetGamePool");
  const StandbyGamePool = await hre.ethers.getContractFactory("StandbyGamePool");

  console.log("Deploying FaucetGamePool");
  const gPool = await FaucetGamePool.deploy();
  await gPool.deployed();

  const oldgpool = StandbyGamePool.attach("0x708d103424674547238d60E8Fde806eb74560e25");

  await oldgpool.update(gPool.address);

  await gPool.setMaxRequestAmount("1000000000000000000000");

  await gpool.requestBZN("0x4EeABa74D7f51fe3202D7963EFf61D2e7e166cBa", "500000000000000000000")
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
