# OSC2026 合规清单

这个文件是给审核看的快速对照表，方便核对仓库是否满足 OSC2026 的公开提交要求。

## 基本信息

- 项目名称：MoonGeoRoute
- 项目标识：`moongeoroute`
- 作者：`phjphj676`
- 仓库类型：公开仓库
- 许可证：Apache-2.0
- 主要语言：MoonBit

## 审核重点对应

- 仓库结构：`coord/`、`geomath/`、`geojson/`、`spatial/`、`graph/` 五个子包层次清晰。
- README：根目录 README 提供项目定位、模块范围、设计目标和使用示例。
- LICENSE：根目录保留 Apache-2.0 许可证。
- 提交历史：已整理为创作者本人单一作者口径，不保留虚拟贡献者。
- 远程默认分支：GitHub 使用 `main`，GitLink 使用 `master`。
- MoonBit 源码规模：项目包含 40+ 个 MoonBit 源文件和完整测试集。
- 来源说明：所有实现与说明均按 MoonGeoRoute 主题整理。
- CI：已提供官方风格的 `test.yml` 与 `publish.yml`。
- 格式化与接口检查：使用 `moon check --fmt --deny-warn`、`moon check --deny-warn` 和 `moon info --target all` 组合校验。

## 当前状态

- `moon check`：通过
- `moon test`：通过
- `moon version --all`：已能识别 `moonc v0.10.3`
- Mooncakes：本地已登录，可直接执行发布流程
