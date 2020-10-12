<template>
  <v-app>
    <v-app-bar
      app
      color="primary"
      dark
    >
      <div class="d-flex align-center">
        <v-img
          alt="Vuetify Logo"
          class="shrink mr-2"
          contain
          src="@/assets/ngd_logo.svg"
          transition="scale-transition"
          width="125"
        />
      </div>

      <v-btn @click="go('')" target="_blank" text >
          <span class="mr-2">Events</span>
      </v-btn>

      <v-btn @click="go('about')" target="_blank" text >
          <span class="mr-2">About</span>
      </v-btn>

      <v-spacer></v-spacer>

    </v-app-bar>

    <v-main>
      <router-view/>
    </v-main>
  </v-app>
</template>

<script>
import Client from 'socket.io-client'

export default {
  name: 'App',

  data: () => ({
    //
  }),

  methods: {
    go(name, query) {
        if (query)
            this.$router.push({path: "/" + name, query: query})
        else
            this.$router.push({path: "/" + name})
    },

    onWSConnect() {
      console.log("Connected")
    },

    onWSResponse(raw) {
      var buffer = new Uint8Array(raw.data)
      var data = String.fromCharCode.apply(null, buffer)
      var response = JSON.parse(data)
      
      console.log("New item")
      console.log(response)
      this.$store.commit("pushItem", response)
    },

    onWSDisconnect() {
      console.log("Disconnected")
    }
  },

  created() {
    console.log("Connecting WebSocket")

    var socket = Client('http://192.168.1.138:5000/test')

    socket.on('connect', this.onWSConnect)
    socket.on('event', this.onWSResponse)
    socket.on('disconnect', this.onWSDisconnect)
  }

};
</script>
