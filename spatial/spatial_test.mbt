///|
test "geohash encoding and decoding accuracy" {
  let beijing = @coord.Coord::new(39.9042, 116.4074)
  let hash = encode_geohash(beijing, 6)
  inspect(hash.length(), content="6")

  match decode_geohash(hash) {
    Some((center, bbox)) => {
      let lat_ok = Double::abs(center.lat - beijing.lat) < 0.1
      let lon_ok = Double::abs(center.lon - beijing.lon) < 0.1
      inspect(lat_ok && lon_ok, content="true")
      inspect(bbox.contains(beijing), content="true")
    }
    None => fail("Expected valid geohash decode")
  }
}

///|
test "grid index bbox query and nearest neighbor search" {
  let grid : GridIndex[String] = GridIndex::new(cell_size_deg=1.0)
  let bj = @coord.Coord::new(39.9042, 116.4074)
  let sh = @coord.Coord::new(31.2304, 121.4737)
  let gz = @coord.Coord::new(23.1291, 113.2644)

  grid.insert("bj", bj, "Beijing City")
  grid.insert("sh", sh, "Shanghai City")
  grid.insert("gz", gz, "Guangzhou City")

  let north_box = @coord.BBox::new(35.0, 110.0, 45.0, 120.0)
  let query_res = grid.query_bbox(north_box)
  inspect(query_res.length(), content="1")
  inspect(query_res[0].id, content="bj")

  // Search nearest neighbor from a point near Shanghai (Suzhou: 31.29, 120.58)
  let suzhou = @coord.Coord::new(31.2989, 120.5853)
  match grid.nearest_neighbor(suzhou) {
    Some((item, dist)) => {
      inspect(item.id, content="sh")
      let dist_km = dist / 1000.0
      let is_reasonable = dist_km > 50.0 && dist_km < 100.0
      inspect(is_reasonable, content="true")
    }
    None => fail("Should find nearest neighbor in grid")
  }
}

///|
test "quadtree subdivision and range queries" {
  let bbox = @coord.BBox::new(0.0, 0.0, 100.0, 100.0)
  let qtree : QuadTree[Int] = QuadTree::new(bbox, capacity=2)

  // Insert 5 items to trigger subdivision
  for i in 1..=5 {
    let lat = i.to_double() * 10.0
    let lon = i.to_double() * 10.0
    let coord = @coord.Coord::raw(lat, lon)
    let item : SpatialItem[Int] = { id: "p" + i.to_string(), coord, data: i * 100 }
    let _ = qtree.insert(item)
    ()
  }

  // Query bottom-left quadrant [0, 0, 35, 35] -> should capture p1(10,10), p2(20,20), p3(30,30)
  let qbox = @coord.BBox::new(0.0, 0.0, 35.0, 35.0)
  let found = qtree.query(qbox)
  inspect(found.length(), content="3")
}
