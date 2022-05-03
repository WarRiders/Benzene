const L1_ADDRESS = {
  'optimismDev': 'TODO',
  'optimistic-kovan': '0x598C27AC122aF75e9101324b4Fe06656b6520071',
  'optimistic-mainnet': 'TODO'
}

async function main() {
  const L2BenzeneToken = await ethers.getContractFactory("L2BenzeneToken");

  console.log('deploying L2BenzeneToken to', hre.network.name)

  const network = hre.network.name;
  if (!(network in L1_ADDRESS)) {
    throw new Error("Network not supported");
  }

  const l1Token = L1_ADDRESS[network];

  console.log(l1Token);

  if (l1Token == "TODO") {
    throw new Error("Network not configured");
  }

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

  console.log("Deploying L2BZN");
  const L2BZN = await L2BenzeneToken.deploy(
    '0x4200000000000000000000000000000000000010',  // L2 Standard Bridge
    l1Token,                                       // L1 token
    gamePool.address, teamPool.address, advisorPool.address);                                      

  await L2BZN.deployed();

  const symbol = await L2BZN.name();

  console.log("L2BZN deployed to:", L2BZN.address + " " + symbol);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });