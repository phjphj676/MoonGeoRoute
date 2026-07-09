///|
/// Checks if a coordinate point is inside a closed polygon boundary using the Ray-Casting algorithm.
pub fn point_in_polygon(point : @coord.Coord, polygon_ring : Array[@coord.Coord]) -> Bool {
  let n = polygon_ring.length()
  if n < 3 {
    return false
  }
  let mut inside = false
  let mut j = n - 1
  for i in 0..<n {
    let vi = polygon_ring[i]
    let vj = polygon_ring[j]
    let lat_between = (vi.lat > point.lat) != (vj.lat > point.lat)
    if lat_between {
      let intersect_lon = (vj.lon - vi.lon) * (point.lat - vi.lat) / (vj.lat - vi.lat) + vi.lon
      if point.lon < intersect_lon {
        inside = !inside
      }
    }
    j = i
  }
  inside
}

///|
/// Computes the intersection coordinate of two line segments (p1-p2 and q1-q2), or returns `None` if parallel/disjoint.
pub fn segment_intersection(
  p1 : @coord.Coord,
  p2 : @coord.Coord,
  q1 : @coord.Coord,
  q2 : @coord.Coord
) -> @coord.Coord? {
  let x1 = p1.lon
  let y1 = p1.lat
  let x2 = p2.lon
  let y2 = p2.lat
  let x3 = q1.lon
  let y3 = q1.lat
  let x4 = q2.lon
  let y4 = q2.lat

  let denom = (y4 - y3) * (x2 - x1) - (x4 - x3) * (y2 - y1)
  if Double::abs(denom) < 1.0e-12 {
    return None
  }

  let ua = ((x4 - x3) * (y1 - y3) - (y4 - y3) * (x1 - x3)) / denom
  let ub = ((x2 - x1) * (y1 - y3) - (y2 - y1) * (x1 - x3)) / denom

  if ua >= 0.0 && ua <= 1.0 && ub >= 0.0 && ub <= 1.0 {
    let intersect_lon = x1 + ua * (x2 - x1)
    let intersect_lat = y1 + ua * (y2 - y1)
    Some(@coord.Coord::raw(intersect_lat, intersect_lon))
  } else {
    None
  }
}

///|
/// Computes approximate perpendicular distance from point `p` to line segment `a-b` in meters.
pub fn point_to_segment_distance_meters(p : @coord.Coord, a : @coord.Coord, b : @coord.Coord) -> Double {
  let dx = b.lon - a.lon
  let dy = b.lat - a.lat
  let len_sq = dx * dx + dy * dy
  if len_sq < 1.0e-14 {
    return haversine_distance(p, a)
  }
  let mut t = ((p.lon - a.lon) * dx + (p.lat - a.lat) * dy) / len_sq
  if t < 0.0 {
    t = 0.0
  } else if t > 1.0 {
    t = 1.0
  }
  let proj_lon = a.lon + t * dx
  let proj_lat = a.lat + t * dy
  haversine_distance(p, @coord.Coord::raw(proj_lat, proj_lon))
}

///|
/// Simplifies a LineString (trajectory) using the Douglas-Peucker algorithm given a distance tolerance in meters.
pub fn simplify_linestring(path : Array[@coord.Coord], tolerance_meters : Double) -> Array[@coord.Coord] {
  if path.length() <= 2 {
    return path.copy()
  }
  let mut max_dist = 0.0
  let mut max_index = 0
  let first = path[0]
  let last = path[path.length() - 1]

  for i in 1..<(path.length() - 1) {
    let dist = point_to_segment_distance_meters(path[i], first, last)
    if dist > max_dist {
      max_dist = dist
      max_index = i
    }
  }

  if max_dist > tolerance_meters {
    let left_slice = path[:max_index + 1].to_owned()
    let right_slice = path[max_index:].to_owned()
    let left_simplified = simplify_linestring(left_slice, tolerance_meters)
    let right_simplified = simplify_linestring(right_slice, tolerance_meters)
    
    let result = left_simplified.copy()
    for i in 1..<right_simplified.length() {
      result.push(right_simplified[i])
    }
    result
  } else {
    [first, last]
  }
}
