import Vue from 'vue'
import Vuex from 'vuex'

Vue.use(Vuex)

export default new Vuex.Store({
  state: {
    items: []
  },

  mutations: {
    pushItem(state, item) {
      state.items.unshift(item)
    },

    clearItems(state) {
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