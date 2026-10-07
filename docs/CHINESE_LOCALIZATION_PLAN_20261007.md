# Compositor 简体中文本地化

用户于 2026-10-07 确认实施。目标：同一应用支持英文和简体中文，首版跟随系统语言，完整覆盖核心工作流与专业编辑面板。

## 设计与约束

- 沿用 Swift / SwiftUI / AppKit / C 和 Xcode 工程；不新增第三方依赖。
- 英文为开发与回退语言，中文资源使用 `zh-Hans` 和原生 String Catalog。
- 显示文字与枚举原始值、菜单动作、快捷键保存键及可访问性标识分开。
- 不改变 `.comp` 的字段、枚举编码或格式版本；保留用户已有名称和画布内容。
- 新建默认图层名称按当前语言生成，查重必须覆盖已有名称。
- 完整句子用可翻译模板，覆盖参数、错误、撤销/重做、工具提示和辅助功能文字。
- 保留已有失败测试和验证记录；不得跳过、删除或放宽断言以宣称全绿。
- 用户随后授权创建自己的 fork，并提交、推送到开发分支。正式分发前明确独立应用标识与 Sparkle 更新源策略；本轮不发行或公证。

## 执行清单

- [x] 编写并运行资源与标识回归检查，观察中文资源缺失的失败。
- [x] 增加原生本地化资源和必要的运行时字符串查找。
- [x] 本地化文档操作名称、错误、默认名称和快捷键显示，保持内部值稳定。
- [x] 本地化菜单、SwiftUI 与 AppKit 编辑面板、动态提示和辅助功能标签。
- [x] 翻译完整字符串目录，检查参数占位符和术语一致性。
- [x] 重新构建，运行英文回归、中文针对性检查及窗口测试。
- [x] 原生界面验证中文创建、编辑、保存、重新打开和 PNG 导出。
- [ ] 检查拼音输入法、快捷键列表与专业面板布局；当前 Computer Use 菜单元素失效，待恢复控制。
- [x] 保存验证报告、已知限制和接续说明。

## 验证入口

`xcodebuild build-for-testing -project Compositor.xcodeproj -scheme Compositor -destination 'platform=macOS,arch=arm64' -configuration Debug -derivedDataPath DerivedData -onlyUsePackageVersionsFromResolvedFile CODE_SIGN_IDENTITY=- CODE_SIGN_STYLE=Manual DEVELOPMENT_TEAM=`。

构建后拆分常规与真实窗口测试：常规批次排除 `CompositorTests/FloatingPanelTests` 和 `CompositorTests/SliderSnapTests`，另以 `-parallel-testing-enabled NO` 单独运行这两个目标。新增本地化回归位于 `CompositorTests/LocalizationTests.swift`。英文测试固定 `-testLanguage en -testRegion US`；中文检查固定 `-testLanguage zh-Hans -testRegion CN`。所有结果使用新的 `build/verification/` 子目录，不复用或删除旧结果包。

## 术语

Layer：图层；Mask：蒙版；Blend Mode：混合模式；Levels：色阶；Curves：曲线；Selection：选区；Opacity：不透明度；Feather：羽化；Clipping Mask：剪贴蒙版；Content-Aware Fill：内容识别填充。PNG、JPEG、sRGB、RGB、CMYK、品牌名、字体名及快捷键字符保持标准写法。

## Fork

本地 LICENSE 为 MIT，保留原版权与许可声明即可修改和分发。已按用户授权创建 `damin93381/Compositor`，本地 `origin` 指向该 fork，`upstream` 保留 `robbietilton/Compositor`。开发分支为 `codex/simplified-chinese`；最新验证与提交状态见 `CHINESE_LOCALIZATION_REPORT_20261007.md`。
