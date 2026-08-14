# 变更记录

## 2026-08-14

- Added Web Mercator projection, slippy-map tile conversion, and projected bounding boxes.
- Added polyline metrics, interpolation/sampling, polygon area/centroid, circle rings, and closest-point diagnostics.
- Added recursive GeoJSON validation reports for coordinate ranges, line lengths, polygon closure, and nested geometries.
- Added spatial radius, ordered nearest-match, density, and regular-grid analysis APIs.
- Added road-network counts, edge checks, breadth-first reachability, import audit statistics, and route limit checks.
- Added a global-city GeoJSON fixture and boundary-focused regression tests; the release candidate now contains 41 MoonBit source files and 46 passing tests.

## 2026-08-11

- 增加非法坐标、空输入、边界裁剪、不可达路由和畸形 GeoJSON 等边界测试，测试总数提升到 29 个。
- 增加五城市 WGS84 GeoJSON 基准夹具、基准复现说明和 README 使用边界说明。
- 修正 GitHub Actions 的 MoonBit 安装方式，避免引用不存在的 setup action。
- 清理 GitLink remote 中的明文凭据；发布前需重新确认 Mooncakes 账号与模块命名空间归属。
- 发布版本提升至 `0.1.1`，避免覆盖已存在的 `0.1.0`。
- 新增路由指标汇总与路径连续性审计，发布版本提升至 `0.1.2`。

## 2026-07-14

- 将 GitHub Actions 改为官方 MoonBit `test.yml` 风格，并补充 `publish.yml`。
- 新增 `FeatureCollection` 统计与包围盒能力。
- 增补 GeoJSON 测试，扩大源码与测试覆盖范围。
- 同步 README、合规说明和 Mooncakes 发布说明。

## 2026-07-09

- 统一项目名称、项目标识、作者信息和仓库链接。
- 修正 `moon.mod`、README、申报材料中的旧引用。
- 补充源代码来源说明、申报材料和提交说明。
- 验证 `moon check` 与 `moon test` 通过。
