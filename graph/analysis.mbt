///|
/// A compact audit report for a route returned by `RoadNetwork`.
///
/// The report is useful to callers that need to display route summaries,
/// compare alternative routes, or reject malformed paths before persistence.
pub(all) struct RouteMetrics {
  node_count : Int
  edge_count : Int
  distance_meters : Double
  total_weight : Double
  bounds : @coord.BBox?
  connected : Bool
} derive(Debug, Eq)

///|
fn find_route_edge_weight(
  network : RoadNetwork,
  from_id : String,
  to_id : String,
  fallback : Double,
) -> Double {
  match network.adjacency.get(from_id) {
    Some(edges) => {
      for edge in edges {
        if edge.to_id == to_id {
          return edge.weight
        }
      }
      fallback
    }
    None => fallback
  }
}

///|
/// Summarizes a route and checks that every consecutive pair is a graph edge.
///
/// An empty or one-node path is considered connected. If a path contains a
/// node that is not in the network, or a missing edge, `connected` is false;
/// the geometric distance is still reported so callers can show diagnostics.
pub fn RoadNetwork::route_metrics(
  self : RoadNetwork,
  path : Array[Node],
) -> RouteMetrics {
  let mut distance = 0.0
  let mut weight = 0.0
  let mut connected = true
  let coords = []

  for node in path {
    coords.push(node.coord)
    if self.nodes.get(node.id) is None {
      connected = false
    }
  }

  if path.length() > 1 {
    for i in 0..<(path.length() - 1) {
      let from = path[i]
      let to = path[i + 1]
      let segment_distance = @geomath.haversine_distance(from.coord, to.coord)
      distance = distance + segment_distance
      match self.adjacency.get(from.id) {
        Some(edges) => {
          let mut found = false
          for edge in edges {
            if edge.to_id == to.id {
              weight = weight + edge.weight
              found = true
              break
            }
          }
          if !found {
            connected = false
            weight = weight + segment_distance
          }
        }
        None => {
          connected = false
          weight = weight + segment_distance
        }
      }
    }
  }

  {
    node_count: path.length(),
    edge_count: if path.length() > 0 {
      path.length() - 1
    } else {
      0
    },
    distance_meters: distance,
    total_weight: weight,
    bounds: @coord.BBox::from_coords(coords),
    connected,
  }
}

///|
/// Returns the weight of a single route segment, or its geographic distance
/// when the segment is not present in the network. This helper is intended for
/// callers that need a stable cost estimate while constructing a route report.
pub fn RoadNetwork::segment_weight(
  self : RoadNetwork,
  from : Node,
  to : Node,
) -> Double {
  let distance = @geomath.haversine_distance(from.coord, to.coord)
  find_route_edge_weight(self, from.id, to.id, distance)
}
