# JavaScript 与 TypeScript 规范

## 总原则

先尊重项目语言选择。TypeScript 项目写 TypeScript，JavaScript 项目写 JavaScript，不为了个人偏好强制迁移。

## TypeScript 项目

优先明确以下类型：

- 组件 props
- emits 参数
- API 请求参数
- API 响应数据
- Pinia state
- 工具函数入参和返回值
- 复杂业务对象

## 类型组织

- 当前文件专用的简单类型可以写在当前文件。
- 多处复用的类型放到 `types.ts` 或项目已有类型目录。
- 避免超长内联类型。
- API 响应类型要靠近 API 模块或业务域。

## any 使用

- 不优先使用 `any`。
- 无法确认外部数据结构时，用 `unknown` 或临时窄化。
- 使用 `any` 时必须有明确理由，不要为了省事掩盖类型问题。

## JavaScript 项目

- 不强行加入 TS 类型语法。
- 可以通过清晰命名、JSDoc、数据结构注释提升可读性。
- 保持和项目已有代码风格一致。

## 代码风格

- 函数命名表达业务含义。
- 布尔变量使用 `is`、`has`、`can`、`should` 等前缀。
- 避免魔法字符串和魔法数字，必要时抽常量。
- 注释解释“为什么”，不要重复解释“怎么做”。

## 格式化与 Lint

- JS / TS 编码风格必须保持项目内一致。
- 通过项目已有 ESLint 约束明显问题。
- 通过项目已有 Prettier 或格式化工具保持格式一致。
- TypeScript 规则应与 JavaScript 基础风格一致。
- 不因为补规则就强制安装新的 lint 包；项目已有配置优先。
