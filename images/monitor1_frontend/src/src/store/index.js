import Vue from 'vue'
import Vuex from 'vuex'

Vue.use(Vuex)

export default new Vuex.Store({
  state: {
    items: [{}]
  },

  mutations: {
    addMsg(state, event) {
      state.items.push({event})
    },

    clear(state) {
      state.items = []
    }
  },

  actions: {
  },

  modules: {
  }
})