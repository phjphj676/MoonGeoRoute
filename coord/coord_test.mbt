///|
test "coord normalization and bounds validation" {
  let c = Coord::new(39.9042, 116.4074)
  inspect(c.lat, content="39.9042")
  inspect(c.lon, content="116.4074")

  // test longitude wrap around
  let c_wrap = Coord::new(10.0, 190.0)
  inspect(c_wrap.lon, content="-170")
}

///|
test "coord rejects invalid latitude and handles exact longitude edges" {
  try Coord::new(90.0001, 0.0) catch {
    InvalidCoordError(message) =>
      inspect(message, content="Latitude out of bounds [-90, 90]: 90.0001")
  } noraise {
    _ => fail("Expected invalid latitude to raise")
  }
  inspect(Coord::new(-90.0, -180.0).lon, content="-180")
  inspect(Coord::new(90.0, 540.0).lon, content="180")
}

///|
test "bbox creation and containment" {
  let bbox = BBox::new(30.0, 110.0, 40.0, 120.0)
  let beijing = Coord::new(39.9042, 116.4074)
  let shanghai = Coord::new(31.2304, 121.4737)
  inspect(bbox.contains(beijing), content="true")
  inspect(bbox.contains(shanghai), content="false")
}

///|
test "bbox intersections and expansion" {
  let b1 = BBox::new(0.0, 0.0, 10.0, 10.0)
  let b2 = BBox::new(5.0, 5.0, 15.0, 15.0)
  let b3 = BBox::new(20.0, 20.0, 30.0, 30.0)
  inspect(b1.intersects(b2), content="true")
  inspect(b1.intersects(b3), content="false")

  let expanded = b1.expand_by_margin(1.0)
  inspect(expanded.min_lat, content="-1")
  inspect(expanded.max_lat, content="11")
}

///|
test "bbox handles empty input, reversed bounds, and world clipping" {
  match BBox::from_coords([]) {
    None => ()
    Some(_) => fail("Empty coordinate input must return None")
  }
  let reversed = BBox::new(10.0, 20.0, -10.0, -20.0)
  inspect(reversed.min_lat, content="-10")
  inspect(reversed.max_lon, content="20")
  let clipped = reversed.expand_by_margin(1000.0)
  inspect(clipped.min_lat, content="-90")
  inspect(clipped.max_lat, content="90")
}

///|
test "geometry to_coords and bbox extraction" {
  let p1 = Coord::raw(0.0, 0.0)
  let p2 = Coord::raw(10.0, 10.0)
  let line = Geometry::LineString([p1, p2])
  inspect(line.vertex_count(), content="2")
  match line.bbox() {
    Some(bb) => {
      inspect(bb.min_lat, content="0")
      inspect(bb.max_lat, content="10")
    }
    None => fail("Should return valid BBox")
  }
}
