<template>
  <v-container>

    <v-row>
      <v-col cols="4" v-for="item in items" :key="item.uuid">
        <CardFaces v-bind:item=item />
      </v-col>
    </v-row>

  </v-container>
</template>

<script>
// @ is an alias to /src
import CardFaces from "../components/CardFaces"


export default {
  name: 'Events',
  
  components: {
    CardFaces,
  },

  computed: {
    items() {
      return this.$store.state.items
    }
  },

  methods: {
    onReceiveEvents(response) {
      console.log("success")
      console.log(response.data)
      this.$store.commit("setItems", response.data)
    }
  },

  created() {
    console.log("Ready")
    console.log(process.env)

    this.$axios.get("/api/events")
      .then(this.onReceiveEvents)
      .catch(function(error){
        console.log("failed")
        console.log(error)
      })
    console.log()
  }
}
</script>
