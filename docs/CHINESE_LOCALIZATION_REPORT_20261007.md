# Compositor 简体中文开发与验证

核验日期：2026-10-07（Asia/Shanghai）。分支：`codex/simplified-chinese`。基线：`11d8d7a50992b24fd9a760a1c13b1c01b70aaf30`。

## 当前状态

英文与简体中文资源及源码接入已完成，最终 Debug 构建通过。本轮基线单元测试共 521 项：520 项通过，1 项为交接中已有的 SliderSnap 失败。中文专项测试另行运行 4 项，全部通过，不重复计入 521 项。

原生基础流程验收已通过：Mac 解锁后，已在中文应用中完成尺寸校验、新建、混合模式选择、中文文字编辑、保存、关闭后重新打开及 PNG 导出。输入法候选和专业面板布局验收仍未完成：Computer Use 在“图像”菜单中连续返回元素失效，重新绑定与重置控制会话仍未恢复；已请用户关闭菜单并切换中文输入法。此限制尚不能归因于应用本身。

## 已实现

- 同一应用支持 `en` 与 `zh-Hans`，首版跟随系统/应用语言设置；英文为开发与回退语言。
- 原生 `Localizable.xcstrings` 维护翻译；动态枚举与共享控件的标签调用 Foundation 本地化查询。
- 覆盖主菜单、工具标签、图层面板、文件操作、错误和确认提示、撤销/重做、图层/选区/滤镜/Camera Raw 等编辑面板及辅助功能文字。
- 混合模式通过 `NSMenuItem.representedObject` 识别，添加蒙版子菜单通过稳定标识识别，避免以翻译后的标题执行业务动作。
- 快捷键名称和分组只在显示时翻译；保存键、工具/控件标识、枚举原始值及拖放载荷保留原值。
- 新建默认名称按当前语言生成；已有用户名称、路径和画布文字保持原样。
- `.comp` 保存格式仍为版本 11，没有修改字段或依赖锁定文件。

## 验证结果

证据目录：`build/verification/chinese-20261007/`，绝对路径为 `/Users/drm/project/compositor-damin93381/build/verification/chinese-20261007`。表中的构建产物、结果包和 `.omo/evidence/` 记录保留在本地，不随源码上传。

| 场景 | 结果 | 证据 |
|---|---|---|
| 修改前本地化回归 | 1 通过、2 失败；分别捕捉中文资源缺失和标题反查混合模式问题 | `red.log`、`Red.xcresult` |
| 最终应用和测试目标构建 | `TEST BUILD SUCCEEDED`，退出码 0 | `build-final.log` |
| 英文常规回归 | 514 通过，0 失败、0 跳过，退出码 0 | `english-parallel.log`、`EnglishParallel.xcresult` |
| 英文真实窗口测试 | 6 通过、1 失败，0 跳过，退出码 65 | `english-serial.log`、`EnglishSerial.xcresult` |
| 中文专项回归 | 4 通过，0 失败、0 跳过，退出码 0 | `chinese-core.log`、`ChineseCore.xcresult` |
| 推送前重新构建与中文专项回归 | `TEST SUCCEEDED`，4 通过，0 失败、0 跳过，退出码 0 | `before-push.log`、`BeforePush.xcresult` |
| 本地签名验证 | `codesign --verify --deep --strict`，退出码 0 | 最终应用产物 |
| 源码审查 | 修复两处残留英语后，源码变更通过审查；整体验收仍待原生 QA | `.omo/evidence/chinese-localization-code-review.md` |
| 翻译资源检查 | JSON、翻译状态、参数类型/位置、术语与运行时标签覆盖检查通过 | `.omo/evidence/localization-catalog/validate_catalog.py` |
| 原生基础流程 | 中文新建、尺寸校验、混合模式、文字、保存重开与 PNG 导出通过 | `native/中文验收项目.comp`、`native/中文验收项目.png`、`.omo/evidence/chinese-localization-native-qa.md` |
| 原生专业面板与输入法 | 待恢复界面控制后继续 | Computer Use 元素失效及截图不可用响应 |

