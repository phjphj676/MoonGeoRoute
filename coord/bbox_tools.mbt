///|
/// Returns whether the box has valid WGS84 latitude/longitude bounds.
pub fn BBox::is_valid(self : BBox) -> Bool {
  self.min_lat >= -90.0 &&
  self.max_lat <= 90.0 &&
  self.min_lon >= -180.0 &&
  self.max_lon <= 180.0 &&
  self.min_lat <= self.max_lat &&
  self.min_lon <= self.max_lon
}

///|
/// Returns the smallest box containing both input boxes.
pub fn BBox::union(self : BBox, other : BBox) -> BBox {
  BBox::new(
    if self.min_lat < other.min_lat {
      self.min_lat
    } else {
      other.min_lat
    },
    if self.min_lon < other.min_lon {
      self.min_lon
    } else {
      other.min_lon
    },
    if self.max_lat > other.max_lat {
      self.max_lat
    } else {
      other.max_lat
    },
    if self.max_lon > other.max_lon {
      self.max_lon
    } else {
      other.max_lon
    },
  )
}

///|
/// Returns a copy constrained to the WGS84 latitude and longitude limits.
pub fn BBox::clamped(self : BBox) -> BBox {
  let min_lat = if self.min_lat < -90.0 { -90.0 } else { self.min_lat }
  let max_lat = if self.max_lat > 90.0 { 90.0 } else { self.max_lat }
  let min_lon = if self.min_lon < -180.0 {
    -180.0
  } else if self.min_lon > 180.0 {
    180.0
  } else {
    self.min_lon
  }
  let max_lon = if self.max_lon < -180.0 {
    -180.0
  } else if self.max_lon > 180.0 {
    180.0
  } else {
    self.max_lon
  }
  BBox::new(min_lat, min_lon, max_lat, max_lon)
}

///|
/// Returns a regular row-major grid of boxes covering this box. The function
/// is useful for tiled aggregation and keeps the final row/column exact.
pub fn BBox::subdivide(self : BBox, rows : Int, columns : Int) -> Array[BBox] {
  let result = []
  if rows <= 0 || columns <= 0 {
    return result
  }
  let lat_step = self.height_deg() / rows.to_double()
  let lon_step = self.width_deg() / columns.to_double()
  for row in 0..<rows {
    for column in 0..<columns {
      let min_lat = self.min_lat + row.to_double() * lat_step
      let min_lon = self.min_lon + column.to_double() * lon_step
      let max_lat = if row == rows - 1 {
        self.max_lat
      } else {
        min_lat + lat_step
      }
      let max_lon = if column == columns - 1 {
        self.max_lon
      } else {
        min_lon + lon_step
      }
      result.push(BBox::new(min_lat, min_lon, max_lat, max_lon))
    }
  }
  result
}

///|
/// Returns whether a box contains another box, including shared boundaries.
pub fn BBox::contains_bbox(self : BBox, other : BBox) -> Bool {
  self.min_lat <= other.min_lat &&
  self.max_lat >= other.max_lat &&
  self.min_lon <= other.min_lon &&
  self.max_lon >= other.max_lon
}

///|
/// Returns a box translated by degree offsets and clamped to WGS84 bounds.
pub fn BBox::translated(
  self : BBox,
  lat_delta : Double,
  lon_delta : Double,
) -> BBox {
  BBox::new(
    self.min_lat + lat_delta,
    self.min_lon + lon_delta,
    self.max_lat + lat_delta,
    self.max_lon + lon_delta,
  ).clamped()
}

///|
/// Returns a coordinate translated in degree space. This is intended for
/// small local offsets and deliberately does not pretend to be a projection.
pub fn Coord::translated(
  self : Coord,
  lat_delta : Double,
  lon_delta : Double,
) -> Coord {
  let lat = self.lat + lat_delta
  let lon = self.lon + lon_delta
  let safe_lat = if lat < -90.0 {
    -90.0
  } else if lat > 90.0 {
    90.0
  } else {
    lat
  }
  let safe_lon = if lon < -180.0 {
    lon + 360.0
  } else if lon > 180.0 {
    lon - 360.0
  } else {
    lon
  }
  Coord::raw(safe_lat, safe_lon)
}
