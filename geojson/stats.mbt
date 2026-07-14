///|
/// Returns the number of features in this collection.
pub fn FeatureCollection::feature_count(self : FeatureCollection) -> Int {
  self.features.length()
}

///|
/// Computes the geographic bounding box of all geometries in this collection.
/// Returns `None` when the collection is empty or when no coordinates are present.
pub fn FeatureCollection::bbox(self : FeatureCollection) -> @coord.BBox? {
  let all_coords = []
  for feature in self.features {
    let coords = feature.geometry.to_coords()
    for c in coords {
      all_coords.push(c)
    }
  }
  @coord.BBox::from_coords(all_coords)
}
