# 真实应用工作流复现

`scenarios/real_workflow_test.mbt` 是一个离线可复现的应用场景测试，覆盖：

1. 真实城市中心参考坐标的 GeoJSON 解析与结构校验；
2. 城市服务覆盖的包围盒查询、近邻排序和密度统计；
3. 将空间点转成服务网络节点，执行 Dijkstra 路径规划；
4. 对路线执行节点数、连通性、距离限制和路径端点审计。

仓库中的 `benchmarks/fixtures/cn-city-points.geojson` 与测试内联数据保持一致，使用北京、上海、广州、深圳、成都五个真实城市中心参考点。它是确定性 GIS 测试夹具，不是道路几何，也不宣称提供生产级道路距离。

## 数据合规边界

- 本仓库只分发最小城市点夹具，不分发第三方道路网络或在线下载缓存。
- 若需要扩展城市点数据，可使用 [GeoNames](https://www.geonames.org/export/) 的 CC BY 数据，并在实验记录中保留来源和署名。
- 若需要真实道路网络，应单独使用带 ODbL/归因记录的 OpenStreetMap 导出数据，记录下载日期、区域、节点数、边数、起终点、算法、耗时和硬件；不要把该数据未经审查直接打进 Apache-2.0 源码包。
- 因此本测试验证的是“真实地理点 + 可导入路网拓扑”的完整软件工作链，生产路网性能应在具名数据集上单独复测。

## 复现命令

```bash
moon check --deny-warn --target all
moon test --deny-warn --target all
moon run cmd/main
```
