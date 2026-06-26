# Pinia 规范

## 使用条件

只在以下情况使用 Pinia：

- 项目已经使用 Pinia。
- 用户明确要求使用 Pinia。
- 状态确实跨多个页面或多个组件共享。
- 局部状态提升后仍然比 props/emits 更清晰。

不要为简单组件状态创建 store。

## Store 拆分

- 按业务域拆分，例如 `user`、`cart`、`permission`。
- 一个 store 不要承担多个无关业务。
- UI 临时状态优先留在组件内部。

## State / Getters / Actions

- state 存储原始业务状态。
- getters 表达派生状态。
- actions 处理异步请求、复杂业务动作和状态变更。

## 响应式使用

组件中解构 store 时优先使用：

```ts
const { userInfo } = storeToRefs(userStore)
```

直接解构 store state 可能丢失响应式。

## API 请求

请求是否放在 store 中，取决于项目已有风格：

- 如果项目 store 负责业务数据加载，则放 actions。
- 如果项目 API 层和页面层分离，则遵循现有结构。
- 不要把所有请求无脑塞进 store。

## 持久化

- 持久化 token、用户配置时注意安全和过期策略。
- 不持久化大量列表数据。
- SSR 或多端项目中注意存储 API 是否可用。
