
<template>
  <div id="app">
    <img alt="Vue logo" src="./assets/logo.png" />
    <form @submit.prevent="onSubmit">
      <input type="text" v-model="money" />
      <input type="submit" />
    </form>
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
      money: '',
    };
  },
  created() {
    console.log(web3.eth.getAccounts());
  },
  methods: {
    async onSubmit() {
      try {
        const accounts = await web3.eth.getAccounts();
        // For Test
        // await web3.eth.sendTransaction({
        //     from: accounts[0],
        //     to: '0x3F37278403BF4Fa7c2B8fa0D21Af353c554641A1',
        //     value: web3.utils.toWei('1'),
        //     gas: 2000000
        // });
        if (!this.money) {
          return;
        }

        await cashapon.methods.play().send({
          from: accounts[0],
          value: web3.utils.toWei(this.money, 'ether'),
        });

        // TODO: get result
      } catch (error) {
        console.log(error);
      }
    }
  },
  watch: {
    money(newMoney) {
      console.log(newMoney);
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
