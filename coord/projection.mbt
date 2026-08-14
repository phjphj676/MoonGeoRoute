///|
/// A point in the Web Mercator projection, expressed in meters.
pub(all) struct WebMercatorPoint {
  x : Double
  y : Double
} derive(Debug, Eq)

///|
/// A slippy-map tile coordinate at an integer zoom level.
pub(all) struct TileCoord {
  x : Int
  y : Int
  z : Int
} derive(Debug, Eq)

///|
/// Web Mercator half-world extent at the equator.
pub const WEB_MERCATOR_HALF_WORLD : Double = 20037508.342789244

///|
/// Maximum latitude supported by spherical Web Mercator.
pub const WEB_MERCATOR_MAX_LAT : Double = 85.0511287798066

///|
fn clamp_projection_latitude(lat : Double) -> Double {
  if lat < -WEB_MERCATOR_MAX_LAT {
    -WEB_MERCATOR_MAX_LAT
  } else if lat > WEB_MERCATOR_MAX_LAT {
    WEB_MERCATOR_MAX_LAT
  } else {
    lat
  }
}

///|
fn clamp_longitude(longitude : Double) -> Double {
  let mut value = longitude
  while value < -180.0 {
    value = value + 360.0
  }
  while value > 180.0 {
    value = value - 360.0
  }
  value
}

///|
/// Projects WGS84 latitude/longitude into spherical Web Mercator meters.
pub fn Coord::to_web_mercator(self : Coord) -> WebMercatorPoint {
  let lat = clamp_projection_latitude(self.lat)
  let lon = clamp_longitude(self.lon)
  let radians = 3.14159265358979323846 / 180.0
  let x = lon * WEB_MERCATOR_HALF_WORLD / 180.0
  let y = WEB_MERCATOR_HALF_WORLD /
    3.14159265358979323846 *
    @math.ln(@math.tan(3.14159265358979323846 / 4.0 + lat * radians / 2.0))
  { x, y }
}

///|
/// Converts a Web Mercator point back to a normalized WGS84 coordinate.
pub fn WebMercatorPoint::to_coord(self : WebMercatorPoint) -> Coord {
  let longitude = self.x / WEB_MERCATOR_HALF_WORLD * 180.0
  let latitude = (
      2.0 *
      @math.atan(
        @math.exp(self.y / WEB_MERCATOR_HALF_WORLD * 3.14159265358979323846),
      ) -
      3.14159265358979323846 / 2.0
    ) *
    180.0 /
    3.14159265358979323846
  Coord::raw(latitude, clamp_longitude(longitude))
}

///|
/// Returns Euclidean projected distance in meters between two projected points.
pub fn WebMercatorPoint::distance_meters(
  self : WebMercatorPoint,
  other : WebMercatorPoint,
) -> Double {
  let dx = self.x - other.x
  let dy = self.y - other.y
  (dx * dx + dy * dy).sqrt()
}

///|
/// Projects the corners of a geographic bounding box.
pub fn BBox::to_web_mercator(self : BBox) -> BBox {
  let south_west = Coord::raw(self.min_lat, self.min_lon).to_web_mercator()
  let north_east = Coord::raw(self.max_lat, self.max_lon).to_web_mercator()
  BBox::new(south_west.y, south_west.x, north_east.y, north_east.x)
}

///|
/// Converts a Web Mercator extent back to geographic coordinates.
pub fn BBox::from_web_mercator(self : BBox) -> BBox {
  let south_west = WebMercatorPoint::{ x: self.min_lon, y: self.min_lat }.to_coord()
  let north_east = WebMercatorPoint::{ x: self.max_lon, y: self.max_lat }.to_coord()
  BBox::new(south_west.lat, south_west.lon, north_east.lat, north_east.lon)
}

///|
/// Converts a coordinate to an XYZ slippy-map tile.
pub fn Coord::to_tile(self : Coord, zoom : Int) -> TileCoord {
  let safe_zoom = if zoom < 0 { 0 } else if zoom > 30 { 30 } else { zoom }
  let scale = (1 << safe_zoom).to_double()
  let lon = clamp_longitude(self.lon)
  let lat = clamp_projection_latitude(self.lat)
  let x = ((lon + 180.0) / 360.0 * scale).floor().to_int()
  let radians = lat * 3.14159265358979323846 / 180.0
  let y = ((
      1.0 -
      @math.ln(@math.tan(3.14159265358979323846 / 4.0 + radians / 2.0)) /
      3.14159265358979323846
    ) /
    2.0 *
    scale)
    .floor()
    .to_int()
  let max_tile = (scale - 1.0).to_int()
  {
    x: if x < 0 {
      0
    } else if x > max_tile {
      max_tile
    } else {
      x
    },
    y: if y < 0 {
      0
    } else if y > max_tile {
      max_tile
    } else {
      y
    },
    z: safe_zoom,
  }
}

///|
/// Returns the geographic bounds of an XYZ tile.
pub fn TileCoord::bounds(self : TileCoord) -> BBox {
  let scale = (1 << self.z).to_double()
  let west = self.x.to_double() / scale * 360.0 - 180.0
  let east = (self.x + 1).to_double() / scale * 360.0 - 180.0
  let north_y = 3.14159265358979323846 *
    (1.0 - 2.0 * self.y.to_double() / scale)
  let south_y = 3.14159265358979323846 *
    (1.0 - 2.0 * (self.y + 1).to_double() / scale)
  let north_exp = @math.exp(north_y)
  let south_exp = @math.exp(south_y)
  let north = @math.atan((north_exp - 1.0 / north_exp) / 2.0) *
    180.0 /
    3.14159265358979323846
  let south = @math.atan((south_exp - 1.0 / south_exp) / 2.0) *
    180.0 /
    3.14159265358979323846
  BBox::new(south, west, north, east)
}

///|
/// Returns the center coordinate of an XYZ tile.
pub fn TileCoord::center(self : TileCoord) -> Coord {
  self.bounds().center()
}

///|
/// Tests whether a projected point lies inside a projected box.
pub fn WebMercatorPoint::inside(self : WebMercatorPoint, bbox : BBox) -> Bool {
  self.x >= bbox.min_lon &&
  self.x <= bbox.max_lon &&
  self.y >= bbox.min_lat &&
  self.y <= bbox.max_lat
}
