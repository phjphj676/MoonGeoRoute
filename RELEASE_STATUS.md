# MoonGeoRoute 发布验收状态

更新时间：2026-08-14

## 已核验状态

| 项目 | 结果 |
| --- | --- |
| 本地提交 | `16a6912` |
| GitHub `main` | 与本地提交一致 |
| GitLink `main` | 与本地提交一致 |
| GitLink `master` | 与本地提交一致 |
| MoonBit 模块 | `phjphj676/moongeoroute@0.1.3` |
| Mooncakes | 已发布，发布包复检通过 |
| 严格检查 | `moon check --deny-warn` 通过 |
| 严格测试 | `moon test --deny-warn`：46/46 通过 |
| 运行示例 | `moon run cmd/main` 正常 |
| 源码规模 | 41 个 `.mbt` 文件，4020 行 |

## 申报材料边界

正式提交的申报书位于 `C:\Users\33046\Downloads\MoonGeoRoute-申报书.md`，本文件及本次仓库维护均不修改该申报书。仓库内的 `PROPOSAL.md` 和 `submission.md` 也作为申报材料存档保留；当前发布状态以本文件、README、COMPLIANCE 和 MOONCAKES 为准。

## 基准数据边界

仓库内的中国城市点和全球城市点是可再分发的公开参考坐标，用于确定性空间查询测试；它们不冒充道路网络。生产路网基准应使用有明确许可证和来源记录的 OpenStreetMap 导出数据，并记录下载时间、区域、节点数、边数、查询点、算法和耗时。
