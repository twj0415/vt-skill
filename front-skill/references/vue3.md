# Vue3 开发规范

## 默认写法

Vue3 项目优先使用 Composition API。TypeScript 项目优先使用：

```vue
<script setup lang="ts">
</script>
```

如果项目已有大量普通 `<script>` 或 Options API，优先匹配现有风格，不强行重构。

## Props 和 Emits

TypeScript 项目中优先使用类型声明：

```ts
const props = defineProps<{
  title: string
  visible?: boolean
}>()

const emit = defineEmits<{
  confirm: []
  change: [value: string]
}>()
```

规则：

- props 类型要清楚。
- emits 事件名和参数要明确。
- 不直接修改 props。
- 复杂默认值用 `withDefaults` 或项目已有写法。

## 响应式选择

- 基础值使用 `ref`。
- 对象状态使用 `reactive` 或多个 `ref`，按项目风格选择。
- 大对象、外部实例、无需深层响应的数据优先考虑 `shallowRef`。
- 派生值使用 `computed`。
- 副作用使用 `watch` 或 `watchEffect`，不要把副作用写进 computed。

## Composable

适合抽 composable 的场景：

- 多个组件复用同一逻辑。
- 逻辑包含状态、请求、事件监听、定时器、缓存或副作用。
- 组件文件因为业务逻辑过多变得难以阅读。

不适合抽 composable 的场景：

- 只被一个组件使用的几行简单逻辑。
- 抽出来后命名模糊、调用链更复杂。

## 生命周期

- DOM 相关逻辑放 `onMounted` 后。
- 事件监听、定时器、订阅必须在 `onUnmounted` 清理。
- 与响应式数据强相关的副作用优先使用 watch，并清理异步竞态。

## 模板

- 模板中避免写复杂表达式。
- 复杂条件抽成 computed。
- 列表渲染必须有稳定 key。
- 避免同时滥用 `v-if` 和 `v-for`。

## 禁止行为

- 不把所有逻辑都堆在一个组件里。
- 不为简单局部状态创建全局 store。
- 不滥用 `any`。
- 不把请求、格式化、权限判断、UI 状态全部混在模板中。
