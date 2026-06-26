# 工程化与质量检查

## 优先级

1. 优先遵循当前项目已有 ESLint、Stylelint、Prettier、TypeScript、测试和构建配置。
2. 如果项目已有 `.prettierrc`、`prettier.config.*` 或 `package.json` 中的 `prettier` 字段，必须优先遵循已有格式化配置。
3. 如果项目没有 lint，不主动强行安装；只有用户要求或项目确有长期维护需要时才建议接入。
4. 修改后根据改动范围选择最小必要验证，不为小改动强制跑全量流程。

## Prettier 与格式化

已有 Prettier 配置时：

- 不覆盖 `.prettierrc`。
- 不擅自修改 `printWidth`、`tabWidth`、`semi`、`singleQuote`、`trailingComma`、`vueIndentScriptAndStyle` 等格式化规则。
- 不新增与 Prettier 冲突的 ESLint 格式规则。
- ESLint 负责代码质量和潜在错误，Prettier 负责格式化。
- 如果项目配置了较大的 `printWidth`，不要擅自按 80/100/120 字符强制换行。

 Prettier 配置倾向：

```json
{
  "printWidth": 250,
  "tabWidth": 2,
  "semi": true,
  "singleQuote": true,
  "trailingComma": "es5",
  "vueIndentScriptAndStyle": true
}
```

处理该项目时必须尊重以上格式化风格。

## ESLint

ESLint 适合约束：

- 未使用变量。
- 错误 import。
- 变量作用域问题。
- Promise 未处理。
- Vue 规则。
- TypeScript 质量规则。
- 明显 bug 或不安全写法。

ESLint 不应重复接管 Prettier 已经负责的纯格式问题。

## TypeScript 检查

TypeScript 项目优先使用项目已有 typecheck 命令。常见命令可能是：

```bash
pnpm typecheck
pnpm vue-tsc
```

没有 typecheck 脚本时，不凭空假设命令；先检查 `package.json`。

## CSS / Tailwind / Stylelint

- 传统 CSS / SCSS / Less 项目可使用 Stylelint。
- Tailwind 项目优先遵循已有 class 组织方式和 Prettier 格式化结果。
- 如果项目主要使用 Tailwind 和组件库，不必强行加入复杂 Stylelint。
- 样式质量重点是主题 token、一致性、响应式和可维护性。

## Commit

如果项目已有 commitlint，提交信息遵循项目规则。常见类型：

```text
feat
fix
refactor
style
test
docs
chore
```

不要为了小改动引入新的提交规范体系。

## 没有 Lint 时

没有 lint 不代表可以降低代码质量。必须手动检查：

- import 是否正确。
- 变量是否未使用。
- 路径是否正确。
- 类型是否明显不匹配。
- 模板中变量是否存在。
- props / emits 是否和组件调用一致。
- 用户可见状态是否完整。

如果项目会长期维护，且频繁出现格式、类型或低级错误，可以建议补充基础 ESLint / Prettier / typecheck，但不要直接强制安装。

## 修改后验证

优先运行项目已有脚本：

```bash
pnpm lint
pnpm typecheck
pnpm test
pnpm build
```

如果项目使用 npm、yarn、bun，按项目已有包管理器执行。

选择验证范围：

- 小的文案、样式微调：至少自查格式、状态、响应式影响。
- 组件逻辑修改：优先运行 lint / typecheck。
- 请求、权限、登录、多语言、主题、基础组件修改：优先运行相关测试或 build。
- 大范围重构：运行 lint、typecheck、test、build 中项目可用的组合。
