<template>
<v-card class="mx-auto my-12" width="100%">
    <v-img
        class="white--text align-end"
        height="70px"
        src="@/assets/vacation.jpg"
        >
        <v-card-title>
            Cron Parquet Export 
            <div class="orange--text ml-2">
                {{ item.ellapsed }}
            </div>
        </v-card-title>
    </v-img>

    <v-container>
        <v-row>
            <v-col cols="12">
                <v-data-table
                    :headers="item.table.headers"
                    :items="item.table.data"
                    :items-per-page="2"
                    hide-default-footer
                    class="elevation-1"
                ></v-data-table>
            </v-col>
        </v-row>

    </v-container>
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
