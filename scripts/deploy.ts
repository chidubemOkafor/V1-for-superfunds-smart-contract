import {ethers} from "hardhat";

async function main() {
  const CreateFunding = await ethers.getContractFactory("CreateFunding");
  
  console.log("Deploying CreateFunding contract...");
  const createFunding = await CreateFunding.deploy();
//   await createFunding.deployed();

  console.log("createFunding deployed to: ", createFunding.target);

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
});
