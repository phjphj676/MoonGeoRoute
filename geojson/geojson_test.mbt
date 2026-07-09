///|
test "geojson point feature serialization and parsing" {
  let pt = @coord.Coord::new(39.9042, 116.4074)
  let geom = @coord.Geometry::Point(pt)
  let props : Map[String, Json] = {}
  props.set("name", Json::string("Beijing"))
  let f = Feature::new(geom, id="CN-BJ", properties=props)

  let json = f.to_json()
  let f_parsed = Feature::from_json_value(json)
  match f_parsed.id {
    Some(id) => inspect(id, content="CN-BJ")
    None => fail("Expected feature id CN-BJ")
  }
}

///|
test "geojson feature collection parsing and spatial filtering" {
  let p1 = @coord.Coord::new(39.9042, 116.4074) // Beijing
  let p2 = @coord.Coord::new(31.2304, 121.4737) // Shanghai
  let f1 = Feature::new(@coord.Geometry::Point(p1), id="bj")
  let f2 = Feature::new(@coord.Geometry::Point(p2), id="sh")
  let fc = FeatureCollection::new([f1, f2])

  // Filter with Northern China bbox
  let north_bbox = @coord.BBox::new(35.0, 110.0, 45.0, 120.0)
  let filtered_fc = filter_by_bbox(fc, north_bbox)
  inspect(filtered_fc.features.length(), content="1")
  match filtered_fc.features[0].id {
    Some(id) => inspect(id, content="bj")
    None => fail("Expected feature bj")
  }
}
