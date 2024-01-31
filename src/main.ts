import { createApp } from "vue"
import App from "./App.vue"
import ElementPlus from "element-plus"
import "element-plus/dist/index.css"
import "./style/index.scss"

import * as VueRouter from 'vue-router'

import PuzzleGames from "@/views/puzzle/index.vue"
import SudoKuGames from "@/views/sudoku/index.vue"


const routes = [
  { path: '/klotski', component: PuzzleGames , name: 'klotski'},
  { path: '/sudoku', component: SudoKuGames , name: 'sudoku'},
  {path: '/', redirect: '/sudoku'},
]

const router = VueRouter.createRouter({
  history: VueRouter.createWebHashHistory(),
  routes, 
})

const app = createApp(App)
app.use(router)
app.use(ElementPlus)

app.mount('#app')
  
