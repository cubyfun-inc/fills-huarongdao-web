import { Action, ElMessageBox } from "element-plus";

function areArraysEqual(arr1: any[], arr2: any[]) {
  if (arr1.length !== arr2.length) {
    return false;
  }

  for (let i = 0; i < arr1.length; i++) {
    if (!isObjectEqual(arr1[i], arr2[i])) {
      return false;
    }
  }

  return true;
}

function isObjectEqual(obj1: any, obj2: any) {
  const keys1 = Object.keys(obj1);
  const keys2 = Object.keys(obj2);

  if (keys1.length !== keys2.length) {
    return false;
  }

  for (const key of keys1) {
    const val1 = obj1[key];
    const val2 = obj2[key];

    if (isObject(val1) && isObject(val2)) {
      if (!isObjectEqual(val1, val2)) {
        return false;
      }
    } else if (val1 !== val2) {
      return false;
    }
  }

  return true;
}

function isObject(obj: any) {
  return obj !== null && typeof obj === "object";
}
// 生成随机排列的数组
function shuffleArray(array: number[] | string[]) {
  for (let i = array.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [array[i], array[j]] = [array[j], array[i]];
  }
}

// 创建一个4x4的颜色数独
function createColorSudoku() {
  //   const colors = ["red", "yellow", "orange", "green"];
  const colors = ["#FF6262", "#FFA462", "#FFF262", "#81FF62"];
  shuffleArray(colors);
  const sudoku = [];
  for (let i = 0; i < 4; i++) {
    const row = [];
    for (let j = 0; j < 4; j++) {
      row.push(colors[(i + j) % 4]);
    }
    sudoku.push(row);
  }
  return sudoku;
}

function randomizeData(data: any[], numItems: number) {
  const randomIndexes: any[] = [];

  while (randomIndexes.length < numItems) {
    const index = Math.floor(Math.random() * data.length);
    if (!randomIndexes.includes(index)) {
      randomIndexes.push(index);
      data[index].color = "";
      data[index].canEdit = true;
    }
  }

  return data;
}

export interface ISudoku {
  isStart: boolean;
  activeIndex: number;
  randomData: Array<any>;
  finishData: Array<any>;
  colors: string[];
}

class Sudoku implements ISudoku {
  isStart = false;
  randomData: Array<any> = [];
  activeIndex: number = -1;
  finishData: Array<any> = [];
  colors = ["", "#FF6262", "#FFA462", "#FFF262", "#81FF62"];
  constructor() {}
  init() {
    this.randomData = this.getRandomData();
    this.isStart = !this.isStart;
    this.activeIndex = this.findFirstCanEditIndex();
    // if (this.isStart) this.finishData = this.getFinishData()
    console.log(this.activeIndex);
    console.log(this.randomData);
  }

  getRandomData(): Array<any> {
    const matrix4 = createColorSudoku();
    this.finishData = matrix4;
    const randomData: any[] = [];
    matrix4.map((v) => {
      v.map((v) => {
        const item = { color: v, canEdit: false };
        randomData.push(item);
        return item;
      });
    });

    return randomizeData(randomData, 9);
  }

  findFirstCanEditIndex(): number {
    const firstIndex = this.randomData.findIndex((v) => {
      return v.color === "" && v.canEdit === true;
    });
    return firstIndex ?? 0;
  }

  findNextEditableIndex() {
    const randomData = this.randomData;
    if (!randomData || randomData.length === 0) {
      return -1;
    }
    for (let i = 1; i <= randomData.length; i++) {
      const nextIndex = (this.activeIndex + i) % randomData.length;
      if (randomData[nextIndex].canEdit) {
        return nextIndex;
      }
    }
    return -1;
  }

  findPreEditableIndex() {
    const randomData = this.randomData;
    if (!randomData || randomData.length === 0) {
      return -1;
    }

    for (let i = 1; i <= randomData.length; i++) {
      const previousIndex =
        (this.activeIndex - i + randomData.length) % randomData.length;
      if (randomData[previousIndex].canEdit) {
        return previousIndex;
      }
    }
    return -1;
  }

  findNextColorLeft() {
    const currentColor = this.randomData[this.activeIndex].color;
    const currentIndex = this.colors.indexOf(currentColor);
    if (currentIndex === -1) {
      // 如果当前颜色不在数组中，返回默认颜色（例如第一个颜色）
      return this.colors[0];
    }

    const nextIndex =
      (currentIndex - 1 + this.colors.length) % this.colors.length;
    return this.colors[nextIndex];
  }

  //向右查询下一个颜色
  findNextColorRight() {
    const currentColor = this.randomData[this.activeIndex].color;
    const currentIndex = this.colors.indexOf(currentColor);
    if (currentIndex === -1) {
      // 如果当前颜色不在数组中，返回默认颜色（例如第一个颜色）
      return this.colors[0];
    }

    const nextIndex = (currentIndex + 1) % this.colors.length;
    return this.colors[nextIndex];
  }

  onKeydown(code: number) {
    switch (code) {
      case 37: //"按了←键！"
        this.activeIndex = this.findPreEditableIndex();
        this.finish();
        break;

      case 39: //"按了→键！"
        this.activeIndex = this.findNextEditableIndex();
        this.finish();
        break;

      case 38: //"按了↑键！"

        this.randomData[this.activeIndex].color = this.findNextColorLeft();

        this.randomData = [...this.randomData];
        this.finish();
        break;

      case 40: //"按了↓键！"
        this.randomData[this.activeIndex].color = this.findNextColorRight();
        this.randomData = [...this.randomData];
        this.finish();
        break;
    }
  }

  finish() {
    if (areArraysEqual(this.finishData, this.randomData)) {
      ElMessageBox.alert(`恭喜你，闯关成功`, "提示", {
        confirmButtonText: "OK",
        callback: (action: Action) => {
          this.isStart = false;
          this.randomData = [];
          this.activeIndex = -1;
          this.finishData = [];
        },
      });
    }
  }
}

export default new Sudoku();
