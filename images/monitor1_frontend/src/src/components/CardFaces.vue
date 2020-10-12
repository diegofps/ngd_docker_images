<template>
<v-card class="mx-auto my-12" >
    <v-img height="200" :src="'data:image/jpg;base64, ' + item.b64image" />

    <v-row class="mr-1 ml-1">
    <v-col cols="3" v-for="face in item.faces" :key="face.uuid">
        <v-img height="100%" :src="'data:image/jpg;base64, ' + face.b64image" style="border-radius: 50%" />
    </v-col>
    </v-row>


    <v-divider class="mx-4"></v-divider>

    <v-card-actions>
    <v-btn color="orange lighten-2" text >
        More
    </v-btn>

    <v-spacer></v-spacer>

    <v-btn
        icon
        @click="show = !show"
    >
        <v-icon>{{ show ? 'mdi-chevron-up' : 'mdi-chevron-down' }}</v-icon>
    </v-btn>
    </v-card-actions>

    <v-expand-transition>
    <div v-show="show">
        <v-divider></v-divider>

        <v-card-title>Hostname</v-card-title>
        <v-card-subtitle> {{item.hostname}} </v-card-subtitle>

        <v-card-title>Location</v-card-title>
        <v-card-subtitle> {{item.path}} </v-card-subtitle>

        <v-card-title>Parsed at</v-card-title>
        <v-card-subtitle> {{item.created_at}} </v-card-subtitle>

    </div>
    </v-expand-transition>
    </v-card>
</template>

<script>
  export default {
    name: 'CardFaces',

    props: ["item"],

    data: () => ({
        show: false
    })
  }
</script>
