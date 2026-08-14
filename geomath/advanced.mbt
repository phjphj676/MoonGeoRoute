///|
/// Summary metrics for a geographic polyline.
pub(all) struct PolylineMetrics {
  point_count : Int
  segment_count : Int
  length_meters : Double
  min_lat : Double?
  min_lon : Double?
  max_lat : Double?
  max_lon : Double?
  closed : Bool
} derive(Debug, Eq)

///|
/// Computes length, extent, and closure information for a polyline.
pub fn polyline_metrics(path : Array[@coord.Coord]) -> PolylineMetrics {
  if path.is_empty() {
    return {
      point_count: 0,
      segment_count: 0,
      length_meters: 0.0,
      min_lat: None,
      min_lon: None,
      max_lat: None,
      max_lon: None,
      closed: false,
    }
  }
  let mut min_lat = path[0].lat
  let mut max_lat = path[0].lat
  let mut min_lon = path[0].lon
  let mut max_lon = path[0].lon
  let mut length = 0.0
  for i, point in path {
    if point.lat < min_lat {
      min_lat = point.lat
    }
    if point.lat > max_lat {
      max_lat = point.lat
    }
    if point.lon < min_lon {
      min_lon = point.lon
    }
    if point.lon > max_lon {
      max_lon = point.lon
    }
    if i > 0 {
      length = length + haversine_distance(path[i - 1], point)
    }
  }
  let closed = path.length() > 2 &&
    Double::abs(path[0].lat - path[path.length() - 1].lat) < 1.0e-9 &&
    Double::abs(path[0].lon - path[path.length() - 1].lon) < 1.0e-9
  {
    point_count: path.length(),
    segment_count: if path.length() > 0 {
      path.length() - 1
    } else {
      0
    },
    length_meters: length,
    min_lat: Some(min_lat),
    min_lon: Some(min_lon),
    max_lat: Some(max_lat),
    max_lon: Some(max_lon),
    closed,
  }
}

///|
/// Linearly interpolates one segment in geographic coordinates.
pub fn interpolate_segment(
  start : @coord.Coord,
  end : @coord.Coord,
  fraction : Double,
) -> @coord.Coord {
  let t = if fraction < 0.0 {
    0.0
  } else if fraction > 1.0 {
    1.0
  } else {
    fraction
  }
  @coord.Coord::raw(
    start.lat + (end.lat - start.lat) * t,
    start.lon + (end.lon - start.lon) * t,
  )
}

///|
/// Returns the coordinate at a normalized distance along a polyline.
pub fn interpolate_polyline(
  path : Array[@coord.Coord],
  fraction : Double,
) -> @coord.Coord? {
  if path.is_empty() {
    return None
  }
  if path.length() == 1 {
    return Some(path[0])
  }
  let metrics = polyline_metrics(path)
  if metrics.length_meters <= 0.0 {
    return Some(path[0])
  }
  let t = if fraction < 0.0 {
    0.0
  } else if fraction > 1.0 {
    1.0
  } else {
    fraction
  }
  let target = metrics.length_meters * t
  let mut travelled = 0.0
  for i in 0..<(path.length() - 1) {
    let segment = haversine_distance(path[i], path[i + 1])
    if target <= travelled + segment || i == path.length() - 2 {
      let local_fraction = if segment <= 0.0 {
        0.0
      } else {
        (target - travelled) / segment
      }
      return Some(interpolate_segment(path[i], path[i + 1], local_fraction))
    }
    travelled = travelled + segment
  }
  Some(path[path.length() - 1])
}

///|
/// Densifies a path so adjacent samples are no farther than the requested distance.
pub fn sample_polyline(
  path : Array[@coord.Coord],
  max_segment_meters : Double,
) -> Array[@coord.Coord] {
  if path.is_empty() {
    return []
  }
  if path.length() == 1 {
    return path.copy()
  }
  let limit = if max_segment_meters <= 0.0 { 1.0 } else { max_segment_meters }
  let result = [path[0]]
  for i in 0..<(path.length() - 1) {
    let start = path[i]
    let end = path[i + 1]
    let distance = haversine_distance(start, end)
    let pieces = if distance <= limit {
      1
    } else {
      (distance / limit).ceil().to_int()
    }
    for part in 1..<=pieces {
      result.push(
        interpolate_segment(start, end, part.to_double() / pieces.to_double()),
      )
    }
  }
  result
}

