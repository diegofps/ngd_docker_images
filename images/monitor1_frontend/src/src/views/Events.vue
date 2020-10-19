<template>
  <v-container>

    <v-row>
      <v-btn block elevation="4" @click="clear">
        Clear
      </v-btn>
    </v-row>

    <v-row>
      <template v-for="item in items"> 
        <CardFaces v-bind:item=item :key="item.uuid" v-if="item.type === 'faces'" />
        <CardCron v-bind:item=item :key="item.uuid" v-else-if="item.type === 'cron'" />
        <CardUnknown v-bind:item=item :key="item.uuid" v-else />
      </template>
        
    </v-row>

  </v-container>
</template>

<script>
// @ is an alias to /src
import CardFaces from "../components/CardFaces"
import CardCron from "../components/CardCron"
import CardUnknown from "../components/CardUnknown"


export default {
  name: 'Events',
  
  components: {
    CardFaces,
    CardCron,
    CardUnknown
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
    },

    clear() {
      this.$store.commit("clearItems")
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
