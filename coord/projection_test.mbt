///|
test "web mercator round trip and latitude clipping" {
  let beijing = Coord::new(39.9042, 116.4074)
  let projected = beijing.to_web_mercator()
  let restored = projected.to_coord()
  inspect(Double::abs(restored.lat - beijing.lat) < 0.000001, content="true")
  inspect(Double::abs(restored.lon - beijing.lon) < 0.000001, content="true")
  let polar = Coord::raw(90.0, 0.0).to_web_mercator().to_coord()
  inspect(polar.lat < 85.06, content="true")
}

///|
test "slippy map tiles are bounded and reversible" {
  let beijing = Coord::new(39.9042, 116.4074)
  let tile = beijing.to_tile(10)
  inspect(tile.z, content="10")
  inspect(tile.x >= 0 && tile.x < 1024, content="true")
  inspect(tile.y >= 0 && tile.y < 1024, content="true")
  inspect(tile.bounds().contains(beijing), content="true")
  let center = tile.center()
  inspect(Double::abs(center.lat - beijing.lat) < 1.0, content="true")
}

///|
test "projected bounding boxes preserve containment" {
  let area = BBox::new(30.0, 110.0, 40.0, 120.0)
  let projected = area.to_web_mercator()
  let point = Coord::new(35.0, 115.0).to_web_mercator()
  inspect(point.inside(projected), content="true")
  let restored = projected.from_web_mercator()
  inspect(restored.contains(Coord::new(35.0, 115.0)), content="true")
}
