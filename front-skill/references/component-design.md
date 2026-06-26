# 组件设计规范

## 组件职责

- 页面组件负责路由级组织、数据装配和页面状态。
- 业务组件负责独立业务块。
- 基础组件负责纯 UI 和通用交互。
- composable 负责可复用逻辑。

## 拆分原则

适合拆分组件的情况：

- 单个 `.vue` 文件过长。
- 模板结构难以阅读。
- 某块 UI 可独立复用。
- 某块业务状态和事件相对独立。

不适合拆分的情况：

- 只是几行简单 DOM。
- 拆分后 props/emits 变得复杂。
- 拆分后业务上下文更难理解。

## 目录组织

当一个页面或业务模块内容较多时，优先使用清晰的目录结构，而不是把所有文件平铺在一起。

推荐结构：

```text
feature-name/
  index.vue
  components/
    SearchForm.vue
    DataTable.vue
    EditDialog.vue
  composables/
    useFeatureQuery.ts
  constants.ts
  types.ts
```

规则：

- `index.vue` 作为当前页面或模块的入口文件，负责组合页面结构和主流程。
- `components/` 放当前模块私有子组件；跨模块复用组件放项目已有公共组件目录。
- `composables/` 放当前模块可复用逻辑；跨模块复用逻辑放公共 composables 目录。
- `constants.ts` 放当前模块常量、枚举映射、状态文案。
- `types.ts` 放当前模块类型定义。
- 简单页面不强行建完整目录，避免为了形式增加维护成本。

## 共享基础组件边界

共享基础 UI 组件必须保持纯粹：

- 通过 props 传参，通过 emit 抛事件。
- 不直接调用业务 API。
- 不直接修改全局状态。
- 不写死业务字段、权限码、页面路由。
- 不依赖具体业务 store。

业务字段映射、权限判断、接口协议适配应放在页面、模块 composable 或模块层，不放进基础组件。

## Props

- props 表达输入，不承担内部状态职责。
- props 数量过多时，考虑组件是否承担太多职责。
- 对象 props 要明确结构。

## Emits

- emits 表达事件，不传递模糊 payload。
- 事件名使用项目已有命名风格。
- 子组件不直接修改父组件状态。

## 表单组件

- 区分表单数据、校验规则、提交状态。
- loading、error、disabled 状态要明确。
- 提交前处理重复点击。

## 列表组件

- 处理 loading、empty、error、pagination 或 load more。
- 列表 key 必须稳定。
- 大列表注意性能。

## 弹窗组件

- visible/open 状态来源要清楚。
- 关闭、确认、取消事件要明确。
- 表单弹窗关闭时是否重置数据要符合业务。
