
<template>
  <v-app>
    <v-toolbar class="toolbar-background" @click="onPlayBackground"></v-toolbar>
    <v-container fluid>
      <v-card>
        <v-layout align-center justify-center column fill-height>
          <v-flex xs12 class="relative">
            <img alt="Cashapon" src="./assets/gasha-machine.png">
            <img
              v-bind:class="['gasha-handle', isPlaying ? 'gasha-handle-spin' : '']"
              src="./assets/gasha-handle.png"
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
      <v-dialog v-model="dialogVisible" width="500">
        <v-card>
          <v-card-title class="headline grey lighten-2" primary-title>Yay! Casha!!</v-card-title>
          <v-card-text class="test">
            <v-layout align-center justify-center column fill-height>
              <v-flex xs12>
                <div style="position: relative; height: 250px; width: 216px; margin: 0 auto;">
                  <img
                    v-bind:class="['test-img', !GashaToggle ? 'test-img-transparent' : '']"
                    src="./assets/gasha-close.png"
                  >
                  <img
                    v-bind:class="['test-img', GashaToggle ? 'test-img-transparent' : '']"
                    src="./assets/gasha-open.png"
                  >
                </div>
              </v-flex>
              <v-flex xs12>
                <v-btn round color="success" @click="onGoToEtherscan">See what I cashaed</v-btn>
              </v-flex>
            </v-layout>
          </v-card-text>
          <v-divider></v-divider>
          <v-card-actions>
            <v-spacer></v-spacer>
            <v-btn color="primary" flat @click="dialogVisible = false">Close</v-btn>
          </v-card-actions>
        </v-card>
      </v-dialog>
    </v-container>
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
import { clearInterval, setInterval } from 'timers';

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
      numTokens: 1,
      GashaToggleTimerId: null,
      GashaToggle: false,
      prevSound: null,
    };
  },
  async mounted() {
    try {
      this.prevSound = await this.playSound('background');
    } catch (error) {
      console.log(error);
    }
  },
  created() {
    console.log('ACCOUNT:', web3.eth.getAccounts());

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
    async onPlayBackground() {
      this.prevSound = await this.playSound('background');
    },
    async playSound(soundFile) {
      const source = new Audio(`/${soundFile}.mp3`);
      if (this.prevSound) {
        this.prevSound.pause();
        this.prevSound.currentTime = 0;
      }
      await source.play();
      return source;
    },
    onGoToEtherscan() {
      window.open(this.etherScan + this.txHash, '_blank');
    },
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
        if (this.numTokens > 1) {
          await cashapon.methods.play().send({
            gas: '500000',
            from: accounts[0],
            value: web3.utils.toWei(this.ether, 'ether'),
          });
        } else {
          // TODO: add playMultiple(numTokens)
          await cashapon.methods.playMultiple(this.numTokens).send({
            gas: '1100000',
            from: accounts[0],
            value: web3.utils.toWei(this.ether, 'ether'),
          });
        }
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
    async dialogVisible(newDialogVisible) {
      if (newDialogVisible) {
        this.prevSound = await this.playSound('applause');
        this.GashaToggleTimerId = setInterval(() => {
          this.GashaToggle = !this.GashaToggle;
        }, 500);
      } else {
        clearInterval(this.GashaToggleTimerId);
      }
    },
  },
};
</script>

<style scoped>
.test-img {
  transition: opacity 0s ease-in-out;
  position: absolute;
}

.test-img-transparent {
  opacity: 0;
}

.toolbar-background {
  background: no-repeat url('./assets/logo.png'),
    linear-gradient(to right, #6cd4b3 0%, #6cd4b3 50%, #fbe357 50%, #fbe357 50%);
  height: 150px;
  background-size: contain;
  background-position: center center;
}

.button-width {
  width: 195px !important;
}

.relative {
  position: relative;
}

.gasha-handle {
  z-index: 10;
  position: absolute;
  top: 177px;
  left: 155px;
}
.gasha-handle-spin {
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

.logo {
  object-fit: cover;
  height: 50px;
}

.no-text-decoration {
  text-decoration: none;
}
</style>
