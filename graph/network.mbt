///|
/// A topological graph node representing a physical intersection or waypoint.
pub(all) struct Node {
  id : String
  coord : @coord.Coord
} derive(Debug, Eq)

///|
/// A directed road network edge connecting two nodes with physical distance and cost weight.
pub(all) struct Edge {
  from_id : String
  to_id : String
  distance_meters : Double
  weight : Double
} derive(Debug, Eq)

///|
/// A topological road network storing nodes, adjacency lists, and a spatial grid index for fast coordinate snapping.
pub(all) struct RoadNetwork {
  nodes : Map[String, Node]
  adjacency : Map[String, Array[Edge]]
  spatial_index : @spatial.GridIndex[String]
}

///|
/// Initializes an empty `RoadNetwork`.
pub fn RoadNetwork::new(cell_size_deg? : Double) -> RoadNetwork {
  let size = match cell_size_deg {
    Some(s) => s
    None => 0.5
  }
  {
    nodes: {},
    adjacency: {},
    spatial_index: @spatial.GridIndex::new(cell_size_deg=size),
  }
}

///|
/// Adds a node with a geographical coordinate into the road network.
pub fn RoadNetwork::add_node(self : RoadNetwork, id : String, coord : @coord.Coord) -> Unit {
  let node = { id, coord }
  self.nodes.set(id, node)
  self.spatial_index.insert(id, coord, id)
  if self.adjacency.get(id) is None {
    self.adjacency.set(id, [])
  }
}

///|
/// Adds a directed edge between `from_id` and `to_id`. Optionally computes distance automatically and supports bidirectional insertion.
pub fn RoadNetwork::add_edge(
  self : RoadNetwork,
  from_id : String,
  to_id : String,
  weight? : Double,
  bidirectional? : Bool
) -> Unit {
  let n_from = match self.nodes.get(from_id) {
    Some(n) => n
    None => return
  }
  let n_to = match self.nodes.get(to_id) {
    Some(n) => n
    None => return
  }

  let dist = @geomath.haversine_distance(n_from.coord, n_to.coord)
  let w = match weight {
    Some(val) => val
    None => dist
  }

  let edge = { from_id, to_id, distance_meters: dist, weight: w }
  match self.adjacency.get(from_id) {
    Some(arr) => arr.push(edge)
    None => self.adjacency.set(from_id, [edge])
  }

  let bidi = match bidirectional {
    Some(b) => b
    None => false
  }
  if bidi {
    let rev_edge = { from_id: to_id, to_id: from_id, distance_meters: dist, weight: w }
    match self.adjacency.get(to_id) {
      Some(arr) => arr.push(rev_edge)
      None => self.adjacency.set(to_id, [rev_edge])
    }
  }
}

///|
/// Snaps a geographical coordinate to the nearest graph node using the spatial grid index.
pub fn RoadNetwork::nearest_node(self : RoadNetwork, target : @coord.Coord) -> (Node, Double)? {
  match self.spatial_index.nearest_neighbor(target) {
    Some((item, dist)) =>
      match self.nodes.get(item.id) {
        Some(node) => Some((node, dist))
        None => None
      }
    None => None
  }
}
