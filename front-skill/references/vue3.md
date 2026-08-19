# Vue3 开发规范

## 默认写法

Vue3 项目优先匹配当前模块已有风格。新建组件时，如果项目使用 TypeScript 且同类文件没有不同约定，可优先使用：

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
- Props 字段说明输入数据的业务含义，Emits 字段说明触发时机；字段注释放在同一行。
- 复杂组件的业务方法使用一行短中文注释。

## 响应式选择

- 基础值使用 `ref`。
- 对象状态使用 `reactive` 或多个 `ref`，按项目风格选择。
- 大对象、外部实例、无需深层响应的数据优先考虑 `shallowRef`。
- 派生值使用 `computed`。
- 副作用使用 `watch` 或 `watchEffect`，不要把副作用写进 computed。

## Composable

适合抽 composable 的场景：

- 多个组件复用同一逻辑。
- 逻辑包含稳定的状态、请求、事件监听、定时器、缓存或副作用。
- 组件文件因为业务逻辑过多变得难以阅读，抽出后主流程更清楚。

不适合抽 composable 的场景：

- 只被一个组件使用的几行简单逻辑。
- 抽出来后命名模糊、调用链更复杂。
- 抽出来后参数、配置项或回调明显变多。

## 生命周期

- DOM 相关逻辑放 `onMounted` 后。
- 事件监听、定时器、订阅必须在 `onUnmounted` 清理。
- 与响应式数据强相关的副作用优先使用 watch，并清理异步竞态。

## 模板

- 简单表达式可以留在模板中。
- 重复、过长或影响阅读的条件再抽成 computed。
- 列表渲染必须有稳定 key。
- 避免在同一元素上同时使用 `v-if` 和 `v-for`；需要过滤列表时优先使用 computed 或包裹 `template`。
- 复杂模板按顶部操作区、查询条件区、主内容区、加载状态、空状态、弹窗和抽屉等业务区域加 HTML 注释。
- 不给每个普通 `div`、Flex 容器或按钮包装层写注释。
- `@register`、`@success`、`@stale`、`@confirm`、`@detail` 等不直观事件在组件标签前说明用途。

## 禁止行为

- 不把已经难以阅读的复杂逻辑继续堆在一个组件里。
- 不为简单局部状态创建全局 store。
- 不滥用 `any`。
- 不把请求、格式化、权限判断、UI 状态全部混在模板中。
