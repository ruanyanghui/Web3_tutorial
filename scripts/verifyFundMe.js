

async function main() {
    fundMeaddr = "0x1808f0652eAb41Aa7c4C326B44f13e8ad20287c3"
    args = [300]
    await hre.run("verify:verify", {
        address: fundMeaddr,
        constructorArguments: args,
      });
}

main().then().catch((error) => {
    console.error(error)
    process.exit(1)
})