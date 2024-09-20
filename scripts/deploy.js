async function main() {
  const FunRound = await ethers.getContractFactory("FunRound");
  const funRound = await FunRound.deploy();

  // Wait for the contract to be mined
  await funRound.waitForDeployment();

  console.log("FunRound deployed to:", await funRound.getAddress());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
