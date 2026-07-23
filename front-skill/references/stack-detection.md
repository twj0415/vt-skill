# 技术栈识别

## 目标

在修改前端代码前，先判断项目实际技术栈。不要只根据用户一句话猜测 Vue2、Vue3、TypeScript、Vite、Tailwind、Pinia 或 uni-app。

技术栈不明确、首次进入项目、或改动涉及栈差异时再检查；纯局部改动只查看与本次任务直接相关的文件。

## 按需检查

根据任务范围选择必要信息，不要每次全量扫描：

1. 读取 `package.json`，确认主要依赖和脚本。
2. 检查依赖版本：`vue`、`@vue/composition-api`、`vite`、`webpack`、`pinia`、`vuex`、`tailwindcss`、`@dcloudio/*`、`uni-app`、`typescript`。
3. 需要确认入口或框架版本时，检查 `main.js`、`main.ts`、`src/main.js`、`src/main.ts`。
4. 需要确认构建、样式或多端配置时，检查 `vite.config.*`、`vue.config.js`、`tailwind.config.*`、`tsconfig.json`、`pages.json`、`manifest.json`。
5. 修改 `.vue` 文件时，优先检查同类文件写法：Options API、Composition API、`<script setup>`、JS 或 TS。
6. 修改状态管理时，检查 `stores/`、`store/`、`pinia`、`vuex`。
7. 修改请求时，检查 `api/`、`services/`、`request.*`、`http.*`、`utils/request.*`。
8. 修改样式时，检查 Tailwind、SCSS、Less、CSS Modules、UnoCSS、组件库样式。

## 判断规则

### Vue2

出现以下特征时按 Vue2 处理：

- `package.json` 中 `vue` 主版本为 2。
- 存在 `new Vue({ render: h => h(App) })`。
- 大量组件使用 Options API：`data`、`computed`、`watch`、`methods`。
- 老项目常见 Vuex；Pinia 也可能存在，需结合 Vue 版本和入口确认。

### Vue3

出现以下特征时按 Vue3 处理：

- `package.json` 中 `vue` 主版本为 3。
- 存在 `createApp(App)`。
- 大量组件使用 `<script setup>`、`defineProps`、`defineEmits`。
- Vue Router 4 或 Pinia 可作为辅助信号，不能单独作为唯一依据。

### uni-app

出现以下特征时按 uni-app 处理：

- 根目录存在 `pages.json`、`manifest.json`。
- 依赖中存在 `@dcloudio/*`。
- 代码中大量使用 `uni.request`、`uni.navigateTo`、`uni.showToast`。
- 存在条件编译：`#ifdef`、`#ifndef`。

## 决策原则

- 技术栈不明确时先读取文件确认，不直接改。
- 项目已有风格优先于通用最佳实践。
- Vue2 与 Vue3 写法不能混用。
- JS 项目不强制转 TS。
- 非 Tailwind 项目不强行引入 Tailwind。
- 非 Pinia 项目不强行引入 Pinia。
