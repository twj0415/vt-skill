# Tailwind CSS 规范

## 默认原则

Tailwind 项目优先遵循项目已有 class 写法、设计 token 和组件风格。不要为了炫技写难维护的 class，也不要为了整理 class 顺序扩大无关 diff。

项目已有 token 体系时优先使用；没有 token 体系时，沿用项目现有颜色和样式写法。

## Class 组织

新增代码或大幅改写时，可参考以下顺序组织 class；修改旧代码时优先保持附近代码和格式化工具结果，不因顺序问题重排大量 class。

1. 布局：`flex`、`grid`、`block`
2. 尺寸：`w-*`、`h-*`
3. 间距：`p-*`、`m-*`、`gap-*`
4. 边框和圆角
5. 背景和颜色
6. 字体和文本
7. 状态：`hover:`、`focus:`、`disabled:`
8. 响应式：`sm:`、`md:`、`lg:`、`xl:`

## 颜色与主题

- 项目已有语义 token、CSS variables 或设计系统时，优先使用。
- 项目本身使用 `bg-white`、`text-slate-*`、`border-gray-*` 等 Tailwind 颜色时，继续沿用现有风格。
- 不临时发明一套新的颜色体系。
- 新增或修改可见颜色、背景、边框、阴影、悬浮态、选中态、禁用态时，按项目是否支持 light / dark 决定是否同时处理。
- 同一类视觉语义优先复用项目已有变量或 class，不在多个文件零散硬写近似颜色。

## Tailwind 负责范围

Tailwind 优先负责：

- display
- flex / grid
- gap / padding / margin
- width / height / min / max
- overflow
- position / inset / z-index
- 字体尺寸、字重
- 响应式

根主题变量、亮暗主题切换、复杂渐变、`color-mix(...)`、伪元素、动画 keyframes、基础组件皮肤继续按项目已有 CSS / 组件内部方式处理。

## Arbitrary Value

避免滥用：

```html
<div class="mt-[13px] text-[15px]">
```

只有设计稿确实需要、项目没有对应 token 或工具类时才使用 arbitrary value。

## 复杂样式

当 class 过长、重复出现或难以维护时，先考虑局部整理。只有重复明显、语义稳定或影响阅读时，再考虑：

- 抽组件。
- 抽常量。
- 使用项目已有封装。
- 使用 CSS / SCSS 局部样式，但要符合项目风格。

## 响应式

- 按项目实际支持的端和断点处理。
- 不只关注默认尺寸。
- 表格、弹窗、卡片、导航在项目目标窄屏场景下要可用。

## 可访问性状态

交互组件按实际交互考虑：

- hover
- focus
- active
- disabled
- loading
- error
- selected
