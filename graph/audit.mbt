///|
/// Network-level counts used in import diagnostics and benchmark reports.
pub(all) struct NetworkStats {
  node_count : Int
  edge_count : Int
  connected_node_count : Int
  isolated_node_count : Int
  total_edge_distance_meters : Double
} derive(Debug, Eq)

///|
/// Returns the number of nodes in the network.
pub fn RoadNetwork::node_count(self : RoadNetwork) -> Int {
  self.nodes.length()
}

///|
/// Returns the number of directed edges. A bidirectional edge contributes two.
pub fn RoadNetwork::edge_count(self : RoadNetwork) -> Int {
  let mut count = 0
  for edges in self.adjacency.values() {
    count = count + edges.length()
  }
  count
}

///|
/// Returns true when a directed edge exists from `from_id` to `to_id`.
pub fn RoadNetwork::has_edge(
  self : RoadNetwork,
  from_id : String,
  to_id : String,
) -> Bool {
  match self.adjacency.get(from_id) {
    Some(edges) => {
      for edge in edges {
        if edge.to_id == to_id {
          return true
        }
      }
      false
    }
    None => false
  }
}

///|
/// Traverses the directed network from a starting node using breadth-first search.
pub fn RoadNetwork::reachable_nodes(
  self : RoadNetwork,
  start_id : String,
) -> Array[String] {
  if self.nodes.get(start_id) is None {
    return []
  }
  let visited : Map[String, Bool] = {}
  let queue = [start_id]
  visited.set(start_id, true)
  let mut head = 0
  while head < queue.length() {
    let current = queue[head]
    head = head + 1
    match self.adjacency.get(current) {
      Some(edges) =>
        for edge in edges {
          if visited.get(edge.to_id) is None {
            visited.set(edge.to_id, true)
            queue.push(edge.to_id)
          }
        }
      None => ()
    }
  }
  queue
}

///|
/// Builds a deterministic import-quality report for a directed road network.
pub fn RoadNetwork::network_stats(self : RoadNetwork) -> NetworkStats {
  let mut total_distance = 0.0
  let mut active_nodes = 0
  let mut isolated_nodes = 0
  let mut edge_count = 0
  for node_edges in self.adjacency.values() {
    if node_edges.is_empty() {
      isolated_nodes = isolated_nodes + 1
    } else {
      active_nodes = active_nodes + 1
    }
    for edge in node_edges {
      edge_count = edge_count + 1
      total_distance = total_distance + edge.distance_meters
    }
  }
  {
    node_count: self.nodes.length(),
    edge_count,
    connected_node_count: active_nodes,
    isolated_node_count: isolated_nodes,
    total_edge_distance_meters: total_distance,
  }
}

///|
/// Checks that a route is connected and within optional distance/cost limits.
pub fn RoadNetwork::route_within_limits(
  self : RoadNetwork,
  path : Array[Node],
  max_distance_meters? : Double,
  max_weight? : Double,
) -> Bool {
  let metrics = self.route_metrics(path)
  if !metrics.connected {
    return false
  }
  match max_distance_meters {
    Some(limit) =>
      if limit < 0.0 || metrics.distance_meters > limit {
        return false
      }
    None => ()
  }
  match max_weight {
    Some(limit) =>
      if limit < 0.0 || metrics.total_weight > limit {
        return false
      }
    None => ()
  }
  true
}
