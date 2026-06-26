# 简洁代码与文件组织

## 核心原则

写容易维护的代码，而不是看起来复杂的代码。

## 简洁优先

- 能直接表达就不要绕一层抽象。
- 能复用现有工具就不要重复实现。
- 能用清晰命名表达就少写解释性注释。
- 能拆成两个清楚函数就不要写一个巨大函数。

## 不过度封装

不要为了“可复用”提前抽象。复用要克制：

- 相同 UI 或逻辑稳定复用达到 3 处时，必须评估是否抽离。
- 复用达到 2 处时可以评估，但不强制抽离。
- 只有同源、稳定、边界清楚时才抽离。
- 抽出后命名必须明确。
- 抽出后调用方应更简单。
- 抽出后不能隐藏关键业务逻辑。
- 不为了追求统一大面积改动无关旧代码。

## 文件组织

- 类型放在 `types.ts` 或项目已有类型目录。
- 常量放在 `constants.ts` 或业务模块附近。
- 纯工具函数放在 `utils/` 或项目已有工具目录。
- composable 放在 `composables/` 或项目已有结构。
- API 请求放在 `api/`、`services/` 或项目已有请求层。

## 命名

命名要语义明确，但不要无限变长。目标是让人一眼知道用途，同时读起来不累。

- 组件名表达业务含义。
- 函数名用动词开头。
- 布尔值使用 `is`、`has`、`can`、`should`。
- 避免 `data`、`list`、`temp` 这类过于模糊的命名，除非上下文非常清楚。
- `handleXxx` 只用于模板事件处理层，不用于业务动作、请求动作或数据转换。
- 业务动作使用明确动词，例如 `submitUserForm`、`getOrderList`、`formatOrderRows`。
- 避免过长命名；如果名称超过 3～5 个英文单词或读起来很绕，要结合目录上下文缩短。
- 在模块目录内，不重复写模块名前缀。例如 `order/components/OrderSearchForm.vue` 可缩短为 `SearchForm.vue`。
- 在 `components/` 内使用业务角色命名，例如 `SearchForm.vue`、`DataTable.vue`、`EditDialog.vue`，不要写成 `IndexSearchFormComponent.vue`。
- 缩写只用于团队熟悉的通用词，例如 `ID`、`URL`、`API`。不要自造难懂缩写。
- 函数名过长时，优先拆分职责，而不是继续堆单词。

示例：

```text
不推荐：UserManagementPageSearchConditionFormComponent.vue
推荐：user-management/components/SearchForm.vue

不推荐：handleClickSubmitUserCreateFormButton
推荐：handleSubmitClick + submitUserForm

不推荐：getOrderListDataFromServerAndFormatToTableData
推荐：getOrders + formatOrderRows
```

## 注释

不追求零注释。注释目标是让业务代码、动态表单、流程节点、配置型文件更快被理解。

允许短中文扫读型注释，例如：

```ts
// 新增
// 删除
// 获取登录配置
```

只在以下情况写注释：

- 解释业务原因。
- 解释兼容性限制。
- 解释临时方案和后续计划。
- 解释不直观的边界条件。

不要注释代码表面行为。

## 复用和缓存

遇到多个页面重复请求、重复数据转换、重复过滤逻辑时，优先抽共享 helper、composable 或 API 层缓存。不要每个页面复制一份逻辑。
