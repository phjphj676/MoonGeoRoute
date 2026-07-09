///|
/// Filters a `FeatureCollection` by spatial bounding box, returning only features whose geometries intersect `bbox`.
pub fn filter_by_bbox(collection : FeatureCollection, bbox : @coord.BBox) -> FeatureCollection {
  let result = []
  for f in collection.features {
    match f.geometry.bbox() {
      Some(f_bbox) =>
        if f_bbox.intersects(bbox) {
          result.push(f)
        }
      None => ()
    }
  }
  FeatureCollection::new(result)
}

///|
/// Filters a `FeatureCollection` by a polygon boundary, returning features with at least one vertex inside the polygon.
pub fn filter_by_polygon(collection : FeatureCollection, polygon_ring : Array[@coord.Coord]) -> FeatureCollection {
  let result = []
  for f in collection.features {
    let coords = f.geometry.to_coords()
    let mut is_inside = false
    for c in coords {
      if @geomath.point_in_polygon(c, polygon_ring) {
        is_inside = true
        break
      }
    }
    if is_inside {
      result.push(f)
    }
  }
  FeatureCollection::new(result)
}
