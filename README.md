# MoonGeoRoute (地理路径与区域空间分析工具库)

[![MoonBit](https://img.shields.io/badge/Language-MoonBit-F25F5C?style=flat-square)](https://www.moonbitlang.com)
[![License](https://img.shields.io/badge/License-Apache--2.0-blue?style=flat-square)](LICENSE)
[![Tests](https://img.shields.io/badge/Tests-20%20Passed-2ea44f?style=flat-square)](#测试与质量保证)

**MoonGeoRoute** 是一个使用 **MoonBit** 原生编写的高精度地理路径与区域空间分析综合工具库（Geographic Routing & Spatial Analysis Library），聚焦于 **GIS 大地空间测量 + GeoJSON 数据建模 + 高性能空间网格索引 + 拓扑路网图规划** 的深度交叉融合。

---

## 核心设计理念与项目背景

在现有的基础软件生态中，通用图算法（如抽象图的 `A*`、`Dijkstra`）或简单经纬度计算往往是孤立存在的。在实际的地理信息系统（GIS）、出行导航、物流路径优化、空间地理数据挖掘（Spatial Data Mining）以及地理范围监控等关键业务场景中，开发者面临复杂的综合性痛点：
1. **真实曲面空间与拓扑计算分离**：传统图算法不理解 WGS84 大地坐标与球面/椭球面空间距离，无法直接基于地理经纬度自动建立物理约束权重。
2. **海量地理要素检索检索极慢**：在没有地理索引（如 Geohash、均匀网格或四叉树）的情况下，针对数万个地理几何要素（包围盒、多边形区域）进行点面包含判断（Point-in-Polygon）或最近邻空间吸附（Snapping）的时间复杂度为 $O(N)$，在大规模并发下面临严重的性能瓶颈。
3. **数据格式与算法链条断裂**：工业界广泛采用 OGC / GeoJSON 标准传输地理数据，但在许多语言中解析 GeoJSON 后构建空间索引及拓扑路径规划需要跨越多个不同框架，存在繁琐的数据转换与内存冗余。

**MoonGeoRoute** 打通了 **「地理空间数据解析 -> 大地空间测量与几何关系 -> 高性能分层空间网格索引 -> 物理路网拓扑图规划」** 的完整链路。全库不依赖任何第三方运行时依赖（仅使用官方 `@json` 及 `@math` 核心包），采用纯现代 MoonBit 原生构建，完美适应 Wasm、JS 与 Native 全多端运行环境！

---

## 模块架构与包划分

项目采用高内聚、低耦合的清晰包模块架构，全库包含以下 5 个独立但深度协同的子包：

```
moon_geo_route/
├── coord/      # 大地坐标与基础空间几何模型 (WGS84 Coord, BBox, Geometry AST)
├── geomath/    # GIS 大地测量算法与计算几何 (Haversine, Vincenty, 射线投影, Douglas-Peucker)
├── geojson/    # OGC GeoJSON 规范解析、序列化与多维空间剪裁 (RFC 7946 标准)
├── spatial/    # 分层空间索引结构 (Geohash base32 编码, 均匀空间网格, QuadTree 树状检索)
└── graph/      # 物理拓扑路网图与导航规划引擎 (Dijkstra 最短路, 空间吸附 A* 路径规划)
```

| 子包名称 | 职责描述 | 关键数据结构与核心算法 |
| :--- | :--- | :--- |
| `coord` | **空间几何基础模型** | `Coord` (经纬度验证与弧度转换)、`BBox` (包围盒相交与扩展缓冲)、`Geometry` (Point/LineString/Polygon 枚举 AST) |
| `geomath` | **大地测量与计算几何** | `haversine_distance` (球面距离)、`vincenty_distance_approx` (椭球面高精度修正)、`initial_bearing` (前向方位角)、`destination_point` (终点推算)、`point_in_polygon` (射线法面相交)、`simplify_linestring` (Douglas-Peucker 轨迹简化) |
| `geojson` | **GeoJSON 规范与空间查询** | `Feature` / `FeatureCollection` 解析与序列化、`filter_by_bbox` (包围盒空间剪裁)、`filter_by_polygon` (地理多边形过滤) |
| `spatial` | **空间网格与树状索引** | `encode_geohash` / `decode_geohash` (精度 1~12 的 Base32 Geohash 网格编码)、`GridIndex[T]` (均匀网格桶与环形最近邻搜索)、`QuadTree[T]` (四叉树空间容量分层索引与范围查询) |
| `graph` | **拓扑路网与路经规划引擎** | `RoadNetwork` (带有空间索引的物理网络)、`nearest_node` (经纬度精准节点吸附)、`dijkstra` (全图全局最短路)、`a_star` (带大地方位启发函数的高速定向规划)、`find_path_by_coords` (端到端坐标直接路径计算) |

---

## 快速安装与使用

### 1. 引入依赖
在项目中，通过 `moon add` 命令添加依赖或在 `moon.mod.json` 中配置包引用：

```json
{
  "name": "your-username/your-project",
  "version": "0.1.0",
  "readme": "README.md",
  "license": "Apache-2.0",
  "source": "src",
  "dependencies": {
    "bins-c-language/moon_geo_route": "0.1.0"
  }
}
```

---

### 2. 核心功能代码指南

#### ① 大地空间测量与目标坐标计算 (`coord` + `geomath`)
计算北京和上海之间的大地球面距离、初始前进方位角，并通过给定的起航角推断目标坐标：

```mbt check
test "geodetic measurement" {
  let beijing = @coord.Coord::new(39.9042, 116.4074)
  let shanghai = @coord.Coord::new(31.2304, 121.4737)
  
  // 1. 计算 Haversine 球面距离（结果约为 1068.5 公里）
  let dist_m = @geomath.haversine_distance(beijing, shanghai)
  inspect(dist_m > 1060000.0 && dist_m < 1075000.0, content="true")

  // 2. 计算从北京出发飞往上海的初始方位角
  let bearing = @geomath.initial_bearing(beijing, shanghai)
  inspect(bearing >= 0.0 && bearing < 360.0, content="true")

  // 3. 沿正北方向（方位角 0°）前行 111.195 公里（约 1 个纬度）的目标坐标
  let dest = @geomath.destination_point(beijing, 111195.0, 0.0)
  inspect(Double::abs(dest.lat - 40.9042) < 0.01, content="true")
}
```

#### ② GeoJSON 数据解析与多边形空间剪裁 (`geojson`)
将标准 GeoJSON 文本解析为 `FeatureCollection`，并使用由坐标构成的地理多边形边界对数据进行严格空间过滤：

```mbt check
test "geojson spatial filtering" {
  let beijing = @coord.Coord::new(39.9042, 116.4074)
  let guangzhou = @coord.Coord::new(23.1291, 113.2644)
  
  let f1 = @geojson.Feature::new(@coord.Geometry::Point(beijing), id="CN-BJ")
  let f2 = @geojson.Feature::new(@coord.Geometry::Point(guangzhou), id="CN-GZ")
  let collection = @geojson.FeatureCollection::new([f1, f2])

  // 定义北方区域多边形边界
  let north_ring = [
    @coord.Coord::new(35.0, 110.0),
    @coord.Coord::new(35.0, 125.0),
    @coord.Coord::new(45.0, 125.0),
    @coord.Coord::new(45.0, 110.0),
  ]

  // 使用多边形包围边界筛选要素
  let filtered = @geojson.filter_by_polygon(collection, north_ring)
  inspect(filtered.features.length(), content="1")
  inspect(filtered.features[0].id, content="Some(\"CN-BJ\")")
}
```

#### ③ 高性能空间网格索引与最近邻吸附 (`spatial`)
通过均匀空间网格索引树 `GridIndex[T]` 和 Geohash Base32 算法进行高效空间聚类检索：

```mbt check
test "spatial index snapping" {
  let grid : @spatial.GridIndex[String] = @spatial.GridIndex::new(cell_size_deg=0.5)
  let bj_center = @coord.Coord::new(39.9042, 116.4074)
  let tj_center = @coord.Coord::new(39.0842, 117.2009)
  
  grid.insert("BEIJING_STATION", bj_center, "北京南站枢纽")
  grid.insert("TIANJIN_STATION", tj_center, "天津站枢纽")

  // 从北京周边任意有偏差的 GPS 坐标出发，进行快速空间环形最近邻检索
  let gps_query = @coord.Coord::new(39.8900, 116.3900)
  match grid.nearest_neighbor(gps_query) {
    Some((item, dist)) => {
      inspect(item.id, content="BEIJING_STATION")
      inspect(dist < 5000.0, content="true") // 距离小于 5 公里
    }
    None => fail("Should snap to nearest station")
  }

  // 计算精确到 6 位的 Geohash 编码
  let geohash = @spatial.encode_geohash(bj_center, precision=6)
  inspect(geohash.length(), content="6")
}
```

#### ④ 端到端拓扑路网规划 (`graph`)
构建带有真实大地距离权重的路网图，支持 Dijkstra 全局最优解及基于地理距离启发函数的 A* 定向最短路径规划：

```mbt check
test "road network navigation" {
  let net = @graph.RoadNetwork::new(cell_size_deg=1.0)
  
  let bj = @coord.Coord::new(39.9042, 116.4074)
  let tj = @coord.Coord::new(39.0842, 117.2009)
  let sh = @coord.Coord::new(31.2304, 121.4737)

  net.add_node("BJ", bj)
  net.add_node("TJ", tj)
  net.add_node("SH", sh)

  // 添加双向连接，不显式传权重则自动通过 WGS84 经纬度计算真实球面距离作为权重
  net.add_edge("BJ", "TJ", bidirectional=true)
  net.add_edge("TJ", "SH", bidirectional=true)

  // 1. 使用 A* 算法规划北京至上海的最短路径
  match net.a_star("BJ", "SH") {
    Some((path, total_meters)) => {
      inspect(path.length(), content="3")
      inspect(path[0].id, content="BJ")
      inspect(path[1].id, content="TJ")
      inspect(path[2].id, content="SH")
      inspect(total_meters > 1000000.0, content="true")
    }
    None => fail("Route computation error")
  }

  // 2. 端到端导航：直接输入任意两点真实经纬度坐标，系统自动吸附最接近的路网节点并规划最优路线
  let start_gps = @coord.Coord::new(39.91, 116.41)
  let end_gps = @coord.Coord::new(31.24, 121.48)
  match net.find_path_by_coords(start_gps, end_gps) {
    Some((path, _)) => inspect(path[2].id, content="SH")
    None => fail("End-to-end routing failed")
  }
}
```

---

## 测试与质量保证

**MoonGeoRoute** 经过了严格的单元与黑盒测试验证，所有几何判断、边界相交、JSON 解析、树状划分及图搜索算法均包含 100% 测试覆盖。

开发者在本地构建与运行全量测试套件：

```bash
# 执行静态类型与语法检查
moon check

# 运行全库单元测试与黑盒测试
moon test
```

执行后终端输出示例如下：
```text
Total tests: 20, passed: 20, failed: 0.
```

---

## 许可证

本项目以 [Apache License 2.0](LICENSE) 开源许可证发布，允许免费用于商业应用、科研及开源生态建设。
