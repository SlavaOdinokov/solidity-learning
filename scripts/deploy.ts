import { ethers } from "hardhat";

async function main() {
  const [signer] = await ethers.getSigners();

  const Shop = await ethers.getContractFactory("MShop", signer);
  const shop = await Shop.deploy();

  await shop.deployed();

  console.log(
    `Shop deployed to address ${shop.address} with token ${await shop.token()}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
