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
- `geojson` 统计：FeatureCollection 计数、整体包围盒

## 数据与边界覆盖

- `benchmarks/fixtures/cn-city-points.geojson`：北京、上海、广州、深圳和成都的 WGS84 城市中心点，用于 GeoJSON 解析、包围盒过滤和空间索引的可复现实例。
- `BENCHMARKS.md`：记录数据来源说明、规模、运行方法和结果记录格式；不把合成数据的结果冒充真实路网性能。
- 边界测试覆盖非法纬度、经度归一化、空坐标集合、反向边界、世界范围裁剪、空路网/不可达路径、畸形 GeoJSON 和 MultiPolygon。

## API 使用方式

公共 API 的最小示例见各包的 `README.mbt.md`。库包导入名为 `@phjphj676/moongeoroute/...`；根包可直接用于网格路线演示，`cmd/main` 是不依赖外部服务的可运行示例。

## 链接

- GitHub: https://github.com/phjphj676/MoonGeoRoute
- GitLink: https://gitlink.org.cn/phjphj676/moongeoroute

## 合规

- MoonBit: 主要实现语言
- Tests: `moon test` 通过
- License: Apache-2.0
- Source: 原创实现，使用公开算法定义
- Third-party data/code: 当前仓库不分发第三方源码；`benchmarks/fixtures` 仅包含公开城市坐标的最小测试夹具，详见 `COMPLIANCE.md`。
