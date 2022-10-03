const { ethers } = require("hardhat");
require("dotenv").config({ path: ".env" });

async function main() {

  const metadataURL = "ipfs://CID/";
  const name=""
  const token=""

  const NftWhitelist = await ethers.getContractFactory("NftWhitelist");

  // deploy the contract
  const deployedNftWhitelist = await NftWhitelist.deploy(name,token,metadataURL);

  await deployedNftWhitelist.deployed();

  // print the address of the deployed contract
  console.log("Contract Address:", deployedNftWhitelist.address);
}

// Call the main function and catch if there is any error
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
