import web3 from './web3';
import cashapon from './cashapon.json';

// Contract Info: https://ropsten.etherscan.io/address/0x1670dfb52806de7789d5cf7d5c005cf7083f9a5d#contracts
const address = '0x1670dfb52806de7789d5cf7d5c005cf7083f9a5d';
export default new web3.eth.Contract(cashapon, address);
