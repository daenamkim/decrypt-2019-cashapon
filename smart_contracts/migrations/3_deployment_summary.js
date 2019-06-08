/* global artifacts */
/* eslint-disable no-unused-vars, no-eval */
const fs = require('fs');

const Cashapon = artifacts.require('./Cashapon.sol');

const networkConfig = JSON.parse(fs.readFileSync('../config/network.json', 'utf8'));
const tokenConfig = JSON.parse(fs.readFileSync('../config/tokens.json', 'utf8'));

module.exports = (deployer, network, accounts) => {
  console.log('\n');

  console.log('Network');
  console.log('==================');
  console.log(network);

  console.log('\n');

  console.log('Permissions');
  console.log('==================');
  console.log(`(admin) ${accounts[0]}`);

  console.log('\n');

  console.log('Tokens');
  console.log('==================');
  tokenConfig.Tokens.forEach((token) => {
    console.log(token);
  });

  console.log('\n');

  console.log('Contracts');
  console.log('==================');
  console.log(`(KyberNetworkProxy) ${networkConfig.KyberNetworkProxy}`);
  console.log(`(Cashapon) ${Cashapon.address}`);
};
