///|
test "bbox union and validity" {
  let left = BBox::new(1.0, 2.0, 3.0, 4.0)
  let right = BBox::new(0.0, 3.0, 5.0, 6.0)
  let merged = left.union(right)
  inspect(merged.is_valid(), content="true")
  inspect(merged.contains_bbox(left), content="true")
  inspect(merged.contains_bbox(right), content="true")
}

///|
test "bbox subdivision covers exact area" {
  let box = BBox::new(0.0, 0.0, 10.0, 20.0)
  let cells = box.subdivide(2, 4)
  inspect(cells.length(), content="8")
  inspect(cells[0].min_lat, content="0")
  inspect(cells[0].max_lon, content="5")
  inspect(cells[7].max_lat, content="10")
  inspect(cells[7].max_lon, content="20")
}

///|
test "bbox translation and coordinate wrapping" {
  let box = BBox::new(10.0, 170.0, 20.0, 179.0)
  let moved = box.translated(5.0, 20.0)
  inspect(moved.min_lat, content="15")
  inspect(moved.max_lon, content="180")
  let point = Coord::raw(89.0, 179.0).translated(5.0, 10.0)
  inspect(point.lat, content="90")
  inspect(point.lon, content="-171")
}
