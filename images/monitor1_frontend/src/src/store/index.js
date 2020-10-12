import Vue from 'vue'
import Vuex from 'vuex'

Vue.use(Vuex)

export default new Vuex.Store({
  state: {
    items: []
  },

  mutations: {
    pushItem(state, item) {
      state.items.push(item)
    },

    clear(state) {
      state.items = []
    },

    setItems(state, items) {
      state.items = items
    }
  },

  actions: {
  },

  modules: {
  }
})