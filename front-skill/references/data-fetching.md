# 请求与数据流规范

## 请求前检查

修改请求逻辑前先查找：

- 项目已有 request/http client。
- API 模块目录。
- 错误处理封装。
- token 注入逻辑。
- loading 管理方式。
- 缓存或去重机制。

## API 层

- 不在组件里到处直接写 `fetch` 或 `axios`。
- 请求地址和参数构造优先放 API 模块。
- 组件负责调用和展示，不负责底层请求细节。
- 业务 CRUD、Store、模块 API 的获取类动作优先使用 `getXxx`。
- 业务层不新增 `fetchXxx`；只有底层封装 Web API 或第三方库语义明确时才保留 `fetchXxx`。
- 同一模块内不要同时出现 `getUserList`、`getList`、`queryList` 三套同义命名。

## 状态处理

请求相关状态至少考虑：

- loading
- success
- error
- empty
- refreshing
- pagination / hasMore

## 避免重复请求

- 多个页面使用相同数据时，考虑共享缓存、store 或 composable。
- 路由切换、弹窗打开、tab 切换时避免无意义重复请求。
- onShow / onMounted 中请求要判断是否真的需要刷新。

## 错误处理

- 不吞掉错误。
- 用户可见错误要给明确反馈。
- 开发者需要的错误信息要保留日志或调试信息。
- 不把后端错误结构硬编码到多个组件里。

## CRUD 命名建议

模块内部优先使用：

- 查询列表：`getList`
- 分页列表：`getPage`
- 查询单条 / 详情：`getInfo` 或 `getDetail`
- 新增：`create`
- 修改：`update`
- 删除：`deleteItem` 或 `remove`，避免直接命名为 `delete`
- 批量删除：`deleteBatch`
- 状态修改：`updateState`
- 导入 / 导出：`importData` / `exportData`

底层 API 文件如果项目已有 `getXxxApi`、`createXxxApi`、`updateXxxApi`、`deleteXxxApi` 风格，继续沿用。页面、composable 或模块层可以通过 import alias 收口为短命名。

## 工具函数语义

- `resolveXxx`：根据输入推导结果，不产生副作用。
- `normalizeXxx`：把不稳定输入转成标准结构。
- `parseXxx`：解析字符串、协议、URL、配置。
- `formatXxx`：格式化展示文本。
- `createXxx`：创建对象、实例、配置。
- `applyXxx`：把结果应用到 DOM、状态、主题等，有副作用。
- `syncXxx`：同步两个状态源，通常有副作用。

## 数据转换

- API 原始数据转换成 UI 数据时，优先抽纯函数。
- 多处复用的 mapper 不重复写。
- 时间、金额、状态文案、枚举映射统一处理。
