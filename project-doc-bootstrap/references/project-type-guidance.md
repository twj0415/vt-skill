# 项目类型分支指引

当项目类型不同，不要复制一整套完全不同的方法论。保留同一套文档骨架，只调整内容重点。

## Web 项目

重点补充：

- 页面与路由结构
- 接口边界
- 状态管理
- 构建与部署

建议追加：

```text
doc/pages/
doc/contracts/
```

## uniapp 项目

重点补充：

- 端差异
- 页面栈和分包
- 登录、权限、支付、分享
- 小程序与 App 差异

建议追加：

```text
doc/platforms.md
doc/pages/
```

## 桌面程序

重点补充：

- 前后端边界
- 本地文件、路径、安全
- 数据目录
- 打包、升级、日志、诊断

建议追加：

```text
doc/runtime.md
doc/storage.md
doc/security.md
```

## Fullstack 项目

重点补充：

- 前后端职责分层
- DTO 和接口契约
- 数据库 schema
- 发布链路

建议追加：

```text
doc/contracts/
doc/backend/
doc/frontend/
```

## 多应用或多端项目

采用“总文档 + 分端说明”：

```text
doc/README.md
doc/apps/web.md
doc/apps/admin.md
doc/apps/desktop.md
```

规则：

1. 总文档只写整体目标、边界和协作关系。
2. 每个端单独写职责和限制。
3. 当前焦点仍只在 `plan/CURRENT.md` 维护一份。
