/* global artifacts */
/* eslint-disable */
const fs = require('fs');

const Cashapon = artifacts.require('./Cashapon.sol');

const networkConfig = JSON.parse(fs.readFileSync('../config/network.json', 'utf8'));
const tokenConfig = JSON.parse(fs.readFileSync('../config/tokens.json', 'utf8'));

module.exports = async (deployer, network, accounts) => {
  const admin = accounts[0];

  // Deploy the contracts
  await deployer.deploy(Cashapon, networkConfig.KyberNetworkProxy, admin, tokenConfig.Tokens);
};
