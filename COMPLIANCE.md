# OSC2026 合规清单

这个文件是给评审看的快速对照表，方便核对仓库是否满足 OSC2026 的公开提交要求。

## 基本信息

- 项目名称：MoonGeoRoute
- 项目标识：`moongeoroute`
- 作者：`phjphj676`
- 仓库类型：公开仓库
- 许可证：Apache-2.0
- 主要语言：MoonBit

## 评审重点对应

- 仓库结构：`coord/`、`geomath/`、`geojson/`、`spatial/`、`graph/` 五个子包分层清晰。
- README：根目录 README 提供项目定位、模块范围、设计目标和使用示例。
- LICENSE：仓库根目录保留 Apache-2.0 许可证。
- 提交历史：保留了独立开发过程的提交记录，且 2026-04-29 之后仍有持续新增内容。
- 源码规模：MoonBit 源码、测试、接口文件和示例入口都已整理到位，便于检查和维护。
- 来源说明：所有代码和文档均按 MoonGeoRoute 主题整理，未混入来源不清的第三方闭源代码。
- CI：`.github/workflows/ci.yml` 提供 `moon check` 和 `moon test` 自动校验。

## 当前状态

- 本地检查：`moon check` 通过，`moon test` 通过。
- 申报材料：`PROPOSAL.md` 与桌面版申报书一致。
- GitHub 仓库：已同步最新内容。
- GitLink 仓库：已同步最新内容，并持续补充有效提交记录。

