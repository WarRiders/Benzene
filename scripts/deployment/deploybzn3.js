// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");
const fs = require('fs');
const { BigNumber } = require("ethers");

async function main() {
  const oldTeamPool = "0xd053A4Da65691611d0E2a14561386EA39A49b540";
  const oldAdvisorPool = "0xc866a25f68be46365c7F5633827Ef7600B8d1113";
  const gamePoolAddress = "0x83f11770176d959B19F9cC6E2d5a051cb101bdAf";
  const oldBzn = ["0x6524B87960c2d573AE514fd4181777E7842435d4"]
  const l1StandardBridge = "0x99C9fc46f92E8a1c0deC1b1747d010903E884bE1";
  const bannedAddresses = [
    "0xF99240d814ab87F59dEFCf7E78b41b5a165ebb7a",
    "0x54cD51e63bfdDeded12763aAe609f38C005F99Ab"
  ];
  const airdropRedirect = {
    '0x64ab3e2cc5a40b308267ae3def2dc1c0e7fd1d37': 'teampool',
    '0xc7999e15c878a6ab9b86cc754e76d16413ed156f': 'teampool',
    '0xf99240d814ab87f59defcf7e78b41b5a165ebb7a': '0x3259D8f74880DAe5656deEA35D282Dd857509a5F'
  }

  const BenzeneToken = await hre.ethers.getContractFactory("BenzeneTokenV3");
  const BridgedAdvisorPool = await hre.ethers.getContractFactory("BridgedAdvisorPool");
  const BridgedTeamPool = await hre.ethers.getContractFactory("BridgedTeamPool");
  const GamePool = await hre.ethers.getContractFactory("GamePool");

  const gamePool = GamePool.attach(gamePoolAddress);

  let totalGas = BigNumber.from("0");

  console.log("Deploying new pools");
  const advisorPool = await BridgedAdvisorPool.deploy(l1StandardBridge);
  const teamPool = await BridgedTeamPool.deploy(l1StandardBridge);

  await advisorPool.deployed();
  await teamPool.deployed();

  console.log("Calculating total gas");
  const apGas = (await advisorPool.deployTransaction.wait(1)).gasUsed;
  const tpGas = (await teamPool.deployTransaction.wait(1)).gasUsed;
  console.log("Gas used: " + apGas);
  console.log("Gas used: " + tpGas);

  totalGas = totalGas.add(apGas).add(tpGas);
  console.log("Total gas: " + totalGas.toString());

  console.log("Deploying new BZN");
  const bzn = await BenzeneToken.deploy(gamePool.address, 
    teamPool.address, 
    advisorPool.address, 
    oldTeamPool, 
    oldAdvisorPool, 
    oldBzn);
  await bzn.deployed();

  const bznGas = (await bzn.deployTransaction.wait(1)).gasUsed;
  totalGas = totalGas.add(bznGas);
  console.log("Gas used: " + bznGas);
  console.log("Total gas: " + totalGas.toString());

  //console.log("Doing gamepool whitelist");
  //const tx1 = await bzn.toggleTokenMigrationAccess(gamePool.address, true);
  //const receipt1 = await tx1.wait(1);
  //console.log("Gas used: " + receipt1.gasUsed);
  //totalGas = totalGas.add(receipt1.gasUsed);
  //console.log("Total gas: " + totalGas.toString());

  console.log("Doing airdrop transactions");
  const allFileContents = fs.readFileSync('airdrop_data.json', 'utf-8');
  const airdropData = JSON.parse(allFileContents);
  const batchSize = 400;
  let cursor = 0;
  while (cursor < airdropData.length) {
    const endSlice = Math.min(cursor + batchSize, airdropData.length);

    console.log("Grabbing slice " + cursor + " -> " + endSlice);
    const slice = airdropData.slice(cursor, endSlice);

    //Checking if any address needs to be redirected
    for (let i = 0; i < slice.length; i++) {
        const d = slice[i];
        const test = d['address'].toLowerCase();

        if (test in airdropRedirect) {
            let redirect = airdropRedirect[test];
            if (redirect == 'teampool') {
                redirect = teamPool.address;
            }
            d['address'] = redirect;
            console.log("Redirecting " + test + ' -> ' + d['address']);
        }
    }

    //Encode airdrop data
    const addressArray = slice.map(function(d) {
        return d['address'];
    });
    
    const balanceArray = slice.map(function(d) {
        return d['totalBalance'];
    });

    console.log("Encoding data");
    const data = hre.ethers.utils.defaultAbiCoder.encode(["address[]", "uint256[]"], [addressArray, balanceArray]);
    console.log(data);
    console.log("Sending airdrop");
    const tx = await bzn.batchAirdrop(data);
    const receipt = await tx.wait(1);
    console.log("Gas used: " + receipt.gasUsed);
    totalGas = totalGas.add(receipt.gasUsed);
    console.log("Total gas: " + totalGas.toString());

    cursor += batchSize;
  }

  console.log("Token minting done, total supply: " + hre.ethers.utils.formatUnits(await bzn.totalSupply()));
  
  console.log("Doing blocklist");
  for (let i = 0; i < bannedAddresses.length; i++) {
    const bannedAddress = bannedAddresses[i];

    const tx3 = await bzn.blocklistAddress(bannedAddress);
    const receipt3 = await tx3.wait(1);
    console.log("Gas used: " + receipt3.gasUsed);
    totalGas = totalGas.add(receipt3.gasUsed);
    console.log("Total gas: " + totalGas.toString());
  }


  console.log("Total gas: " + totalGas.toString());

  console.log("Doing gamePool migration");
  const tx2 = await gamePool.migrate(bzn.address);
  const receipt2 = await tx2.wait(1);
  console.log("Gas used: " + receipt2.gasUsed);
  totalGas = totalGas.add(receipt2.gasUsed);
  console.log("Total gas: " + totalGas.toString());
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
