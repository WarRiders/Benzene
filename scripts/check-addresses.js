// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");
const fs = require('fs');
const { BigNumber } = require("ethers");

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
  const bzn2 = BenzeneToken.attach("0x85171d9cD1CfD8B10072096763674392176f039b");
  const bzn3 = BenzeneToken.attach("0x1BD223e638aEb3A943b8F617335E04f3e6B6fFfa");
  const bznAddresses = [bzn.address.toLowerCase(), bzn2.address.toLowerCase(), bzn3.address.toLowerCase()];
  const balanceHolders = [];
  const allFileContents = fs.readFileSync('data/token_holders.csv', 'utf-8');
  const lines = allFileContents.split(/\r?\n/);
  let total = BigNumber.from("0");

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];

    const columns = line.split(",");
    const address = columns[0].trim();

    if (address && address != "address" && address != "") {
        if (bznAddresses.includes(address.toLowerCase())) {
            console.log("Skipping BZN token: " + address);
            continue;
        }
        console.log("Checking address: " + address);
        const balance = await bzn.balanceOf(address);
        const balance2 = await bzn2.balanceOf(address);
        const balance3 = await bzn3.balanceOf(address);

        if (!balance.isZero() || !balance2.isZero() || !balance3.isZero()) {
            console.log("Is balance holder: " + balance);
            const totalBalance = balance.add(balance2).add(balance3).toString()
            balanceHolders.push({
                address, totalBalance
            });
            total = total.add(totalBalance);
            console.log("New total: " + hre.ethers.utils.formatUnits(total));
        } else {
            console.log("Not a balance holder");
        }
    }
  }
  const json  = JSON.stringify(balanceHolders);
  fs.writeFileSync('airdrop_data.json', json);
  console.log(JSON.stringify(balanceHolders));
  console.log("Total: " + total);

  const teamPoolTotal = BigNumber.from("19837817600313203225442286");
  const advisorPoolTotal = BigNumber.from("4828119999999999999985000");
  const totalSupply = total.add(teamPoolTotal).add(advisorPoolTotal);
  console.log("Total with both Pools: " + hre.ethers.utils.formatUnits(totalSupply));
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
