---
name: front-skill
description: 面向 Vue、Vite、TypeScript、Tailwind CSS、Pinia、uni-app 前端工程的定向实现与排查指南。仅在用户明确要求使用该 Skill，或任务确实需要这些专项参考规范时使用；普通前端修改不必自动加载。
version: "0.2.0"
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

这是一个按需加载的前端专项 Skill，不是所有前端任务的默认流程。只有在用户明确调用，或当前任务确实需要本目录的专项参考规范时才使用。

## 核心约束

- 先确认技术栈、目标文件和现有项目约定，再选择实现方式。
- 优先复用当前项目已有的请求封装、组件、store、composable、样式和国际化能力；不主动引入依赖。
- 以最小必要改动为先，避免无真实复用价值的过度封装、拆分和大范围旧代码重构。
- 遵循项目实际技术栈：Vue2 默认 Options API；Vue3、TypeScript、Vite、Tailwind、Pinia、uni-app 均匹配现有模块风格和运行目标。
- 新增或修改用户可见文案时，遵循项目现有国际化与文案方式。
- 需要验证时，按改动风险和项目已有脚本选择必要的 lint、类型检查、测试或构建，不机械执行全部命令。

## 按需读取参考资料

只读取与当前任务直接相关的文件，不要一次性加载全部参考资料：

- 栈识别：references/stack-detection.md
- Vue2 / Vue3：references/vue2.md、references/vue3.md
- JavaScript / TypeScript：references/typescript-javascript.md
- Vite、Tailwind CSS、Pinia、uni-app：references/vite.md、references/tailwind.md、references/pinia.md、references/uniapp.md
- 组件、数据流、代码风格、旧代码、国际化、测试、UI 和排查：按需读取同目录下对应的 component-design.md、data-fetching.md、code-style.md、legacy-code.md、i18n.md、testing.md、ui-quality.md、troubleshooting.md、context-check.md。
- 只有新增或修改业务 .vue / .ts 文件，或用户明确要求提升可读性、可维护性、审阅效率时，才读取 references/comments.md。先根据实际业务和接口确定注释内容，不套用示例字段。
