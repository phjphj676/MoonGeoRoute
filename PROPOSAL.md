# MoonGeoRoute 参赛申报书

**项目名称**：MoonGeoRoute  
**项目标识**：`moongeoroute`  
**作者**：`phjphj676`

## 项目简介

MoonGeoRoute 是一个面向 MoonBit 生态的地理路径与区域分析工具库，聚焦 `GIS + 图算法 + 空间数据处理` 的交叉方向。项目围绕坐标计算、GeoJSON 过滤、空间索引和路线规划建立统一接口，适合用于移动端定位、路线分析、地理围栏和区域统计等场景。

## 选题理由

地理数据处理通常同时涉及坐标系、空间几何、索引结构和路网搜索，单一算法很难覆盖实际应用。MoonGeoRoute 选择成熟且可扩展的方向，既能体现 MoonBit 在基础库和工程化上的能力，也能为后续继续加入可达性分析、等时圈、路径导出等功能留下空间。

## 已完成内容

1. 完成 `coord`、`geomath`、`geojson`、`spatial`、`graph` 五个子模块的基础结构。
2. 提供距离计算、方位角、目标点推算、GeoJSON 过滤、Geohash、四叉树、Dijkstra、A* 等核心能力。
3. 补充 README、许可证、CI 配置和示例说明，保证仓库结构清晰可审查。
4. 保留可继续扩展的接口，方便后续增加区域分析和路径服务能力。

## 原创性说明

本项目由创作者本人独立完成，源码、文档和提交记录均围绕 MoonGeoRoute 主题整理，不引入其他协作者。若后续继续扩展，会坚持以 MoonBit 原生实现为主，并补充可验证的测试与使用示例。

## 仓库链接

- GitHub：[https://github.com/phjphj676/MoonGeoRoute](https://github.com/phjphj676/MoonGeoRoute)
- GitLink：[https://gitlink.org.cn/phjphj676/moongeoroute](https://gitlink.org.cn/phjphj676/moongeoroute)

