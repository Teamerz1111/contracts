const hre = require("hardhat");

async function main() {
  console.log("Deploying ChainSageMonitor to 0G Chain...");
  console.log("Network:", hre.network.name);
  
  // Get the contract factory
  const ChainSageMonitor = await hre.ethers.getContractFactory("ChainSageMonitor");
  
  // Deploy the contract
  console.log("Deploying contract...");
  const monitor = await ChainSageMonitor.deploy();
  
  // Wait for deployment to finish
  await monitor.waitForDeployment();
  
  // Get the deployed contract address
  const address = await monitor.getAddress();
  
  console.log("\n✅ ChainSageMonitor deployed successfully!");
  console.log("📍 Contract Address:", address);
  console.log("🔍 Block Explorer:", `https://chainscan.0g.ai/address/${address}`);
  console.log("\n📋 Save this address for your WaveHack submission!");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
