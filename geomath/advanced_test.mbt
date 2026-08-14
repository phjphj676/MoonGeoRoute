///|
test "polyline metrics and interpolation" {
  let path = [
    @coord.Coord::new(39.9042, 116.4074),
    @coord.Coord::new(39.9142, 116.4074),
    @coord.Coord::new(39.9142, 116.4174),
  ]
  let metrics = polyline_metrics(path)
  inspect(metrics.point_count, content="3")
  inspect(metrics.segment_count, content="2")
  inspect(metrics.length_meters > 1800.0, content="true")
  inspect(metrics.closed, content="false")
  match interpolate_polyline(path, 0.0) {
    Some(point) => inspect(point.lat, content="39.9042")
    None => fail("Expected start point")
  }
  match interpolate_polyline(path, 1.0) {
    Some(point) => inspect(point.lon, content="116.4174")
    None => fail("Expected end point")
  }
}

///|
test "sampling, circle area, and centroid" {
  let start = @coord.Coord::new(0.0, 0.0)
  let end = @coord.Coord::new(0.0, 1.0)
  let samples = sample_polyline([start, end], 20000.0)
  inspect(samples.length() > 5, content="true")
  let ring = circle_ring(start, 1000.0, 32)
  inspect(ring.length(), content="33")
  inspect(polygon_area_m2(ring) > 2500000.0, content="true")
  match polygon_centroid(ring) {
    Some(center) => inspect(Double::abs(center.lat) < 0.01, content="true")
    None => fail("Expected centroid")
  }
}

///|
test "closest point on polyline returns segment diagnostics" {
  let path = [@coord.Coord::new(0.0, 0.0), @coord.Coord::new(0.0, 1.0)]
  match closest_point_on_polyline(@coord.Coord::new(0.1, 0.5), path) {
    Some(result) => {
      inspect(result.segment_index, content="0")
      inspect(
        result.segment_fraction > 0.4 && result.segment_fraction < 0.6,
        content="true",
      )
      inspect(result.distance_meters > 10000.0, content="true")
    }
    None => fail("Expected closest point")
  }
}
