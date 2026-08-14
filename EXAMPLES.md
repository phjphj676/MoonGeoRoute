# MoonGeoRoute Examples

## Distance
```mbt
let beijing = @coord.Coord::new(39.9042, 116.4074)
let shanghai = @coord.Coord::new(31.2304, 121.4737)
let dist = @geomath.haversine_distance(beijing, shanghai)
```

## Bounding box
```mbt
let bbox = @coord.BBox::new(39.0, 116.0, 40.0, 117.0)
```

## Routing
```mbt
let graph = @graph.RoadNetwork::new()
graph.add_node("BJ", @coord.Coord::new(39.9042, 116.4074))
graph.add_node("SH", @coord.Coord::new(31.2304, 121.4737))
graph.add_edge("BJ", "SH", bidirectional=true)
```
