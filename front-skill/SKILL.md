---
name: front-skill
description: 此 Skill 应在用户请求“修改 Vue 组件”、“重构 .vue 页面”、“修复 Vite 构建报错”、“优化 Tailwind 样式”、“排查 Pinia 状态问题”、“处理 uni-app 多端兼容”、“审查前端代码质量”或涉及 Vue2、Vue3、JavaScript、TypeScript、Vite、Tailwind CSS、Pinia、uni-app 前端工程任务时使用。
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

处理前端任务时，按任务需要优先考虑以下事项，不要把它们当成固定流程机械执行：

1. 先确认本次任务涉及的技术栈和文件范围，再决定写法。
2. 按改动范围阅读必要文件，优先匹配当前项目、当前模块和附近代码风格。
3. 优先复用已有请求封装、组件、store、composable 和样式；复用必须降低理解成本，简单局部逻辑可以直接写。
4. 保持代码简洁直接，不为了“看起来高级”过度封装、过度拆分或过度命名。
5. 只有拆分能明显提升阅读和维护时，才拆大组件、大函数或大文件。
6. 业务模块较复杂时，优先使用 `index.vue` 作为入口；核心业务块放模块根目录，辅助组件放 `components/`；命名结合目录上下文保持短而明确。
7. 新增或修改用户可见文案时，如果项目已有国际化体系，优先接入；没有国际化体系时遵循项目现有文案方式。
8. 触达旧代码时增量演进，以最小必要改动为先，不为追求统一大面积改动无关旧代码。
9. 不主动引入新依赖，除非现有能力明显不足，且用户同意或项目已有约定支持。
10. 不机械运行检查命令；用户要求验证或改动风险较高时，才按项目已有脚本选择必要验证。
11. 发现用户偏好与稳定实现冲突时，先指出风险，再给专业建议。
12. 业务代码要便于审阅：类型用途、关键字段、业务方法、组件事件和主要模板区域使用简短中文注释，不写复述代码的说明。
13. 注释规则必须适用于不同业务模块；参考示例只说明写法，不代表当前模块必须存在对应字段、状态或流程。

## 技术栈默认判断

- Vue2 项目默认使用 Options API；不要强行改成 Vue3 写法。
- Vue3 项目优先匹配当前模块已有风格；新建 TypeScript 组件时可优先使用 `<script setup lang="ts">`。
- JavaScript 项目不要强行迁移 TypeScript。
- TypeScript 项目优先保证 props、emits、API 响应、store state 等边界类型清楚；不要给显而易见的局部变量补冗余类型。
- Vite 项目遵循 `vite.config.*`、alias、`import.meta.env` 和现有插件配置。
- Tailwind 项目遵循已有 class 风格，避免滥用 arbitrary value。
- Pinia 只在项目已有或用户明确要求时使用；不要把所有临时 UI 状态都放进全局 store。
- uni-app 项目按实际运行目标考虑 H5、小程序、App 差异，不直接使用未保护的浏览器 API。

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
- 测试：`references/testing.md`
- UI 质量：`references/ui-quality.md`
- 常见问题排查：`references/troubleshooting.md`
- 上下文校验：`references/context-check.md`
- 注释与代码审阅：`references/comments.md`

新增或修改业务 `.vue`、`.ts` 文件，或用户要求提升可读性、可维护性、审阅效率时，必须读取 `references/comments.md`。涉及 TypeScript、Vue 组件、组件拆分或请求逻辑时，还要同步读取对应参考文件，确保命名、注释和实现一致。先根据当前代码和接口文档识别业务，再选择注释内容，不得把参考示例套用到当前模块。

## 输出要求

- 自然语言说明使用简体中文。
- 代码、命令、路径、URL、包名、API 名、配置键保持原样。
- 修改建议先指出问题，再给方案。
- 不确定时明确说明不确定，并说明需要检查什么文件。
