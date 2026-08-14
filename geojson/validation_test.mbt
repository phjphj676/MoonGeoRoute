///|
test "geojson validation accepts valid closed polygon" {
  let ring = [
    @coord.Coord::new(0.0, 0.0),
    @coord.Coord::new(0.0, 1.0),
    @coord.Coord::new(1.0, 1.0),
    @coord.Coord::new(0.0, 0.0),
  ]
  let report = FeatureCollection::new([
    Feature::new(@coord.Geometry::Polygon([ring]), id="valid"),
  ]).validate()
  inspect(report.has_errors(), content="false")
  inspect(report.feature_count, content="1")
  inspect(report.vertex_count, content="4")
}

///|
test "geojson validation reports open rings and malformed lines" {
  let open_ring = [
    @coord.Coord::new(0.0, 0.0),
    @coord.Coord::new(0.0, 1.0),
    @coord.Coord::new(1.0, 1.0),
  ]
  let report = FeatureCollection::new([
    Feature::new(@coord.Geometry::Polygon([open_ring])),
    Feature::new(@coord.Geometry::LineString([@coord.Coord::new(0.0, 0.0)])),
  ]).validate()
  inspect(report.has_errors(), content="true")
  inspect(report.error_count() >= 2, content="true")
  inspect(report.summary().contains("RING_NOT_CLOSED"), content="true")
}

///|
test "empty collection can be explicitly allowed" {
  let report = FeatureCollection::new([]).validate(allow_empty=true)
  inspect(report.has_errors(), content="false")
  inspect(report.warning_count(), content="0")
}
