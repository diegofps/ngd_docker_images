<template>
<v-card class="mx-auto my-12" width="100%">
    <v-container>
        <v-row>
            <v-col cols="4">
                <v-img height="100%" :src="'data:image/jpg;base64, ' + item.b64image" />
            </v-col>
            <v-col cols="8">
                <v-row>
                    <v-col cols=6>
                        <v-card-title>Node</v-card-title>
                        <v-card-subtitle> {{item.hostname}} </v-card-subtitle>
                    </v-col>

                    <v-col cols=6>
                        <v-card-title>Parsed at</v-card-title>
                        <v-card-subtitle> {{item.created_at}} </v-card-subtitle>
                    </v-col>
                </v-row>

                <v-row>
                    <v-col cols=12>
                        <v-card-title>Filepath</v-card-title>
                        <v-card-subtitle> {{item.path}} </v-card-subtitle>
                    </v-col>
                </v-row>

                <v-card-actions>
                    <v-btn color="lighten-2" text @click="toggleFaces">
                        {{item.faces.length}} faces
                    </v-btn>

                    <v-spacer />

                    <v-btn icon @click="toggleFaces">
                        <v-icon>{{ show ? 'mdi-chevron-up' : 'mdi-chevron-down' }}</v-icon>
                    </v-btn>
                </v-card-actions>

            </v-col>
        </v-row>
    </v-container>
    



    <v-divider></v-divider>

    <v-expand-transition>
        <div v-show="show">
            <v-divider></v-divider>

            <v-container>
                <v-row class="mr-1 ml-1">
                    <v-col cols="1" v-for="face in item.faces" :key="face.uuid">
                        <v-img height="100%" :src="'data:image/jpg;base64, ' + face.b64image" style="border-radius: 50%" />
                    </v-col>
                </v-row>
            </v-container>

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
    }),

    methods: {
        toggleFaces() {
            this.show = !this.show
        }
    }
  }
</script>
