# uni-app 规范

## 默认原则

uni-app 项目不是普通 Web 项目。修改代码时必须考虑 H5、小程序、App 多端差异。

## 项目识别

优先检查：

- `pages.json`
- `manifest.json`
- `uni.scss`
- `main.js` / `main.ts`
- `@dcloudio/*` 依赖
- `#ifdef` / `#ifndef` 条件编译

## API 使用

优先使用 uni-app API：

```js
uni.request()
uni.navigateTo()
uni.redirectTo()
uni.showToast()
uni.showModal()
uni.getStorageSync()
uni.setStorageSync()
```

不要在多端代码里直接使用未保护的：

```js
window
document
localStorage
sessionStorage
```

如必须使用，使用平台判断或条件编译保护。

## 条件编译

根据平台差异使用：

```js
// #ifdef H5
// H5 only
// #endif

// #ifdef MP-WEIXIN
// WeChat Mini Program only
// #endif
```

规则：

- 条件编译只包住真正有平台差异的代码。
- 不要把整个业务流程拆得过于碎片化。
- 条件编译后仍要保证各平台逻辑完整。

## 样式

- 注意 `rpx` 和 `px` 的使用场景。
- 小程序端不支持的选择器和 CSS 特性要避免。
- 不依赖浏览器专用样式能力。
- 公共样式优先复用项目已有变量和 mixin。

## 页面和路由

- 页面路径遵循 `pages.json`。
- 跳转前确认目标页面已注册。
- 页面参数要编码和校验。
- 返回、重定向、tabBar 页面跳转使用正确 API。

## 生命周期

区分 Vue 生命周期和 uni-app 页面生命周期：

- `onLoad`
- `onShow`
- `onHide`
- `onUnload`
- `onPullDownRefresh`
- `onReachBottom`

请求时机要符合页面展示逻辑，不要每次 `onShow` 都重复请求，除非业务需要。
