///|
/// A distance-ranked spatial match returned by radius and nearest queries.
pub(all) struct RadiusMatch[T] {
  item : SpatialItem[T]
  distance_meters : Double
}

///|
/// Summary of a spatial density query over a geographic bounding box.
pub(all) struct DensityReport {
  candidate_count : Int
  cell_count : Int
  occupied_cell_count : Int
  density_per_square_km : Double
  bbox_area_square_km : Double
} derive(Debug, Eq)

///|
/// Returns a stable grid key for integer cell coordinates.
fn grid_key(gx : Int, gy : Int) -> String {
  gx.to_string() + "_" + gy.to_string()
}

///|
/// Computes the approximate area of a geographic bounding box in square kilometres.
fn bbox_area_square_km(bbox : @coord.BBox) -> Double {
  let west = @coord.Coord::raw(bbox.min_lat, bbox.min_lon)
  let east = @coord.Coord::raw(bbox.min_lat, bbox.max_lon)
  let south = @coord.Coord::raw(
    bbox.min_lat,
    (bbox.min_lon + bbox.max_lon) / 2.0,
  )
  let north = @coord.Coord::raw(
    bbox.max_lat,
    (bbox.min_lon + bbox.max_lon) / 2.0,
  )
  let width_km = @geomath.haversine_distance(west, east) / 1000.0
  let height_km = @geomath.haversine_distance(south, north) / 1000.0
  width_km * height_km
}

///|
/// Returns all items within a great-circle radius. The query first limits cells
/// using a conservative latitude/longitude envelope and then applies Haversine
/// distance, so callers receive exact spherical-distance filtering.
pub fn[T] GridIndex::query_radius(
  self : GridIndex[T],
  target : @coord.Coord,
  radius_meters : Double,
) -> Array[RadiusMatch[T]] {
  let result = []
  if radius_meters < 0.0 {
    return result
  }
  let radius_deg = radius_meters / 111320.0
  let search_box = @coord.BBox::new(
    target.lat - radius_deg,
    target.lon - radius_deg,
    target.lat + radius_deg,
    target.lon + radius_deg,
  )
  let candidates = self.query_bbox(search_box)
  for item in candidates {
    let distance = @geomath.haversine_distance(target, item.coord)
    if distance <= radius_meters {
      result.push({ item, distance_meters: distance })
    }
  }
  result
}

///|
/// Returns up to `limit` matches ordered from nearest to farthest.
pub fn[T] GridIndex::nearest_matches(
  self : GridIndex[T],
  target : @coord.Coord,
  limit : Int,
) -> Array[RadiusMatch[T]] {
  let result = []
  if limit <= 0 {
    return result
  }
  let candidates = self.query_radius(target, 20000000.0)
  for candidate in candidates {
    let mut insert_at = result.length()
    for i in 0..<result.length() {
      if candidate.distance_meters < result[i].distance_meters {
        insert_at = i
        break
      }
    }
    result.push(candidate)
    let mut i = result.length() - 1
    while i > insert_at {
      result[i] = result[i - 1]
      i = i - 1
    }
    result[insert_at] = candidate
    if result.length() > limit {
      let _ = result.pop()
    }
  }
  result
}

///|
/// Reports occupancy and point density for a bounding box. Empty areas return
/// zero density instead of producing a division-by-zero result.
pub fn[T] GridIndex::density_report(
  self : GridIndex[T],
  bbox : @coord.BBox,
) -> DensityReport {
  let items = self.query_bbox(bbox)
  let min_gx = Double::floor(bbox.min_lon / self.cell_size_deg).to_int()
  let max_gx = Double::floor(bbox.max_lon / self.cell_size_deg).to_int()
  let min_gy = Double::floor(bbox.min_lat / self.cell_size_deg).to_int()
  let max_gy = Double::floor(bbox.max_lat / self.cell_size_deg).to_int()
  let cell_count = (max_gx - min_gx + 1) * (max_gy - min_gy + 1)
  let mut occupied = 0
  for gx in min_gx..<=max_gx {
    for gy in min_gy..<=max_gy {
      if self.cells.get(grid_key(gx, gy)) is Some(_) {
        occupied = occupied + 1
      }
    }
  }
  let area = bbox_area_square_km(bbox)
  {
    candidate_count: items.length(),
    cell_count,
    occupied_cell_count: occupied,
    density_per_square_km: if area > 0.0 {
      items.length().to_double() / area
    } else {
      0.0
    },
    bbox_area_square_km: area,
  }
}
