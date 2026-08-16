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
- 提交历史：公开 GitHub/GitLink 默认分支的可见提交作者与项目作者一致；本地未发布备份引用不作为提交材料。
- 远程默认分支：GitHub 使用 `main`，GitLink 使用 `master`。
- MoonBit 源码规模：项目包含 34 个受 Git 跟踪的 MoonBit 源文件，共 4056 行，其中 22 个实现文件（3391 行）、12 个测试文件（665 行）。
- 来源说明：所有实现与说明均按 MoonGeoRoute 主题整理。
- CI：已提供官方风格的 `test.yml` 与 `publish.yml`。
- 格式化与接口检查：使用 `moon fmt`、`moon check --deny-warn`、`moon test --deny-warn` 和 `moon info` 组合校验。

## 当前状态

- `moon check`：通过
- `moon test`：通过
- `moon version --all`：已识别 `moonc v0.10.7`
- Mooncakes：`phjphj676/moongeoroute@0.1.5` 已完成发布，发布前校验和发布包复检均通过。

## Verified release-candidate evidence

This section supersedes earlier provisional counts and release notes in this file.

- Candidate version: `0.1.5` in `moon.mod`.
- Effective MoonBit source: 34 tracked `.mbt` files and 4056 lines, excluding build output.
- Test gate: 46 passed, 0 failed with `moon test --deny-warn`.
- Check gate: `moon check --deny-warn` passed with no warnings.
- The repository contains Apache-2.0 licensing, GitHub/GitLink links, usage instructions, CI, package metadata, benchmark fixtures, and route/GeoJSON boundary tests.
- The submitted proposal is intentionally not modified. Its project identity, author, module names, declared algorithms, and repository links correspond to this repository; new APIs are additive implementations within the declared extension scope.
- Mooncakes publication was verified by a successful `moon publish` response for the exact `0.1.5` package; the packaged copy also passed `moon check`.
