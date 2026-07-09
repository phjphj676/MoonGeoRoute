///|
let earth_radius_meters : Double = 6371008.8
let wgs84_a : Double = 6378137.0
let wgs84_f : Double = 1.0 / 298.257223563
let pi : Double = 3.14159265358979323846

///|
/// Computes the great-circle distance between two coordinates using the Haversine formula (in meters).
pub fn haversine_distance(c1 : @coord.Coord, c2 : @coord.Coord) -> Double {
  let (lat1, lon1) = c1.to_radians()
  let (lat2, lon2) = c2.to_radians()
  let dlat = lat2 - lat1
  let dlon = lon2 - lon1
  let sin_dlat = @math.sin(dlat / 2.0)
  let sin_dlon = @math.sin(dlon / 2.0)
  let a = sin_dlat * sin_dlat + @math.cos(lat1) * @math.cos(lat2) * sin_dlon * sin_dlon
  let c = 2.0 * @math.atan2(Double::sqrt(a), Double::sqrt(1.0 - a))
  earth_radius_meters * c
}

///|
/// Computes ellipsoidal distance approximation using Lambert's formula on WGS84 ellipsoid (in meters).
pub fn vincenty_distance_approx(c1 : @coord.Coord, c2 : @coord.Coord) -> Double {
  let (lat1, lon1) = c1.to_radians()
  let (lat2, lon2) = c2.to_radians()
  if Double::abs(lat1 - lat2) < 1.0e-11 && Double::abs(lon1 - lon2) < 1.0e-11 {
    return 0.0
  }
  let beta1 = @math.atan((1.0 - wgs84_f) * @math.tan(lat1))
  let beta2 = @math.atan((1.0 - wgs84_f) * @math.tan(lat2))
  let sin_beta1 = @math.sin(beta1)
  let cos_beta1 = @math.cos(beta1)
  let sin_beta2 = @math.sin(beta2)
  let cos_beta2 = @math.cos(beta2)
  let dlon = lon2 - lon1
  
  let p = @math.acos(sin_beta1 * sin_beta2 + cos_beta1 * cos_beta2 * @math.cos(dlon))
  if Double::abs(p) < 1.0e-11 {
    return 0.0
  }
  let sin_p = @math.sin(p)
  let sin_p_half = @math.sin(p / 2.0)
  let cos_p_half = @math.cos(p / 2.0)
  let x = (p - sin_p) * ((sin_beta1 + sin_beta2) * (sin_beta1 + sin_beta2)) / (4.0 * cos_p_half * cos_p_half)
  let y = (p + sin_p) * ((sin_beta1 - sin_beta2) * (sin_beta1 - sin_beta2)) / (4.0 * sin_p_half * sin_p_half)
  wgs84_a * (p - (wgs84_f / 2.0) * (x + y))
}

///|
/// Computes the initial compass bearing (forward azimuth) from `c1` to `c2` in degrees [0.0, 360.0).
pub fn initial_bearing(c1 : @coord.Coord, c2 : @coord.Coord) -> Double {
  let (lat1, lon1) = c1.to_radians()
  let (lat2, lon2) = c2.to_radians()
  let dlon = lon2 - lon1
  let y = @math.sin(dlon) * @math.cos(lat2)
  let x = @math.cos(lat1) * @math.sin(lat2) - @math.sin(lat1) * @math.cos(lat2) * @math.cos(dlon)
  let mut bearing = @math.atan2(y, x) * 180.0 / pi
  if bearing < 0.0 {
    bearing = bearing + 360.0
  }
  bearing
}

///|
/// Computes destination coordinate along a great circle given distance in meters and bearing in degrees.
pub fn destination_point(start : @coord.Coord, distance_meters : Double, bearing_deg : Double) -> @coord.Coord {
  let (lat1, lon1) = start.to_radians()
  let angular_dist = distance_meters / earth_radius_meters
  let theta = bearing_deg * pi / 180.0
  let sin_lat1 = @math.sin(lat1)
  let cos_lat1 = @math.cos(lat1)
  let sin_dist = @math.sin(angular_dist)
  let cos_dist = @math.cos(angular_dist)
  
  let sin_lat2 = sin_lat1 * cos_dist + cos_lat1 * sin_dist * @math.cos(theta)
  let lat2 = @math.asin(sin_lat2)
  let y = @math.sin(theta) * sin_dist * cos_lat1
  let x = cos_dist - sin_lat1 * sin_lat2
  let lon2 = lon1 + @math.atan2(y, x)
  
  @coord.Coord::raw(lat2 * 180.0 / pi, lon2 * 180.0 / pi)
}

///|
/// Computes total path length of a LineString (array of coordinates) in meters using Haversine segments.
pub fn linestring_length(path : Array[@coord.Coord]) -> Double {
  if path.length() < 2 {
    return 0.0
  }
  let mut total = 0.0
  for i in 0..<(path.length() - 1) {
    total = total + haversine_distance(path[i], path[i + 1])
  }
  total
}
