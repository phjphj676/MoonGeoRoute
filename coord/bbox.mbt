///|
/// WGS84 Geographic Bounding Box (`min_lat`, `min_lon`, `max_lat`, `max_lon`).
pub(all) struct BBox {
  mut min_lat : Double
  mut min_lon : Double
  mut max_lat : Double
  mut max_lon : Double
} derive(Debug, Eq)

///|
/// Creates a new bounding box. Automatically orders min/max coordinates properly.
pub fn BBox::new(
  min_lat : Double,
  min_lon : Double,
  max_lat : Double,
  max_lon : Double,
) -> BBox {
  let actual_min_lat = if min_lat < max_lat { min_lat } else { max_lat }
  let actual_max_lat = if min_lat < max_lat { max_lat } else { min_lat }
  let actual_min_lon = if min_lon < max_lon { min_lon } else { max_lon }
  let actual_max_lon = if min_lon < max_lon { max_lon } else { min_lon }
  {
    min_lat: actual_min_lat,
    min_lon: actual_min_lon,
    max_lat: actual_max_lat,
    max_lon: actual_max_lon,
  }
}

///|
/// Computes a tight bounding box from an array of coordinates. Returns `None` if the array is empty.
pub fn BBox::from_coords(coords : Array[Coord]) -> BBox? {
  if coords.length() == 0 {
    return None
  }
  let mut min_lat = coords[0].lat
  let mut min_lon = coords[0].lon
  let mut max_lat = coords[0].lat
  let mut max_lon = coords[0].lon
  for i in 1..<coords.length() {
    let c = coords[i]
    if c.lat < min_lat {
      min_lat = c.lat
    }
    if c.lat > max_lat {
      max_lat = c.lat
    }
    if c.lon < min_lon {
      min_lon = c.lon
    }
    if c.lon > max_lon {
      max_lon = c.lon
    }
  }
  Some({ min_lat, min_lon, max_lat, max_lon })
}

///|
/// Checks if a geographic coordinate falls within this bounding box.
pub fn BBox::contains(self : BBox, c : Coord) -> Bool {
  c.lat >= self.min_lat &&
  c.lat <= self.max_lat &&
  c.lon >= self.min_lon &&
  c.lon <= self.max_lon
}

///|
/// Checks if two geographic bounding boxes intersect.
pub fn BBox::intersects(self : BBox, other : BBox) -> Bool {
  self.min_lat <= other.max_lat &&
  self.max_lat >= other.min_lat &&
  self.min_lon <= other.max_lon &&
  self.max_lon >= other.min_lon
}

///|
/// Expands the bounding box outward in all directions by a margin in degrees.
pub fn BBox::expand_by_margin(self : BBox, margin_deg : Double) -> BBox {
  let mut min_lat = self.min_lat - margin_deg
  let mut max_lat = self.max_lat + margin_deg
  let mut min_lon = self.min_lon - margin_deg
  let mut max_lon = self.max_lon + margin_deg
  if min_lat < -90.0 {
    min_lat = -90.0
  }
  if max_lat > 90.0 {
    max_lat = 90.0
  }
  if min_lon < -180.0 {
    min_lon = -180.0
  }
  if max_lon > 180.0 {
    max_lon = 180.0
  }
  { min_lat, min_lon, max_lat, max_lon }
}

///|
/// Returns the center coordinate of this bounding box.
pub fn BBox::center(self : BBox) -> Coord {
  {
    lat: (self.min_lat + self.max_lat) / 2.0,
    lon: (self.min_lon + self.max_lon) / 2.0,
  }
}

///|
/// Returns the latitudinal span (height) in degrees.
pub fn BBox::height_deg(self : BBox) -> Double {
  self.max_lat - self.min_lat
}

///|
/// Returns the longitudinal span (width) in degrees.
pub fn BBox::width_deg(self : BBox) -> Double {
  self.max_lon - self.min_lon
}

///|
pub impl Show for BBox with fn output(self, logger) {
  logger.write_string(
    "BBox(" +
    self.min_lat.to_string() +
    ", " +
    self.min_lon.to_string() +
    ", " +
    self.max_lat.to_string() +
    ", " +
    self.max_lon.to_string() +
    ")",
  )
}
