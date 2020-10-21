<template>
<v-card class="mx-auto my-12" width="100%">
    <v-img
        class="white--text align-end"
        height="70px"
        src="@/assets/vacation.jpg"
        >
        <v-card-title>
            Cron Parquet Backup 
            <div class="orange--text ml-2">
                {{ item.ellapsed }}
            </div>
        </v-card-title>
    </v-img>

    <v-row>
        <v-col cols=3>
            <v-card-title>Node</v-card-title>
            <v-card-subtitle> {{ item.hostname }} </v-card-subtitle>
            <v-card-title>Parsed at</v-card-title>
            <v-card-subtitle> {{ item.created_at }} </v-card-subtitle>
        </v-col>

        <v-col cols=9>
            <v-container>
                <v-data-table
                    :headers="item.table.headers"
                    :items="item.table.data"
                    :items-per-page="2"
                    dark
                    hide-default-footer
                    class="elevation-1"
                ></v-data-table>
            </v-container>
        </v-col>
    </v-row>

</v-card>
</template>

<script>
  export default {
    name: 'CardCron',

    props: ["item"],

    data: () => ({
    })
  }
</script>
