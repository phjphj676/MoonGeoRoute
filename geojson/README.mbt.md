# @geojson (OGC GeoJSON 解析、序列化与空间剪裁)

`geojson` 包实现了对 OGC GeoJSON 规范 (`RFC 7946`) 的支持：
- **核心数据模型**：`Feature` 与 `FeatureCollection`，支持 `id`、属性表字典与各类型 `Geometry`；
- **JSON AST 转换**：与 MoonBit 官方 `@json.Json` 无缝对接，提供 `parse_geojson`、`stringify_geojson` 及类型安全解析；
- **空间子集裁剪**：提供基于包围盒的 `filter_by_bbox` 及基于多边形区域边界的 `filter_by_polygon` 空间过滤能力。

## 示例

```mbt check
test "geojson basic example" {
  let pt = @coord.Coord::new(39.9042, 116.4074)
  let feat = @geojson.Feature::new(@coord.Geometry::Point(pt), id="beijing")
  let fc = @geojson.FeatureCollection::new([feat])
  inspect(fc.features.length(), content="1")
}
```
