<template>
  <div class="container">
    <div class="stage">
      <div class="game-name" v-show="!isStart">数独</div>
      <div class="content clearfix" v-show="isStart">
        <div v-for="(item, index) in randomData" :key="item" :class="`img-4`">
          <div
            :style="{
              width: '100px',
              height: '100px',
              opacity: item.canEdit ? 1 : 0.95,
              border:
                index === activeIndex ? '3px solid #fff' : '1px solid #000',
              backgroundColor: item.color || '#c4c4c4',

              animation:
                index === activeIndex ? 'blinking 1s infinite' : 'none',
            }"
          ></div>
        </div>
      </div>
    </div>
    <div class="other">
      <Control :games="games"></Control>
    </div>
  </div>
</template>

<script setup lang="ts">
import Control from "./components/control.vue";
import { onBeforeUnmount, onMounted, reactive, toRefs } from "vue";
import Sudoku from "@/utils/sudoku";
let games = reactive(Sudoku);
const { randomData, isStart, activeIndex } = toRefs(games);

// 鼠标移动图片
const handleMove = (index: number) => {
  // games.move(index)
};
// 键盘事件
const handleKeyDown = (e: any) => {
  if (!isStart.value) return;
  games.onKeydown(e.keyCode);
};
onMounted(() => {
  document.addEventListener("keydown", handleKeyDown);
});
onBeforeUnmount(() => {
  document.removeEventListener("keydown", handleKeyDown);
});
</script>

<style>
@keyframes blinking {
  0% {
    border-color: #fff;
  }
  50% {
    border-color: transparent;
  }
  100% {
    border-color: #fff;
  }
}
</style>
