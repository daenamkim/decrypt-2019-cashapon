// All code examples in this guide have not been audited and should not be used in production.
// If so, it is done at your own risk!

/* global artifacts, web3 */
/* eslint-disable no-underscore-dangle, no-unused-vars */
const BN = require('bn.js');
const moment = require('moment');

const Cashapon = artifacts.require('./Cashapon.sol');

function stdlog(input) {
  console.log(`${moment().format('YYYY-MM-DD HH:mm:ss.SSS')}] ${input}`);
}

function tx(result, call) {
  const logs = result.logs.length > 0 ? result.logs[0] : { address: null, event: null };

  console.log();
  console.log(`   ${call}`);
  console.log('   ------------------------');
  console.log(`   > transaction hash: ${result.tx}`);
  console.log(`   > contract address: ${logs.address}`);
  console.log(`   > gas used: ${result.receipt.gasUsed}`);
  console.log(`   > event: ${logs.event}`);
  console.log();
}

module.exports = async (callback) => {
  const accounts = web3.eth.accounts._provider.addresses;
  const userWallet = accounts[4];
  let expectedRate;
  let slippageRate;
  let result;

  // Set the instances
  const CashaponInstance = await Cashapon.at(Cashapon.address);

  stdlog('- START -');
  stdlog(`Cashapon (${Cashapon.address})`);

  stdlog(
    `ETH balance of ${userWallet} = ${web3.utils.fromWei(await web3.eth.getBalance(userWallet))}`,
  );

  result = await CashaponInstance.play(
    { from: userWallet, value: web3.utils.toWei(new BN(1)) },
  );
  tx(result, 'Cashapon!!');

  stdlog(
    `ETH balance of ${userWallet} = ${web3.utils.fromWei(await web3.eth.getBalance(userWallet))}`,
  );

  stdlog('- END -');
  callback();
};
