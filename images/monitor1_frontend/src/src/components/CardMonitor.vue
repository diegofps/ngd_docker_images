<template>
<v-card class="mx-auto my-12" width="100%">
    <v-img
        class="white--text align-end"
        height="70px"
        src="@/assets/pug1.jpg"
        >
        <v-card-title>
            Monitor Result
            <div class="orange--text ml-2">
                {{ item.ellapsed }}
            </div>
        </v-card-title>
    </v-img>

    <v-container>
        <v-row>
            <v-col cols="4">
                <v-card height=100%>
                    <v-img elevation=3 height=100% :src="'data:image/jpg;base64, ' + item.b64image" />
                </v-card>
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
                    <v-btn color="lighten-2" text @click="toggleFaces" v-if="item.faces.length !== 0">
                        {{item.faces.length}} faces
                    </v-btn>

                    <v-btn color="lighten-2" text @click="togglePlates" v-if="item.plates.length !== 0">
                        {{item.plates.length}} license plates
                    </v-btn>
                </v-card-actions>

            </v-col>
        </v-row>
    </v-container>
    
    <v-divider></v-divider>

    <v-expand-transition>
        <div v-show="showFaces">
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

    <v-expand-transition>
        <div v-show="showPlates">
            <v-divider></v-divider>

            <v-container>
                <v-row class="mr-1 ml-1">
                    <v-col cols="3" v-for="plate in item.plates" :key="plate.uuid">
                        <v-card elevation=3>
                            <v-img  width="150%" :src="'data:image/jpg;base64, ' + plate.b64image" />
                        </v-card>

                        <v-container>
                            <p class="text-center mb-0 font-weight-bold">
                                {{ plate.p1}}
                            </p>
                        </v-container>
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
        showFaces: false,
        showPlates: false
    }),

    methods: {
        toggleFaces() {
            this.showPlates = false
            this.showFaces = !this.showFaces
        },
        togglePlates() {
            this.showFaces = false
            this.showPlates = !this.showPlates
        }
    }
  }
</script>
