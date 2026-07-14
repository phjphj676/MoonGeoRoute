# MoonGeoRoute

MoonGeoRoute 是一个面向 MoonBit 生态的地理路径与区域分析工具库，聚焦 `GIS + 图算法 + 空间数据处理` 的交叉场景。项目把坐标、边界框、GeoJSON 子集、空间索引和路径规划放到同一套接口里，便于把地理数据预处理、空间查询和路线分析串成完整工作流。

## 项目信息

- 项目名称：MoonGeoRoute
- 项目标识：`moongeoroute`
- 作者：`phjphj676`
- GitHub：[https://github.com/phjphj676/MoonGeoRoute](https://github.com/phjphj676/MoonGeoRoute)
- GitLink：[https://gitlink.org.cn/phjphj676/moongeoroute](https://gitlink.org.cn/phjphj676/moongeoroute)

## 功能范围

- `coord`：坐标、边界框、几何基础类型
- `geomath`：距离、方位角、目标点推算、线段简化
- `geojson`：GeoJSON 解析、过滤、区域裁剪
- `spatial`：Geohash、网格索引、四叉树查询
- `graph`：路网建模、Dijkstra、A*、坐标吸附
- `geojson` 统计：FeatureCollection 计数、整体包围盒提取

## 设计目标

1. 让 MoonBit 可以直接处理常见地理数据流，而不是只做单点算法演示。
2. 保持接口轻量，便于后续扩展到 GeoJSON 导出、可达性分析、区域统计和路径服务。
3. 尽量只依赖 MoonBit 原生能力，保持可移植、可检查、可测试。

## 快速使用

```mbt
test "distance example" {
  let beijing = @coord.Coord::new(39.9042, 116.4074)
  let shanghai = @coord.Coord::new(31.2304, 121.4737)
  let dist = @geomath.haversine_distance(beijing, shanghai)
  inspect(dist > 1000000.0, content="true")
}
```

## 参赛说明

本仓库由创作者本人独立完成并持续整理，提交内容包括源码、README、许可证、申报材料和 CI 配置。后续如继续扩展，优先补充可验证的单元测试和更完整的空间分析示例。

## CI 与发布

- GitHub Actions 已补充 `test.yml` 和 `publish.yml`
- CI 按官方 MoonBit 模板执行 `moon version --all`、`moon update`、`moon check --target all --deny-warn --fmt`、`moon check --target all --deny-warn`、`moon info --target all` 和 `moon test --target all --deny-warn`
- Mooncakes 发布流程已接入 `moon publish`
