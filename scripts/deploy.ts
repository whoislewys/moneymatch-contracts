import { ethers } from "hardhat";

async function main() {
  const EscrowFactory = await ethers.getContractFactory("EscrowFactory");
  const deployTx = await EscrowFactory.deploy();
  deployTx.deployed();
  console.log('EscrowFactory deployed to: ', deployTx.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
