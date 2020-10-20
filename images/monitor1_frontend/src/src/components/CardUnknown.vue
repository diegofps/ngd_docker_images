<template>
<v-card class="mx-auto my-12" width="100%">
    <v-container>

        <v-row>
            <v-col cols="12">
                <v-card-title>Unknown Event</v-card-title>
                <v-card-subtitle> type: {{ item.type }} </v-card-subtitle>
            </v-col>
        </v-row>
    </v-container>
</v-card>
</template>

<script>
  export default {
    name: 'CardUnknown',

    props: ["item"],

    data: () => ({
    })
  }
</script>
