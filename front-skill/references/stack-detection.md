# 技术栈识别

## 目标

在修改前端代码前，先判断项目实际技术栈。不要只根据用户一句话猜测 Vue2、Vue3、TypeScript、Vite、Tailwind、Pinia 或 uni-app。

## 检查顺序

1. 读取 `package.json`。
2. 检查依赖版本：`vue`、`@vue/composition-api`、`vite`、`webpack`、`pinia`、`vuex`、`tailwindcss`、`@dcloudio/*`、`uni-app`、`typescript`。
3. 检查入口文件：`main.js`、`main.ts`、`src/main.js`、`src/main.ts`。
4. 检查配置文件：`vite.config.*`、`vue.config.js`、`tailwind.config.*`、`tsconfig.json`、`pages.json`、`manifest.json`。
5. 检查同类 `.vue` 文件写法：Options API、Composition API、`<script setup>`、JS 或 TS。
6. 检查状态管理：`stores/`、`store/`、`pinia`、`vuex`。
7. 检查 API 封装：`api/`、`services/`、`request.*`、`http.*`、`utils/request.*`。
8. 检查样式体系：Tailwind、SCSS、Less、CSS Modules、UnoCSS、组件库样式。

## 判断规则

### Vue2

出现以下特征时按 Vue2 处理：

- `package.json` 中 `vue` 主版本为 2。
- 存在 `new Vue({ render: h => h(App) })`。
- 大量组件使用 Options API：`data`、`computed`、`watch`、`methods`。
- 使用 `vuex` 而不是 Pinia。

### Vue3

出现以下特征时按 Vue3 处理：

- `package.json` 中 `vue` 主版本为 3。
- 存在 `createApp(App)`。
- 大量组件使用 `<script setup>`、`defineProps`、`defineEmits`。
- 使用 Pinia 或 Vue Router 4。

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
