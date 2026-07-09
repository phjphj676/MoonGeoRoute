///|
pub(all) suberror InvalidCoordError {
  InvalidCoordError(String)
} derive(Eq)

///|
/// WGS84 Geographic Coordinate (latitude and longitude in degrees).
pub(all) struct Coord {
  mut lat : Double
  mut lon : Double
} derive(Debug, Eq)

///|
/// Creates a new `Coord` with validation for latitude [-90.0, 90.0] and longitude [-180.0, 180.0].
pub fn Coord::new(lat : Double, lon : Double) -> Coord raise InvalidCoordError {
  if lat < -90.0 || lat > 90.0 {
    raise InvalidCoordError("Latitude out of bounds [-90, 90]: " + lat.to_string())
  }
  let mut normalized_lon = lon
  while normalized_lon < -180.0 {
    normalized_lon = normalized_lon + 360.0
  }
  while normalized_lon > 180.0 {
    normalized_lon = normalized_lon - 360.0
  }
  { lat, lon: normalized_lon }
}

///|
/// Creates a `Coord` without validation (useful for internal fast construction).
pub fn Coord::raw(lat : Double, lon : Double) -> Coord {
  { lat, lon }
}

///|
/// Converts latitude and longitude from degrees to radians.
pub fn Coord::to_radians(self : Coord) -> (Double, Double) {
  let pi = 3.14159265358979323846
  (self.lat * pi / 180.0, self.lon * pi / 180.0)
}

///|
/// Computes Euclidean squared distance in degree space (fast approximation for spatial grid sorting).
pub fn Coord::distance_deg_sq(self : Coord, other : Coord) -> Double {
  let dlat = self.lat - other.lat
  let dlon = self.lon - other.lon
  dlat * dlat + dlon * dlon
}

///|
pub impl Show for Coord with output(self, logger) {
  logger.write_string("Coord(lat=" + self.lat.to_string() + ", lon=" + self.lon.to_string() + ")")
}
