# MoonGeoRoute

MoonGeoRoute 是一个专为 MoonBit 设计的轻量级、高性能地理路由与空间计算库。它提供基础的地理坐标操作、空间网格索引、几何拓扑解析以及基于 A* 和 Dijkstra 算法的最优路径规划功能，非常适合在游戏服务器、物联网后台与物流导航系统中处理空间逻辑。

## 安装

要在您的 MoonBit 项目中使用 MoonGeoRoute，请执行：

```bash
moon add phjphj676/moongeoroute
```

## 直接复现的运行命令

要直接拉取代码并运行所有的单元测试与功能验证，请执行以下命令：

```bash
git clone https://github.com/phjphj676/MoonGeoRoute.git
cd MoonGeoRoute
moon check
moon test
moon run cmd/main
```

`moon run cmd/main` 会输出一个绕开障碍点的最短网格路线；`moon check` 和 `moon test` 覆盖库的编译、解析、空间索引与路由核心路径。

## 功能特性模块

- `coord`：坐标、边界框、几何基础类型
- `geomath`：距离、方位角、目标点推算、线段简化
- `geojson`：GeoJSON 解析、过滤、区域裁剪
- `spatial`：Geohash、网格索引、四叉树查询
- `graph`：路网建模、Dijkstra、A*、坐标吸附
- `graph` 路由审计：`route_metrics` 汇总距离、权重、节点数、包围盒并检查路径连续性
- `geojson` 统计：FeatureCollection 计数、整体包围盒
- `coord` 投影工具：Web Mercator、瓦片坐标、边界框切分与坐标平移
- `geomath` 分析工具：折线量测、等距采样、多边形面积/质心和最近点
- `geojson` 校验工具：坐标范围、线长度、闭合环和嵌套几何校验报告
- `spatial` 分析工具：半径查询、排序近邻、网格密度报告
- `graph` 网络审计：连通节点、边检查、网络统计和路线距离/权重约束
- `scenarios` 端到端场景：真实城市点覆盖分析、服务网络路由和路径审计

## 数据与边界覆盖

- `benchmarks/fixtures/cn-city-points.geojson`：北京、上海、广州、深圳和成都的 WGS84 城市中心点，用于 GeoJSON 解析、包围盒过滤和空间索引的可复现实例。
- `BENCHMARKS.md`：记录数据来源说明、规模、运行方法和结果记录格式；不把合成数据的结果冒充真实路网性能。
- `benchmarks/REAL_WORLD_WORKFLOW.md`：记录真实城市点到服务网络路由的完整可复现场景和数据合规边界。
- 边界测试覆盖非法纬度、经度归一化、空坐标集合、反向边界、世界范围裁剪、空路网/不可达路径、畸形 GeoJSON 和 MultiPolygon。

## API 使用方式

公共 API 的最小示例见各包的 `README.mbt.md`。库包导入名为 `@phjphj676/moongeoroute/...`；根包可直接用于网格路线演示，`cmd/main` 是不依赖外部服务的可运行示例。

## 链接

- GitHub: https://github.com/phjphj676/MoonGeoRoute
- GitLink: https://gitlink.org.cn/phjphj676/moongeoroute

## Current acceptance evidence (2026-08-16)

- Published release: `0.1.6`.
- Effective MoonBit source: 36 tracked `.mbt` files / 4182 lines.
- Automated tests: 47 passed with `moon test --deny-warn` across native, wasm, wasm-gc, and JS.
- Static gate: `moon check --deny-warn --target all`.
- Boundary coverage includes invalid coordinates, empty inputs, clipped latitude, malformed GeoJSON rings, disconnected graphs, radius limits, and route cost limits.
- Reproducible fixtures: `benchmarks/fixtures/cn-city-points.geojson` and `benchmarks/fixtures/global-city-points.geojson`.
- The submitted proposal is preserved at `C:\Users\33046\Downloads\MoonGeoRoute-申报书.md`; repository enhancements stay within its declared GIS, spatial-index, GeoJSON, and routing scope.

## 合规

- MoonBit: 主要实现语言
- Tests: `moon test` 通过
- License: Apache-2.0
- Source: 原创实现，使用公开算法定义
- Third-party data/code: 当前仓库不分发第三方源码；`benchmarks/fixtures` 仅包含公开城市坐标的最小测试夹具，详见 `COMPLIANCE.md`。
