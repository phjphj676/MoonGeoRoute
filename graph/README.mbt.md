# @graph (拓扑路网模型与路径规划引擎)

`graph` 包构建了地理空间拓扑路网并提供了高效率的路径规划算法引擎：
- **拓扑路网构建**：`RoadNetwork` 统一管理 `Node` 与 `Edge`，支持单向/双向路径添加及自动 Haversine 物理距离权重计算；
- **空间网格坐标吸附**：内置 `@spatial.GridIndex`，可通过 `nearest_node` 快速将任意真实世界经纬度坐标精确吸附匹配到路网拓扑节点；
- **核心路径算法**：提供经典 Dijkstra 最短路搜索 `dijkstra`、启发式 A* 空间导航算法 `a_star`，以及端到端坐标导航接口 `find_path_by_coords`。

## 快速使用示例

```mbt check
///|
test "graph routing example" {
  let net = @graph.RoadNetwork::new()
  let bj = @coord.Coord::new(39.9042, 116.4074)
  let sh = @coord.Coord::new(31.2304, 121.4737)
  net.add_node("BJ", bj)
  net.add_node("SH", sh)
  net.add_edge("BJ", "SH", bidirectional=true)

  match net.dijkstra("BJ", "SH") {
    Some((path, _)) => inspect(path.length(), content="2")
    None => fail("No path found")
  }
}
```
