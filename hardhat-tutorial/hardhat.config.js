require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config({path: ".env"})

const API_KEY = process.env.API_KEY
const PRIVATE_KEY = process.env.PRIVATE_KEY

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.9",
  networks: {
    rinkeby: {
      url: API_KEY,
      accounts: [PRIVATE_KEY]
    }
  },
  etherscan: {
    apiKey: "6J7GV8U3K52YPSQ831CG817UB4PDVNHMQW"
  }
};
