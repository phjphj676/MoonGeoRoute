# MoonGeoRoute

项目名称：MoonGeoRoute

项目标识：`moongeoroute`

项目简介：MoonGeoRoute 是一个面向 MoonBit 生态的地理路径与区域分析工具库。它以固定点网格坐标为基础，提供边界判断、路径长度统计、区域围栏校验、折线路径规划和路线预览等能力，适合做轻量 GIS、路网分析和地理数据预处理。

## 解决什么问题

- 把地理坐标、网格路由和区域约束放进同一套 MoonBit 接口
- 提供可直接复用的路线规划基础能力
- 为后续 GeoJSON 子集解析、可达性分析、区域统计留出扩展点

## 当前能力

- 坐标与边界工具
- 曼哈顿距离和路线长度统计
- 路线合法性检查
- 多候选折线路径规划
- 路线边界摘要

## 运行方式

```bash
moon run cmd/main
moon test
```

## 仓库说明

- 主要实现语言：MoonBit
- 许可证：Apache-2.0
- 贡献者：phjphj676
- 发布目标：mooncakes.io
- GitLink：[https://gitlink.org.cn/phjphj676/moongeoroute](https://gitlink.org.cn/phjphj676/moongeoroute)
- GitHub：[https://github.com/phjphj676/MoonGeoRoute](https://github.com/phjphj676/MoonGeoRoute)
