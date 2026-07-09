# MoonGeoRoute 参赛申报书

**项目名称**：MoonGeoRoute  
**项目标识**：`moongeoroute`  
**作者**：`phjphj676`

MoonGeoRoute 是一个面向 MoonBit 生态的地理路径与区域分析工具库，聚焦 `GIS + 图算法 + 空间数据处理` 的交叉方向。项目把坐标、边界框、GeoJSON 子集、空间索引和路线规划放到同一套接口里，目标是让地理数据预处理、空间查询和路线分析可以在 MoonBit 中形成完整工作流。

## 选题说明

地理数据处理在真实场景里通常同时涉及坐标系、空间几何、索引结构和路网搜索，单点算法很难直接落地。MoonGeoRoute 选择的是一个成熟但仍有扩展空间的方向，既能体现 MoonBit 在基础库、数据结构和算法实现上的能力，也方便后续继续加入等时圈、区域统计、路径导出和可达性分析等功能。

## 已完成内容

1. 完成 `coord`、`geomath`、`geojson`、`spatial`、`graph` 五个子模块的基础结构。
2. 提供距离计算、方位角、目标点推算、GeoJSON 过滤、Geohash、四叉树、Dijkstra、A* 等核心能力。
3. 补充 README、许可证、CI 配置和示例说明，保证仓库结构清晰可审查。
4. 保留可继续扩展的接口，后续可以继续做区域分析、路网分析和结果导出。
5. 4 月 29 日之后的新增工作会继续围绕可验证的文档、测试和发布准备展开，避免把旧工作量重复计入本次成果。

## 原创性说明

本项目由创作者本人独立完成，源码、文档和提交记录均围绕 MoonGeoRoute 主题整理，不引入其他协作者。项目以 MoonBit 原生实现为主，避免第三方移植代码堆叠，便于审查和后续维护。

## 赛项对齐

- 公开仓库：已满足
- MoonBit 为主要实现语言：已满足
- README / CI / 测试：已满足
- 源码来源：已说明
- Mooncakes 发布：已准备发布信息，待账号侧完成正式发布

## 仓库链接

- GitHub：<https://github.com/phjphj676/MoonGeoRoute>
- GitLink：<https://gitlink.org.cn/phjphj676/moongeoroute>
