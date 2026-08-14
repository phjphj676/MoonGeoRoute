# 基准数据复现指南

本目录分为两类数据：

1. `fixtures/cn-city-points.geojson` 和 `fixtures/global-city-points.geojson`：仓库内置的公开城市参考点，用于确定性解析、包围盒、投影、网格密度和近邻查询。
2. 外部道路网络：不直接提交到仓库，避免误分发受限制或带有额外数据库条款的数据。

## 道路网络复现要求

使用 OpenStreetMap 数据做真实路网基准时，应在实验记录中保存：

- 数据来源 URL、下载时间和区域范围；
- ODbL/数据集许可证与署名信息；
- 节点数、边数、单向边比例和坐标范围；
- 起点、终点、算法、成功率、平均耗时和硬件环境；
- 从 GeoJSON/OSM 几何转换为 `RoadNetwork` 的脚本或转换说明。

不要把在线下载的道路数据直接混入 Apache-2.0 源码包，也不要把城市中心点 fixture 描述为生产路网。

## 可复现命令

```bash
moon check --deny-warn
moon test --deny-warn
moon run cmd/main
```

当前内置 fixture 的验证重点是数据结构与空间算法正确性；生产规模性能数字必须在固定数据集和固定环境下单独记录。
