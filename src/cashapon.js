import web3 from './web3';
import cashapon from './cashapon.json';

// Contract Info: https://ropsten.etherscan.io/address/0x2ef0db93f2Ee173d3e9d6daAAbCa9884bC50fC63#code
const address = '0x2ef0db93f2Ee173d3e9d6daAAbCa9884bC50fC63';
export default new web3.eth.Contract(cashapon, address);
