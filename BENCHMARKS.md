# MoonGeoRoute 基准数据与复现说明

本文件把“真实数据验证”和“算法压力测试”分开记录，避免把小型示例误称为生产路网基准。

## 已提交的可复现夹具

`benchmarks/fixtures/cn-city-points.geojson` 包含北京、上海、广州、深圳、成都五个公开城市中心坐标，坐标系为 WGS84，经纬度顺序遵循 RFC 7946。它用于验证 GeoJSON FeatureCollection、`BBox`、`GridIndex` 和 `FeatureCollection::bbox` 的端到端行为，不代表行政区边界或道路网络。

## 真实路网数据复现

生产规模路网建议使用 OpenStreetMap 导出的 GeoJSON/OSM 数据，并在本地转换为 `RoadNetwork` 节点与边。复现实验至少记录：数据来源与下载日期、节点数、边数、坐标范围、查询起终点、算法、耗时和是否找到路径。不得把含有隐私或受限再分发条款的数据提交到本仓库。

## 推荐命令

```bash
moon check --deny-warn
moon test --deny-warn
moon run cmd/main
```

当前版本的可重复质量门槛是以上命令全部通过；性能数字应在固定硬件、固定 MoonBit 版本和明确数据规模下另行记录。

## 结果记录模板

| 数据集 | 节点/边 | 查询数 | 算法 | 成功率 | 平均耗时 | 环境 |
| --- | ---: | ---: | --- | ---: | ---: | --- |
| cn-city-points fixture | 5 / 0 | 过滤与最近邻 | BBox/GridIndex | 100% | 见本地运行记录 | MoonBit 0.10.3 |
