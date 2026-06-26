# Vite 规范

## 默认原则

Vite 项目先读取 `vite.config.ts`、`vite.config.js` 或同类配置文件。不要用 webpack 思维修改 Vite 项目。

## Alias

- 使用项目已有 alias，例如 `@/`。
- 不随意新增 alias。
- 新增 alias 时同步考虑 TypeScript `paths`、测试环境和 IDE 识别。

## 环境变量

Vite 中使用：

```ts
import.meta.env
```

规则：

- 客户端可见变量通常需要 `VITE_` 前缀。
- 不把密钥写入客户端环境变量。
- 区分开发、测试、生产环境。

## 插件

- 不随意改动已有插件顺序。
- 不为小功能引入大型插件。
- 修改构建配置前先确认报错来源。

## 构建和性能

- 大包问题先分析依赖来源。
- 动态导入适合路由级、弹窗级、低频模块。
- 不盲目拆包；拆包要有明确收益。

## 常见错误

- 在 Vite 项目中使用 `process.env` 读取客户端变量。
- 把 webpack loader 配置写进 Vite。
- 修改 alias 后忘记同步 tsconfig。
- 直接在浏览器端引入 Node-only 模块。
