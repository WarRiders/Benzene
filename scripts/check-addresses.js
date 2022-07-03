// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");
const fs = require('fs');

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const BenzeneToken = await hre.ethers.getContractFactory("BenzeneToken");

  const bzn = BenzeneToken.attach("0x6524B87960c2d573AE514fd4181777E7842435d4");

  const balanceHolders = [];
  const allFileContents = fs.readFileSync('data/active_users.csv', 'utf-8');
  const lines = allFileContents.split(/\r?\n/);

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];

    const columns = line.split(",");
    const address = columns[0].trim();

    if (address && address != "address" && address != "") {
        console.log("Checking address: " + address);
        const balance = await bzn.balanceOf(address);
        if (!balance.isZero()) {
            console.log("Is balance holder: " + balance);
            balanceHolders.push(address);
        } else {
            console.log("Not a balance holder");
        }
    }
  }

  console.log(JSON.stringify(balanceHolders));
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