///|
/// Approximate signed area of a longitude/latitude ring in square meters.
pub fn polygon_signed_area_m2(ring : Array[@coord.Coord]) -> Double {
  if ring.length() < 3 {
    return 0.0
  }
  let mut mean_lat = 0.0
  for point in ring {
    mean_lat = mean_lat + point.lat
  }
  mean_lat = mean_lat / ring.length().to_double()
  let scale = 6371008.8 * 3.14159265358979323846 / 180.0
  let x_scale = scale * @math.cos(mean_lat * 3.14159265358979323846 / 180.0)
  let mut area = 0.0
  for i in 0..<ring.length() {
    let next = if i + 1 == ring.length() { 0 } else { i + 1 }
    let x1 = ring[i].lon * x_scale
    let y1 = ring[i].lat * scale
    let x2 = ring[next].lon * x_scale
    let y2 = ring[next].lat * scale
    area = area + x1 * y2 - x2 * y1
  }
  area / 2.0
}

///|
/// Returns the absolute area of a polygon ring in square meters.
pub fn polygon_area_m2(ring : Array[@coord.Coord]) -> Double {
  Double::abs(polygon_signed_area_m2(ring))
}

///|
/// Computes an approximate centroid of a polygon ring.
pub fn polygon_centroid(ring : Array[@coord.Coord]) -> @coord.Coord? {
  if ring.length() < 3 {
    return None
  }
  let mut cross_sum = 0.0
  let mut lat_sum = 0.0
  let mut lon_sum = 0.0
  for i in 0..<ring.length() {
    let next = if i + 1 == ring.length() { 0 } else { i + 1 }
    let cross = ring[i].lon * ring[next].lat - ring[next].lon * ring[i].lat
    cross_sum = cross_sum + cross
    lon_sum = lon_sum + (ring[i].lon + ring[next].lon) * cross
    lat_sum = lat_sum + (ring[i].lat + ring[next].lat) * cross
  }
  if Double::abs(cross_sum) < 1.0e-12 {
    return None
  }
  Some(
    @coord.Coord::raw(lat_sum / (3.0 * cross_sum), lon_sum / (3.0 * cross_sum)),
  )
}

///|
/// Creates a closed approximate geodesic circle around a coordinate.
pub fn circle_ring(
  center : @coord.Coord,
  radius_meters : Double,
  vertices : Int,
) -> Array[@coord.Coord] {
  let count = if vertices < 3 {
    3
  } else if vertices > 720 {
    720
  } else {
    vertices
  }
  let radius = if radius_meters < 0.0 { 0.0 } else { radius_meters }
  let result = []
  for i in 0..<count {
    let bearing = i.to_double() * 360.0 / count.to_double()
    result.push(destination_point(center, radius, bearing))
  }
  result.push(result[0])
  result
}

///|
/// Returns the closest sampled point on a polyline and its distance.
pub(all) struct ClosestPoint {
  coordinate : @coord.Coord
  segment_index : Int
  segment_fraction : Double
  distance_meters : Double
} derive(Debug, Eq)

///|
pub fn closest_point_on_polyline(
  point : @coord.Coord,
  path : Array[@coord.Coord],
) -> ClosestPoint? {
  if path.is_empty() {
    return None
  }
  if path.length() == 1 {
    return Some({
      coordinate: path[0],
      segment_index: 0,
      segment_fraction: 0.0,
      distance_meters: haversine_distance(point, path[0]),
    })
  }
  let mut best : ClosestPoint? = None
  for i in 0..<(path.length() - 1) {
    let a = path[i]
    let b = path[i + 1]
    let dx = b.lon - a.lon
    let dy = b.lat - a.lat
    let len_sq = dx * dx + dy * dy
    let mut fraction = if len_sq <= 1.0e-20 {
      0.0
    } else {
      ((point.lon - a.lon) * dx + (point.lat - a.lat) * dy) / len_sq
    }
    if fraction < 0.0 {
      fraction = 0.0
    }
    if fraction > 1.0 {
      fraction = 1.0
    }
    let candidate = interpolate_segment(a, b, fraction)
    let distance = haversine_distance(point, candidate)
    match best {
      Some(current) =>
        if distance < current.distance_meters {
          best = Some({
            coordinate: candidate,
            segment_index: i,
            segment_fraction: fraction,
            distance_meters: distance,
          })
        }
      None =>
        best = Some({
          coordinate: candidate,
          segment_index: i,
          segment_fraction: fraction,
          distance_meters: distance,
        })
    }
  }
  best
}
