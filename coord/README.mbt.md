# @coord (WGS84 坐标与空间几何模型)

`coord` 包提供了基础的大地坐标 `Coord`（经纬度度数表示与弧度转换）、地理边界框 `BBox`（包围盒判断、交叉与扩展）以及对齐 OGC GeoJSON 规范的核心空间几何类型定义 `Geometry`。

## 快速使用示例

```mbt check
test "coord quick usage" {
  let beijing = @coord.Coord::new(39.9042, 116.4074)
  let bbox = @coord.BBox::new(30.0, 110.0, 45.0, 120.0)
  inspect(bbox.contains(beijing), content="true")
}
```
