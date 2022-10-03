require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config({ path: ".env" });

const ALCHEMY_API_URL = process.env.ALCHEMY_API_URL;
const PRIVATE_KEY_GOERLI = process.env.PRIVATE_KEY_GOERLI;

module.exports = {
  solidity: "0.8.9",
  networks: {
    goerli: {
      url: ALCHEMY_API_URL,
      accounts: [PRIVATE_KEY_GOERLI],
    },
  },
};
