# 常见问题排查

## Vue2 响应式不更新

检查是否新增了对象属性或直接修改数组索引。必要时使用 `this.$set` 或整体替换对象。

## Vue3 ref/reactive 问题

检查是否忘记 `.value`，或解构 reactive 后丢失响应式。必要时使用 `toRefs`、`storeToRefs`。

## Pinia 解构后不更新

从 store 解构 state 时使用：

```ts
storeToRefs(store)
```

## Tailwind class 不生效

检查：

- 文件路径是否被 Tailwind content 扫描。
- class 是否动态拼接导致无法被扫描。
- 是否被其他样式覆盖。
- 是否需要 safelist。

## Vite 环境变量不生效

检查：

- 是否使用 `import.meta.env`。
- 客户端变量是否有 `VITE_` 前缀。
- 修改 `.env` 后是否重启 dev server。

## uni-app 平台差异

检查：

- 当前运行平台。
- 是否使用了浏览器专用 API。
- 条件编译是否正确。
- 小程序端是否支持相关 CSS 或组件能力。

## 请求重复执行

检查：

- `onMounted`、`onShow`、watch 是否重复触发。
- tab 切换是否重复加载。
- 是否缺少缓存或请求去重。

## 样式错乱

检查：

- 全局样式污染。
- scoped 是否生效。
- 组件库样式覆盖顺序。
- Tailwind class 顺序和响应式断点。