4 项专项检查分别验证实际打包的中文资源、中文标题的混合模式选择、原有编码/快捷键键值，以及真实中文文字/图层名/文件名的保存、重新打开与 PNG 导出。随后原生界面已目视确认重开后的“中文版测试”和“图层与蒙版”两行字形正常；输入法候选行为仍未验证。

英文测试使用 `-testLanguage en -testRegion US`；中文专项使用 `-testLanguage zh-Hans -testRegion CN`。参数化测试在设备统计中可显示更多运行次数；本表采用 `totalTestCount` / `passedTests` / `failedTests`。

资源目录包含 1,169 个中文条目；检查覆盖 762 个直接源码提取键与 663 个运行时 UI 标签（两组可重叠）。详见 `.omo/evidence/localization-catalog/final-validation.json`。校验脚本不把由目录自动生成的符号计为独立源码证据。

## 保留的问题与边界

- 唯一失败仍为 `SliderSnapTests/clickingTheTrackSnapsBeforeNativeTrackingBegins()`：预期约 0.94，实际 1.0；未修改实现或断言。
- 构建仍有原有的 `GroupTests.swift:161` 未使用变量、App Intents 元数据提取跳过警告；窗口测试记录 QoS 警告。本地化 helper 新增的 actor 隔离警告已在最终构建消除。
- 未执行现有 `CompositorUITests`：当前 scheme 未包含该目标，且其中旧用例仍引用已不存在的欢迎按钮等标识。本轮没有删除、放宽或改写这些旧断言。
- 未执行 Release 构建、发行签名、公证或发行发布。工作区中的旧交接文档和验证记录保留。
- 推送前测试日志另记录 macOS `com.apple.linkd.autoShortcut` 服务连接警告；4 项测试均通过，没有将该系统服务问题计为应用修复。
- 更新配置仍指向原作者 Sparkle feed。独立 fork 正式分发前必须确定应用标识、更新源与签名策略，避免将上游发行版安装到本地中文版上。

## 使用本地构建

应用：`/Users/drm/project/compositor-damin93381/DerivedData/Build/Products/Debug/Compositor.app`。

正常启动跟随系统/应用语言；以下命令仅对新启动的进程指定简体中文，不写入系统语言偏好：

```bash
open -n /Users/drm/project/compositor-damin93381/DerivedData/Build/Products/Debug/Compositor.app --args -AppleLanguages '(zh-Hans)' -AppleLocale zh_CN
```

也可使用 macOS「系统设置 → 通用 → 语言与地区 → 应用程序」为 Compositor 选择简体中文（[Apple 文档](https://support.apple.com/en-gb/guide/mac-help/-mh26684/mac)）。

## Fork 与后续验收

本地 LICENSE 为 MIT：保留 `Copyright (c) 2026 Wonder Assembly LLC` 和许可正文即可修改、分发。2026-10-07 按用户明确要求，已在其 GitHub 账号下创建 [damin93381/Compositor](https://github.com/damin93381/Compositor)。GitHub 查询确认 `isFork=true`、父仓库为 `robbietilton/Compositor`，当前账号有管理员权限。

本地远程已配置：`origin=https://github.com/damin93381/Compositor.git`，`upstream=https://github.com/robbietilton/Compositor.git`。`git ls-remote --heads origin main` 验证连接成功，远端 main 为 `11d8d7a50992b24fd9a760a1c13b1c01b70aaf30`。

按用户后续授权，源码、原生翻译目录与 4 项直接回归测试已提交为 [`e5bca0f`](https://github.com/damin93381/Compositor/commit/e5bca0f)（`Add Simplified Chinese localization`），并推送到 [codex/simplified-chinese](https://github.com/damin93381/Compositor/tree/codex/simplified-chinese)。该分支跟踪用户 fork 的对应远端分支；main 未合并。开发计划与本报告单独提交，原交接文档和本地诊断记录未上传。

剩余原生验收：恢复 Computer Use 控制后，验证拼音候选输入、快捷键列表和专业面板布局。基础流程已保存到独立验证目录；此次操作未修改用户原来的未保存画布。
