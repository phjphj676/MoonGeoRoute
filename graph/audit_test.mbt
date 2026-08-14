///|
fn audit_network() -> RoadNetwork {
  let network = RoadNetwork::new(cell_size_deg=0.1)
  network.add_node("a", @coord.Coord::raw(39.9, 116.4))
  network.add_node("b", @coord.Coord::raw(39.91, 116.41))
  network.add_node("c", @coord.Coord::raw(39.92, 116.42))
  network.add_node("isolated", @coord.Coord::raw(40.0, 117.0))
  network.add_edge("a", "b", bidirectional=true)
  network.add_edge("b", "c", bidirectional=true)
  network
}

///|
test "network audit counts directed edges and isolation" {
  let network = audit_network()
  inspect(network.node_count(), content="4")
  inspect(network.edge_count(), content="4")
  let stats = network.network_stats()
  inspect(stats.isolated_node_count, content="1")
  inspect(stats.edge_count, content="4")
}

///|
test "reachable nodes follows one-way connectivity" {
  let network = audit_network()
  let reachable = network.reachable_nodes("a")
  inspect(reachable.length(), content="3")
  inspect(network.has_edge("a", "b"), content="true")
  inspect(network.has_edge("a", "c"), content="false")
}

///|
test "route limits reject disconnected and overlong paths" {
  let network = audit_network()
  let route = match network.dijkstra("a", "c") {
    Some((path, _)) => path
    None => []
  }
  inspect(
    network.route_within_limits(route, max_distance_meters=100000.0),
    content="true",
  )
  inspect(
    network.route_within_limits(route, max_distance_meters=1.0),
    content="false",
  )
  let a = match network.nodes.get("a") {
    Some(node) => node
    None => fail("missing a")
  }
  let isolated = match network.nodes.get("isolated") {
    Some(node) => node
    None => fail("missing isolated")
  }
  let disconnected = [a, isolated]
  inspect(network.route_within_limits(disconnected), content="false")
}
