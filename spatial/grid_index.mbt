///|
/// A spatial data item associating an ID, coordinate location, and payload data `T`.
pub(all) struct SpatialItem[T] {
  id : String
  coord : @coord.Coord
  data : T
}

///|
/// Uniform Spatial Grid Index dividing 2D space into uniform grid cells of `cell_size_deg` degrees.
pub(all) struct GridIndex[T] {
  cell_size_deg : Double
  cells : Map[String, Array[SpatialItem[T]]]
}

///|
/// Creates a new `GridIndex` with default `cell_size_deg = 0.5` degrees (~55km cell width).
pub fn[T] GridIndex::new(cell_size_deg? : Double) -> GridIndex[T] {
  let size = match cell_size_deg {
    Some(s) => if s <= 0.0 { 0.5 } else { s }
    None => 0.5
  }
  { cell_size_deg: size, cells: {} }
}

///|
/// Computes grid bucket key for a given coordinate.
fn[T] GridIndex::cell_key(self : GridIndex[T], c : @coord.Coord) -> String {
  let gx = Double::floor(c.lon / self.cell_size_deg).to_int()
  let gy = Double::floor(c.lat / self.cell_size_deg).to_int()
  gx.to_string() + "_" + gy.to_string()
}

///|
/// Inserts a spatial item into the grid index.
pub fn[T] GridIndex::insert(
  self : GridIndex[T],
  id : String,
  coord : @coord.Coord,
  data : T,
) -> Unit {
  let key = self.cell_key(coord)
  let item = { id, coord, data }
  match self.cells.get(key) {
    Some(arr) => arr.push(item)
    None => self.cells.set(key, [item])
  }
}

///|
/// Queries all spatial items located inside the specified geographic bounding box `bbox`.
pub fn[T] GridIndex::query_bbox(
  self : GridIndex[T],
  bbox : @coord.BBox,
) -> Array[SpatialItem[T]] {
  let min_gx = Double::floor(bbox.min_lon / self.cell_size_deg).to_int()
  let max_gx = Double::floor(bbox.max_lon / self.cell_size_deg).to_int()
  let min_gy = Double::floor(bbox.min_lat / self.cell_size_deg).to_int()
  let max_gy = Double::floor(bbox.max_lat / self.cell_size_deg).to_int()

  let result = []
  for gx in min_gx..<=max_gx {
    for gy in min_gy..<=max_gy {
      let key = gx.to_string() + "_" + gy.to_string()
      match self.cells.get(key) {
        Some(arr) =>
          for item in arr {
            if bbox.contains(item.coord) {
              result.push(item)
            }
          }
        None => ()
      }
    }
  }
  result
}

///|
/// Finds the nearest spatial item and its distance in meters from `target` coordinate using grid expansion.
pub fn[T] GridIndex::nearest_neighbor(
  self : GridIndex[T],
  target : @coord.Coord,
) -> (SpatialItem[T], Double)? {
  let mut best_item : SpatialItem[T]? = None
  let mut min_dist = 1.0e18
  let mut min_found_ring = -1

  let tgx = Double::floor(target.lon / self.cell_size_deg).to_int()
  let tgy = Double::floor(target.lat / self.cell_size_deg).to_int()

  // Expanding ring search up to radius 20 cells
  for ring in 0..<=20 {
    let mut found_in_ring = false
    for dx in -ring..<=ring {
      for dy in -ring..<=ring {
        if Int::abs(dx) == ring || Int::abs(dy) == ring {
          let gx = tgx + dx
          let gy = tgy + dy
          let key = gx.to_string() + "_" + gy.to_string()
          match self.cells.get(key) {
            Some(arr) =>
              for item in arr {
                let dist = @geomath.haversine_distance(target, item.coord)
                if dist < min_dist {
                  min_dist = dist
                  best_item = Some(item)
                  found_in_ring = true
                }
              }
            None => ()
          }
        }
      }
    }
    // If found and min_found_ring is not set, set it
    if found_in_ring && min_found_ring == -1 {
      min_found_ring = ring
    }
    // Break after checking exactly one full ring beyond the first ring a match was found in
    if min_found_ring != -1 && ring > min_found_ring {
      break
    }
  }

  match best_item {
    Some(item) => Some((item, min_dist))
    None => None
  }
}
