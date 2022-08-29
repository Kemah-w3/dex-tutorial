const { ethers } = require("hardhat")
const { CRYPTO_DEV_CONTRACT_ADDRESS } = require("../constants")

async function main() {
  const Exchange = await ethers.getContractFactory("Exchange")
  const ExchangeContract = await Exchange.deploy(
    CRYPTO_DEV_CONTRACT_ADDRESS
  )

  await ExchangeContract.deployed()
  console.log(`Exchange contract is successfully deployed to : ${ExchangeContract.address}`)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })