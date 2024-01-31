<template>
  <div class="control">
    <div class="line">
      <span class="label" style="margin-right: 10px">游戏</span>
      <el-select v-model="key" :disabled="games.isStart" @change="selectGame">
        <el-option
          v-for="item in gameList"
          :key="item.key"
          :label="item.value"
          :value="item.key"
        />
      </el-select>
    </div>
    <div class="line">
      <el-button type="primary" @click="changeGame">{{
        games.isStart ? "结束游戏" : "开始游戏"
      }}</el-button>
    </div>
  </div>
</template>
<script lang="ts" setup>
import { reactive, toRefs } from "vue";
import { useRouter, useRoute } from "vue-router";

const router = useRouter();
const route = useRoute();

const props = defineProps<{ games: any }>();

const selectGame = (path: string) => {
  router.push(path);
};

// 开始游戏、重来
const changeGame = () => {
  props.games.init();
};

const data = reactive({
  key: route.name,
  gameList: [
    {
      value: "华容道",
      key: "klotski",
    },
    {
      value: "数独",
      key: "sudoku",
    },
  ],
});

const { key, gameList } = toRefs(data);
</script>
<style lang="scss" scoped>
.line {
  display: flex;
  align-items: center;
  justify-content: center;
  & + .line {
    margin-top: 20px;
  }
  .el-select {
    flex: 1;
  }
}
</style>
