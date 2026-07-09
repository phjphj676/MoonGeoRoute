///|
test "road network construction and dijkstra routing" {
  let net = RoadNetwork::new(cell_size_deg=1.0)
  let n1 = @coord.Coord::new(0.0, 0.0)
  let n2 = @coord.Coord::new(0.0, 1.0)
  let n3 = @coord.Coord::new(1.0, 1.0)
  let n4 = @coord.Coord::new(1.0, 0.0)

  net.add_node("A", n1)
  net.add_node("B", n2)
  net.add_node("C", n3)
  net.add_node("D", n4)

  // Add edges A->B->C (cost 10+10 = 20) and A->D->C (cost 5+5 = 10)
  net.add_edge("A", "B", weight=10.0)
  net.add_edge("B", "C", weight=10.0)
  net.add_edge("A", "D", weight=5.0)
  net.add_edge("D", "C", weight=5.0)

  match net.dijkstra("A", "C") {
    Some((path, cost)) => {
      inspect(cost, content="10")
      inspect(path.length(), content="3")
      inspect(path[1].id, content="D")
    }
    None => fail("Should find shortest path via D")
  }
}

///|
test "a_star routing and coordinate snapping" {
  let net = RoadNetwork::new(cell_size_deg=1.0)
  let bj = @coord.Coord::new(39.9042, 116.4074)
  let tj = @coord.Coord::new(39.0842, 117.2009)
  let sh = @coord.Coord::new(31.2304, 121.4737)

  net.add_node("bj", bj)
  net.add_node("tj", tj)
  net.add_node("sh", sh)

  net.add_edge("bj", "tj", bidirectional=true)
  net.add_edge("tj", "sh", bidirectional=true)

  // Find path from Beijing center to Shanghai center via A*
  match net.a_star("bj", "sh") {
    Some((path, _)) => {
      inspect(path.length(), content="3")
      inspect(path[0].id, content="bj")
      inspect(path[2].id, content="sh")
    }
    None => fail("Should find path between Beijing and Shanghai")
  }

  // Snapping query from coordinates slightly off Beijing and Shanghai
  let near_bj = @coord.Coord::new(39.91, 116.41)
  let near_sh = @coord.Coord::new(31.24, 121.48)
  match net.find_path_by_coords(near_bj, near_sh) {
    Some((path, _)) => inspect(path[2].id, content="sh")
    None => fail("Should snap coordinates and find path")
  }
}
