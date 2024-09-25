async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);

  // Check balance
  const balance = await ethers.provider.getBalance(deployer.address);
  console.log("Account balance:", ethers.formatEther(balance), "ETH");

  const FunRound = await ethers.getContractFactory("FunRound");
  const funRound = await FunRound.deploy(); // Deploy the contract

  await funRound.deployed();
  console.log("FunRound deployed to:", funRound.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
