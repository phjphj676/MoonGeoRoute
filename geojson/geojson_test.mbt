///|
test "geojson point feature serialization and parsing" {
  let pt = @coord.Coord::new(39.9042, 116.4074)
  let geom = @coord.Geometry::Point(pt)
  let props : Map[String, Json] = Map([])
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

///|
test "geojson feature collection stats" {
  let p1 = @coord.Coord::new(39.9042, 116.4074)
  let p2 = @coord.Coord::new(31.2304, 121.4737)
  let fc = FeatureCollection::new([
    Feature::new(@coord.Geometry::Point(p1), id="bj"),
    Feature::new(@coord.Geometry::Point(p2), id="sh"),
  ])

  inspect(fc.feature_count(), content="2")
  match fc.bbox() {
    Some(bb) => {
      inspect(bb.contains(p1), content="true")
      inspect(bb.contains(p2), content="true")
    }
    None => fail("Expected feature collection bbox")
  }
}

///|
test "geojson preserves a multipolygon and rejects malformed coordinates" {
  let text = "{\"type\":\"FeatureCollection\",\"features\":[{\"type\":\"Feature\",\"id\":\"islands\",\"geometry\":{\"type\":\"MultiPolygon\",\"coordinates\":[[[[116.0,39.0],[117.0,39.0],[117.0,40.0],[116.0,39.0]]],[[[121.0,31.0],[122.0,31.0],[122.0,32.0],[121.0,31.0]]]]},\"properties\":{}}]}"
  let fc = parse_geojson(text)
  inspect(fc.feature_count(), content="1")
  match fc.features[0].geometry {
    @coord.Geometry::MultiPolygon(polys) => inspect(polys.length(), content="2")
    _ => fail("Expected a multipolygon")
  }
  try
    parse_geojson(
      "{\"type\":\"FeatureCollection\",\"features\":[{\"type\":\"Feature\",\"geometry\":{\"type\":\"Point\",\"coordinates\":[]}}]}",
    )
  catch {
    GeoJsonParseError(_) => ()
  } noraise {
    _ => fail("Malformed coordinates must raise GeoJsonParseError")
  }
}
