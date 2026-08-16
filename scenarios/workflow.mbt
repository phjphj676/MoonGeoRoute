///|
/// A deterministic copy of the repository's public city-point fixture.
///
/// The coordinates are real city-centre reference points. The fixture is kept
/// inline so the end-to-end workflow does not depend on a network or a
/// filesystem working directory.
fn china_city_fixture() -> String {
  (
    #|{
    #|  "type": "FeatureCollection",
    #|  "features": [
    #|    {"type":"Feature","id":"beijing","properties":{"name":"Beijing"},"geometry":{"type":"Point","coordinates":[116.4074,39.9042]}},
    #|    {"type":"Feature","id":"shanghai","properties":{"name":"Shanghai"},"geometry":{"type":"Point","coordinates":[121.4737,31.2304]}},
    #|    {"type":"Feature","id":"guangzhou","properties":{"name":"Guangzhou"},"geometry":{"type":"Point","coordinates":[113.2644,23.1291]}},
    #|    {"type":"Feature","id":"shenzhen","properties":{"name":"Shenzhen"},"geometry":{"type":"Point","coordinates":[114.0579,22.5431]}},
    #|    {"type":"Feature","id":"chengdu","properties":{"name":"Chengdu"},"geometry":{"type":"Point","coordinates":[104.0665,30.5728]}}
    #|  ]
    #|}
  )
}

///|
/// Results emitted by the real-city coverage and service-network workflow.
pub(all) struct WorkflowReport {
  feature_count : Int
  valid_input : Bool
  northern_count : Int
  nearest_city : String
  density_count : Int
  route_start : String
  route_end : String
  route_connected : Bool
  route_node_count : Int
  route_within_limits : Bool
}

///|
/// Runs the complete application-shaped pipeline over real city reference
/// points and an explicitly imported service-network topology.
pub fn run_city_workflow() -> WorkflowReport {
  let collection = try! @geojson.parse_geojson(china_city_fixture())
  let validation = collection.validate()
  let index : @spatial.GridIndex[String] = @spatial.GridIndex::new(
    cell_size_deg=5.0,
  )
  for feature in collection.features {
    let id = match feature.id {
      Some(value) => value
      None => "missing"
    }
    match feature.geometry {
      @coord.Geometry::Point(coord) => index.insert(id, coord, id)
      _ => ()
    }
  }

  let northern = @coord.BBox::new(35.0, 110.0, 45.0, 125.0)
  let nearby = index.nearest_matches(@coord.Coord::raw(31.2, 121.4), 2)
  let nearest_city = if nearby.length() > 0 {
    nearby[0].item.id
  } else {
    "none"
  }
  let density = index.density_report(@coord.BBox::new(20.0, 100.0, 45.0, 125.0))

  // The graph represents an imported service-network topology. Its edges are
  // explicit; this test does not claim to distribute road geometry or replace
  // an OSM import step.
  let network = @graph.RoadNetwork::new(cell_size_deg=2.0)
  for feature in collection.features {
    let id = match feature.id {
      Some(value) => value
      None => "missing"
    }
    match feature.geometry {
      @coord.Geometry::Point(coord) => network.add_node(id, coord)
      _ => ()
    }
  }
  network.add_edge("beijing", "shanghai", bidirectional=true)
  network.add_edge("shanghai", "guangzhou", bidirectional=true)
  network.add_edge("guangzhou", "shenzhen", bidirectional=true)
  network.add_edge("beijing", "chengdu", bidirectional=true)
  network.add_edge("chengdu", "guangzhou", bidirectional=true)

  let route = match network.dijkstra("shenzhen", "beijing") {
    Some((path, _)) => path
    None => []
  }
  let route_start = if route.length() > 0 { route[0].id } else { "none" }
  let route_end = if route.length() > 0 {
    route[route.length() - 1].id
  } else {
    "none"
  }
  let metrics = network.route_metrics(route)
  {
    feature_count: collection.feature_count(),
    valid_input: !validation.has_errors() && validation.vertex_count == 5,
    northern_count: index.query_bbox(northern).length(),
    nearest_city,
    density_count: density.candidate_count,
    route_start,
    route_end,
    route_connected: metrics.connected,
    route_node_count: metrics.node_count,
    route_within_limits: network.route_within_limits(
      route,
      max_distance_meters=4000000.0,
    ),
  }
}
