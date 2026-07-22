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
```

## 功能特性模块

- `coord`：坐标、边界框、几何基础类型
- `geomath`：距离、方位角、目标点推算、线段简化
- `geojson`：GeoJSON 解析、过滤、区域裁剪
- `spatial`：Geohash、网格索引、四叉树查询
- `graph`：路网建模、Dijkstra、A*、坐标吸附
- `geojson` 统计：FeatureCollection 计数、整体包围盒

## 链接

- GitHub: https://github.com/phjphj676/MoonGeoRoute
- GitLink: https://gitlink.org.cn/phjphj676/moongeoroute

## 合规

- MoonBit: 主要实现语言
- Tests: `moon test` 通过
- License: Apache-2.0
- Source: 原创实现，使用公开算法定义
