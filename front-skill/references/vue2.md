# Vue2 开发规范

## 默认写法

Vue2 项目默认遵循 Options API。除非项目已经明确接入 `@vue/composition-api` 并大量使用组合式写法，否则不要把 Vue2 组件改成 Vue3 风格。

## 组件结构

推荐顺序：

1. `name`
2. `components`
3. `props`
4. `data`
5. `computed`
6. `watch`
7. 生命周期
8. `methods`

保持同项目已有顺序优先。

## Props

- props 必须声明类型。
- 复杂对象和数组的默认值必须用函数返回。
- 不在子组件里直接修改 prop。
- 需要双向通信时使用事件或项目已有约定。

## 响应式限制

Vue2 无法自动侦测新增对象属性和部分数组变更。遇到这类问题时使用项目已有方式，例如：

```js
this.$set(obj, 'key', value)
```

或替换整个对象：

```js
this.form = {
  ...this.form,
  key: value,
}
```

## Watch

- 简单派生值优先用 computed，不要滥用 watch。
- watch 用于异步请求、同步外部状态、监听路由变化等副作用。
- 深度监听 `deep: true` 要谨慎，数据大时会影响性能。

## Methods

- 一个 method 只做一件主要事情。
- 表单校验、数据格式化、请求参数构造可以拆成小函数。
- 不要把复杂业务逻辑全部塞进点击事件处理函数。

## Vuex 兼容

Vue2 老项目常用 Vuex。不要为了新写法强行迁移 Pinia。处理状态时先检查已有 store 模块和 mutation/action 风格。

## 禁止行为

- 不在 Vue2 项目里直接使用 `defineProps`、`defineEmits`、`<script setup>`。
- 不在未接入 Composition API 插件的项目中使用 Vue3 组合式 API。
- 不为小改动重写整个组件。
