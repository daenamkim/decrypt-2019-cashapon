
<template>
  <v-app>
    <v-toolbar>
      <v-spacer></v-spacer>
      <v-toolbar-title>$$ Cashapon $$</v-toolbar-title>
      <v-spacer></v-spacer>
    </v-toolbar>
    <v-container fluid>
      <v-card>
        <v-layout align-center justify-center column fill-height>
          <v-flex xs12 class="relative">
            <img alt="Cashapon" src="./assets/gatcha.png">
            <img
              v-bind:class="['gatcha-handle', isPlaying ? 'gatcha-handle-spin' : '']"
              src="./assets/gatcha-handle.png"
              @click="onPlay"
            >
          </v-flex>
          <v-flex xs12 sm6 md3>
            <v-text-field
              label="Put Your Ether"
              outline
              v-model="ether"
              v-bind:disabled="isPlaying"
            ></v-text-field>
          </v-flex>
          <v-flex xs12 sm6 md3 v-if="isPlaying">
            <v-chip
              color="orange"
              text-color="white"
            >Don't close this app! Please have your patience!</v-chip>
          </v-flex>
        </v-layout>
      </v-card>
    </v-container>

    <v-dialog v-model="dialogVisible" width="500">
      <v-card>
        <v-card-title class="headline grey lighten-2" primary-title>Yay! Gatcha!!</v-card-title>
        <v-card-text>
          You can check your coin of the ether you used below
          <a
            v-bind:href="etherScan + txHash"
            target="_blank"
          >{{ this.txHash }}</a>
        </v-card-text>
        <v-divider></v-divider>
        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn color="primary" flat @click="dialogVisible = false">Close</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
    <v-footer class="pa-3">
      <v-spacer></v-spacer>
      <div>Anton Buenavista, Daenam Kim, Masahiro Takeda and Takuya Umeki @ Decrypt Tokyo 2019</div>
    </v-footer>
  </v-app>
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
      dialogVisible: false,
    };
  },
  created() {
    console.log(web3.eth.getAccounts());

    cashapon.events
      .Played({ fromBlock: 'latest' }, (error, event) => {
        console.log(event);
        this.isPlaying = false;
        this.txHash = event.transactionHash;
        this.dialogVisible = true;
      })
      .on('data', event => {
        console.log('data', event); // same results as the optional callback above
      })
      .on('changed', event => {
        // remove event from local database
        console.log('changed', event); // same results as the optional callback above
      })
      .on('error', error => {
        console.error(error);
        this.isPlaying = false;
        this.txHash = '';
      });
  },
  methods: {
    async onPlay() {
      if (
        parseFloat(this.ether) < 0.1 ||
        parseFloat(this.ether) > 1 ||
        this.isPlaying
      ) {
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
    },
  },
  watch: {
    ether(newEther) {
      console.log(newEther);
    },
  },
};
</script>

<style>
.button-width {
  width: 195px !important;
}

.relative {
  position: relative;
}

.gatcha-handle {
  z-index: 10;
  position: absolute;
  top: 177px;
  left: 267px;
}
.gatcha-handle-spin {
  animation: element-spin 2s linear infinite;
}

@keyframes element-spin {
  0% {
    transform: rotate(0deg);
  }
  100% {
    transform: rotate(360deg);
  }
}
</style>
