# @spatial (空间网格索引与树状空间检索结构)

`spatial` 模块提供高性能 GIS 空间索引结构与网格编码算法，专为大范围海量地理数据的快速检索而设计：
- **Geohash 网格编码与解码**：`encode_geohash` 与 `decode_geohash`，支持 1~12 精度层级快速转换与包围盒还原；
- **自适应四叉树空间索引**：`QuadTree[T]` 泛型树状索引结构，支持指定容量阈值的自动四分切割 (`subdivide`) 与高效率包围盒检索 (`query`)；
- **均匀网格桶索引与螺旋最近邻搜索**：`GridIndex[T]` 均匀网格空间索引，提供范围检索 (`query_bbox`) 与严格的扩展环形最近邻检索 (`nearest_neighbor`)。

## 示例

```mbt check
test "spatial quick example" {
  let grid : @spatial.GridIndex[String] = @spatial.GridIndex::new(cell_size_deg=1.0)
  let bj = @coord.Coord::new(39.9042, 116.4074)
  grid.insert("bj", bj, "Beijing")
  let query_res = grid.query_bbox(@coord.BBox::new(35.0, 110.0, 45.0, 120.0))
  inspect(query_res.length(), content="1")
}
```
