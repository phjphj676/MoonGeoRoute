///|
test "haversine distance between Beijing and Shanghai" {
  let beijing = @coord.Coord::new(39.9042, 116.4074)
  let shanghai = @coord.Coord::new(31.2304, 121.4737)
  let dist = haversine_distance(beijing, shanghai)
  // Distance around 1068 km
  let is_approx = dist > 1060000.0 && dist < 1075000.0
  inspect(is_approx, content="true")
}

///|
test "initial bearing and destination point accuracy" {
  let start = @coord.Coord::new(0.0, 0.0)
  // Move 111.3 km North (approx 1 degree latitude)
  let dest = destination_point(start, 111195.0, 0.0)
  let lat_approx = dest.lat > 0.99 && dest.lat < 1.01
  inspect(lat_approx, content="true")

  let bearing = initial_bearing(start, dest)
  let bearing_ok = bearing >= 0.0 && bearing < 1.0
  inspect(bearing_ok, content="true")
}

///|
test "point in polygon Ray-Casting algorithm" {
  let p1 = @coord.Coord::raw(0.0, 0.0)
  let p2 = @coord.Coord::raw(0.0, 10.0)
  let p3 = @coord.Coord::raw(10.0, 10.0)
  let p4 = @coord.Coord::raw(10.0, 0.0)
  let square = [p1, p2, p3, p4]

  let inside_pt = @coord.Coord::raw(5.0, 5.0)
  let outside_pt = @coord.Coord::raw(15.0, 5.0)
  inspect(point_in_polygon(inside_pt, square), content="true")
  inspect(point_in_polygon(outside_pt, square), content="false")
}

///|
test "douglas peucker linestring simplification" {
  let p1 = @coord.Coord::raw(0.0, 0.0)
  let p2 = @coord.Coord::raw(0.0001, 5.0) // tiny deviation near straight line
  let p3 = @coord.Coord::raw(0.0, 10.0)
  let trajectory = [p1, p2, p3]

  // tolerance 100 meters (> ~11 meters deviation)
  let simplified = simplify_linestring(trajectory, 100.0)
  inspect(simplified.length(), content="2")
}
