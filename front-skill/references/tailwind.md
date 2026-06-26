# Tailwind CSS 规范

## 默认原则

Tailwind 项目优先遵循项目已有 class 写法、设计 token 和组件风格。不要为了炫技写难维护的 class。

Tailwind 是布局与语义 token 的消费层，不是主题定义层。颜色、边框、背景、阴影优先消费 Design Tokens / CSS variables。

## Class 组织

建议按功能组织：

1. 布局：`flex`、`grid`、`block`
2. 尺寸：`w-*`、`h-*`
3. 间距：`p-*`、`m-*`、`gap-*`
4. 边框和圆角
5. 背景和颜色
6. 字体和文本
7. 状态：`hover:`、`focus:`、`disabled:`
8. 响应式：`sm:`、`md:`、`lg:`、`xl:`

## 颜色与主题

- 颜色、边框、背景、阴影优先使用语义 token。
- 不新增 `bg-white`、`text-slate-*`、`border-gray-*`、`#fff` 这类临时色，除非项目本身就是这种风格。
- 如果 Tailwind 语义 token class 尚未配置，颜色语义优先写在 CSS variables 或组件 CSS 中，不临时造一套 Tailwind 颜色体系。
- 新增或修改可见颜色、背景、边框、阴影、悬浮态、选中态、禁用态时，同时考虑 light / dark。
- 同一类视觉语义优先复用统一变量，不在多个文件零散硬写近似颜色。

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

根主题变量、亮暗主题切换、复杂渐变、`color-mix(...)`、伪元素、动画 keyframes、基础组件皮肤继续留在 CSS / 组件内部处理。

## Arbitrary Value

避免滥用：

```html
<div class="mt-[13px] text-[15px]">
```

只有设计稿确实需要、项目没有对应 token 时才使用 arbitrary value。

## 复杂样式

当 class 过长、重复出现或难以维护时，考虑：

- 抽组件。
- 抽常量。
- 使用项目已有封装。
- 使用 CSS / SCSS 局部样式，但要符合项目风格。

## 响应式

- 移动端和桌面端布局差异要明确。
- 不只关注默认尺寸。
- 表格、弹窗、卡片、导航在窄屏下要可用。

## 可访问性状态

交互组件要考虑：

- hover
- focus
- active
- disabled
- loading
- error
- selected

