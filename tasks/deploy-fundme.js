const { task } = require("hardhat/config")

task("deploy-fundme","deploy and verify fundme conract").setAction(async(taskArgs,hre) => {
    // create factory

    const fundMeFactory = await ethers.getContractFactory("FundMe")
    console.log("helllo");
    // deploy contract from factory
    const fundMe = await fundMeFactory.deploy(300)
    await fundMe.waitForDeployment() 
    console.log(`contract has been deployed successfully, contract address is ${fundMe.target}`);
    
    // verify fundme
    if (hre.network.config.chainId == 11155111 && process.env.ETHERSCAN_API_KEY) {
        console.log("waiting for 5 confirmations")
        await fundMe.deploymentTransaction().wait(5)
        await verifyFundMe(fundMe.target, [300])
    } else {
        console.log("verification skipped..")
    }
})



async function verifyFundMe(fundMeaddr, args) {

    await hre.run("verify:verify", {
        address: fundMeaddr,
        constructorArguments: args,
      });
}

module.exports = {}