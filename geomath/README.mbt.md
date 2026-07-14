# @geomath (GIS 大地测量与空间几何计算)

`geomath` 模块提供高精度的 GIS 大地测量与计算几何算法：
- **球面与椭球面距离计算**：`haversine_distance`（Haversine 公式）与 `vincenty_distance_approx`（WGS84 椭球面修正）；
- **方位角与目标点推导**：`initial_bearing`（正方位角计算）与 `destination_point`（给定起点、距离、方向求终点）；
- **拓扑与轨迹简化**：`point_in_polygon`（Ray-Casting 多边形包围检测）、`segment_intersection`（线段交点求解）及 `simplify_linestring`（Douglas-Peucker 轨迹简化）。

## 示例

```mbt check
///|
test "geomath example" {
  let beijing = @coord.Coord::new(39.9042, 116.4074)
  let shanghai = @coord.Coord::new(31.2304, 121.4737)
  let dist_km = @geomath.haversine_distance(beijing, shanghai) / 1000.0
  let is_reasonable = dist_km > 1000.0
  inspect(is_reasonable, content="true")
}
```
