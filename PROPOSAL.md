# MoonGeoRoute 参赛申报书

**项目名称**：MoonGeoRoute — 地理路径与区域空间分析工具库

**GitHub 仓库**：https://github.com/bins-c-language/moon_geo_route

**作者**：bins-c-language（3304649941@qq.com）

## 摘要

MoonGeoRoute 是一个纯 MoonBit 原生实现的高性能地理信息（GIS）工具库。涵盖
WGS84 大地测量计算、OGC GeoJSON 规范解析与空间剪裁、Geohash 网格编码、
多层次空间索引（均匀网格 + 四叉树）以及带大地距离启发函数的拓扑路网规划引擎
（Dijkstra + A*），打通了从地理数据输入到复杂空间决策的完整数据链路。

## 选题方向

MoonBit 生态基础库 / 工具类（原创）

## 目标用例

- 出行导航与物流路径优化
- GeoJSON 地理数据流处理与空间过滤
- 移动端 GPS 坐标吸附与最近邻检索
- 地理围栏（Geofencing）区域监控

## 核心特性（5 个子包）

- `coord`：WGS84 Coord / BBox 包围盒 / Geometry 枚举 AST
- `geomath`：Haversine 球面距离 / Vincenty 椭球修正 / Ray-Casting 点面判断 / Douglas-Peucker 轨迹简化
- `geojson`：RFC 7946 GeoJSON 解析、序列化、bbox 与多边形空间过滤
- `spatial`：Geohash base32 编解码、GridIndex 均匀网格最近邻、QuadTree 四叉树范围检索
- `graph`：RoadNetwork 路网建模、Dijkstra 全局最短路、A* 启发式导航、坐标吸附端到端路径

## 实施计划

| 阶段 | 内容 |
| --- | --- |
| 已完成 | 全部 5 个包实现（1646 行 MoonBit 源码），20 项单元/黑盒测试全部通过 |
| 近期 | 添加等时圈分析（Isochrone）、路段限速权重支持 |
| 后续 | 发布至 mooncakes.io，完善 API 文档 |

## 是否原创

**是**，全部代码为原创 MoonBit 实现。算法（Haversine、Douglas-Peucker、
Geohash Base32、Dijkstra/A*）均基于公开领域数学公式，不涉及第三方代码移植。
