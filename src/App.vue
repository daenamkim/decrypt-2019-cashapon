
<template>
  <div id="app">
    <div>
      <img alt="Vue logo" src="./assets/logo.png" />
    </div>
    <div>
      <input type="text" v-model="ether" v-bind:disabled="isPlaying"/>
    </div>
    <div>
      <button @click="onPlay" v-bind:disabled="isPlaying">Play!</button>
    </div>
    <div v-bind:hidden="!isPlaying">
      Playing... Have your patience
    </div>
    <div>
      <a v-bind:href="etherScan + txHash" target="_blank">{{ this.txHash }}</a>
    </div>
  </div>
</template>

<script>
/* eslint-disable no-console */
import web3 from './web3';
import cashapon from './cashapon';

export default {
  name: 'app',
  components: {},
  data() {
    return {
      ether: '0.1',
      etherScan: 'https://ropsten.etherscan.io/tx/',
      txHash: '',
      isPlaying: false,
    };
  },
  created() {
    console.log(web3.eth.getAccounts());

    cashapon.events.Played({fromBlock: "latest"}, (error, event) => {
          console.log(event);
          this.isPlaying = false;
          this.txHash = event.transactionHash;
        }).on('data', (event) => {
          console.log('data', event); // same results as the optional callback above
        }).on('changed', (event) => {
            // remove event from local database
            console.log('changed', event); // same results as the optional callback above
        }).on('error', (error) => {
          console.error(error);
          this.isPlaying = false;
          this.txHash = '';
        });
  },
  methods: {
    async onPlay() {
      if (parseFloat(this.ether) < 0.1 || parseFloat(this.ether) > 1 || this.isRunning) {
        return;
      }

      this.txHash = '';
      this.isPlaying = true;

      try {
        const accounts = await web3.eth.getAccounts();
        await cashapon.methods.play().send({
          from: accounts[0],
          value: web3.utils.toWei(this.ether, 'ether'),
        });
      } catch (error) {
        console.log(error);
        this.isPlaying = false;
      }
    }
  },
  watch: {
    ether(newEther) {
      console.log(newEther);
    }
  }
}
</script>

<style>
#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}
</style>
