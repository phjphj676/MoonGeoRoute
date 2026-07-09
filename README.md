# MoonGeoRoute (地理路径与区域空间分析工具库)

[![MoonBit](https://img.shields.io/badge/Language-MoonBit-F25F5C?style=flat-square)](https://www.moonbitlang.com)
[![License](https://img.shields.io/badge/License-Apache--2.0-blue?style=flat-square)](LICENSE)

**MoonGeoRoute** 是一个使用 **MoonBit** 编写的高性能地理路径与区域空间分析综合工具库（Geographic Routing & Spatial Analysis Library），聚焦于 **GIS 几何处理 + 空间网格索引 + 图算法寻路 + 地理数据分析** 的深度交叉应用。

## 简介与核心特色

在纯算法领域，通用寻路库（如抽象 `A*`、`Dijkstra`）与通用数学图库已较为成熟，但在实际的地理信息系统（GIS）、出行导航、物流配送和空间数据挖掘场景中，开发者往往需要处理 WGS84 大地坐标、空间几何拓扑、GeoJSON 序列化与空间剪裁、高效空间网格索引（Geohash / 均匀空间网格）以及带有多重地理约束（实际曲面距离、限速时间、坡度惩罚、等时圈分析）的寻路与聚类。

**MoonGeoRoute** 打通了从地理数据输入到复杂空间决策的完整数据链路，不仅提供基础大地测量计算与 GeoJSON 数据解析，还融合了空间索引与高级地理路径优化引擎，具有绝佳的扩展性与工程实践价值。
