---
name: front-skill
description: 当用户要求构建、修改、重构、审查、调试或优化前端代码时使用此 Skill，尤其适用于 Vue2、Vue3、JavaScript、TypeScript、Vite、Tailwind CSS、Pinia、uni-app、.vue 文件、组件、页面、状态管理、接口请求、样式、Lint 规范和前端工程化任务。
version: "0.1.0"
metadata:
  author: VT
  language: zh-CN
  stacks:
    - Vue2
    - Vue3
    - JavaScript
    - TypeScript
    - Vite
    - Tailwind CSS
    - Pinia
    - uni-app
---

# Front Skill

## 使用原则

处理前端任务时，按顺序执行：

1. 先识别项目技术栈，再决定写法。
2. 先阅读附近文件、同类组件、路由、store、API 模块和样式文件，匹配项目现有风格。
3. 优先复用已有工具函数、请求封装、store、composable、组件和样式，不重复造轮子。
4. 保持代码简洁直接，不为了“看起来高级”过度封装。
5. 大组件、大函数、大文件要拆分，但不要把简单逻辑拆到难以追踪。
6. 业务模块较复杂时，优先使用 `index.vue` 作为入口，`components/` 放模块私有子组件；命名要语义明确，过长时结合目录上下文缩短。
7. 新增或修改用户可见文案时，优先走项目已有国际化体系，不在页面内私自硬编码。
8. 触达旧代码时增量演进，不为追求统一大面积改动无关旧代码。
9. 不主动引入新依赖，除非现有能力明显不足，且用户同意或项目已有约定支持。
10. 修改代码后优先运行项目已有的 lint、typecheck、test、build 命令验证。
11. 发现用户偏好与稳定实现冲突时，先指出风险，再给专业建议。

## 技术栈默认判断

- Vue2 项目默认使用 Options API；不要强行改成 Vue3 写法。
- Vue3 项目默认使用 Composition API；TypeScript 项目默认使用 `<script setup lang="ts">`。
- JavaScript 项目不要强行迁移 TypeScript。
- TypeScript 项目要给 props、emits、API 响应、store state、关键函数返回值补清晰类型。
- Vite 项目遵循 `vite.config.*`、alias、`import.meta.env` 和现有插件配置。
- Tailwind 项目遵循已有 class 风格，避免滥用 arbitrary value。
- Pinia 只在项目已有或用户明确要求时使用；不要把所有临时 UI 状态都放进全局 store。
- uni-app 项目优先考虑 H5、小程序、App 多端差异，不直接使用未保护的浏览器 API。

## 需要读取的参考文件

按任务相关性读取，不要一次性加载全部：

- 技术栈识别：`references/stack-detection.md`
- Vue2：`references/vue2.md`
- Vue3：`references/vue3.md`
- JS / TS：`references/typescript-javascript.md`
- Vite：`references/vite.md`
- Tailwind CSS：`references/tailwind.md`
- Pinia：`references/pinia.md`
- uni-app：`references/uniapp.md`
- 简洁代码和文件组织：`references/code-style.md`
- 组件设计：`references/component-design.md`
- 请求和数据流：`references/data-fetching.md`
- 多语言：`references/i18n.md`
- 旧代码处理：`references/legacy-code.md`
- 工程化与质量检查：`references/engineering-quality.md`
- 测试：`references/testing.md`
- UI 质量：`references/ui-quality.md`
- 常见问题排查：`references/troubleshooting.md`
- 上下文校验：`references/context-check.md`

## 输出要求

- 自然语言说明使用简体中文。
- 代码、命令、路径、URL、包名、API 名、配置键保持原样。
- 修改建议先指出问题，再给方案。
- 不确定时明确说明不确定，并说明需要检查什么文件。
