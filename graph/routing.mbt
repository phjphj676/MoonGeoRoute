///|
priv struct PQItem {
  node_id : String
  cost : Double
}

///|
priv struct MinHeap {
  items : Array[PQItem]
}

///|
fn MinHeap::new() -> MinHeap {
  { items: [] }
}

///|
fn MinHeap::is_empty(self : MinHeap) -> Bool {
  self.items.is_empty()
}

///|
fn MinHeap::push(self : MinHeap, item : PQItem) -> Unit {
  self.items.push(item)
  let mut i = self.items.length() - 1
  while i > 0 {
    let parent = (i - 1) / 2
    if self.items[i].cost < self.items[parent].cost {
      let tmp = self.items[i]
      self.items[i] = self.items[parent]
      self.items[parent] = tmp
      i = parent
    } else {
      break
    }
  }
}

///|
fn MinHeap::pop(self : MinHeap) -> PQItem? {
  if self.items.is_empty() {
    return None
  }
  let top = self.items[0]
  let last_idx = self.items.length() - 1
  self.items[0] = self.items[last_idx]
  let _ = self.items.pop()
  if !self.items.is_empty() {
    let mut i = 0
    while true {
      let left = 2 * i + 1
      let right = 2 * i + 2
      let mut smallest = i
      if left < self.items.length() && self.items[left].cost < self.items[smallest].cost {
        smallest = left
      }
      if right < self.items.length() && self.items[right].cost < self.items[smallest].cost {
        smallest = right
      }
      if smallest != i {
        let tmp = self.items[i]
        self.items[i] = self.items[smallest]
        self.items[smallest] = tmp
        i = smallest
      } else {
        break
      }
    }
  }
  Some(top)
}

///|
/// Computes shortest path using Dijkstra's algorithm from `start_id` to `end_id`. Returns path nodes and total weight.
pub fn RoadNetwork::dijkstra(self : RoadNetwork, start_id : String, end_id : String) -> (Array[Node], Double)? {
  if self.nodes.get(start_id) is None || self.nodes.get(end_id) is None {
    return None
  }

  let dist : Map[String, Double] = {}
  let prev : Map[String, String] = {}
  let heap = MinHeap::new()

  dist.set(start_id, 0.0)
  heap.push({ node_id: start_id, cost: 0.0 })

  while !heap.is_empty() {
    let top = match heap.pop() {
      Some(item) => item
      None => break
    }
    let u = top.node_id
    if u == end_id {
      break
    }
    let current_dist = match dist.get(u) {
      Some(d) => d
      None => 1.0e18
    }
    if top.cost > current_dist {
      continue
    }
    match self.adjacency.get(u) {
      Some(edges) =>
        for edge in edges {
          let v = edge.to_id
          let alt = current_dist + edge.weight
          let v_dist = match dist.get(v) {
            Some(d) => d
            None => 1.0e18
          }
          if alt < v_dist {
            dist.set(v, alt)
            prev.set(v, u)
            heap.push({ node_id: v, cost: alt })
          }
        }
      None => ()
    }
  }

  match dist.get(end_id) {
    Some(total_cost) => {
      let path = []
      let mut curr = end_id
      while true {
        match self.nodes.get(curr) {
          Some(node) => path.push(node)
          None => break
        }
        if curr == start_id {
          break
        }
        match prev.get(curr) {
          Some(p) => curr = p
          None => return None
        }
      }
      // Reverse path from start to end
      let rev_path = []
      for i in 0..<path.length() {
        rev_path.push(path[path.length() - 1 - i])
      }
      Some((rev_path, total_cost))
    }
    None => None
  }
}

///|
/// Computes shortest path using A* search from `start_id` to `end_id` guided by Haversine distance heuristics.
pub fn RoadNetwork::a_star(self : RoadNetwork, start_id : String, end_id : String) -> (Array[Node], Double)? {
  let end_node = match self.nodes.get(end_id) {
    Some(n) => n
    None => return None
  }
  if self.nodes.get(start_id) is None {
    return None
  }

  let dist : Map[String, Double] = {}
  let prev : Map[String, String] = {}
  let heap = MinHeap::new()

  dist.set(start_id, 0.0)
  heap.push({ node_id: start_id, cost: 0.0 })

  while !heap.is_empty() {
    let top = match heap.pop() {
      Some(item) => item
      None => break
    }
    let u = top.node_id
    if u == end_id {
      break
    }
    let current_dist = match dist.get(u) {
      Some(d) => d
      None => 1.0e18
    }
    match self.nodes.get(u) {
      Some(u_node) => {
        let h_u = @geomath.haversine_distance(u_node.coord, end_node.coord)
        if top.cost - h_u > current_dist + 1.0e-7 {
          continue
        }
      }
      None => continue
    }

    match self.adjacency.get(u) {
      Some(edges) =>
        for edge in edges {
          let v = edge.to_id
          let alt = current_dist + edge.weight
          let v_dist = match dist.get(v) {
            Some(d) => d
            None => 1.0e18
          }
          if alt < v_dist {
            dist.set(v, alt)
            prev.set(v, u)
            match self.nodes.get(v) {
              Some(v_node) => {
                let h = @geomath.haversine_distance(v_node.coord, end_node.coord)
                heap.push({ node_id: v, cost: alt + h })
              }
              None => ()
            }
          }
        }
      None => ()
    }
  }

  match dist.get(end_id) {
    Some(total_cost) => {
      let path = []
      let mut curr = end_id
      while true {
        match self.nodes.get(curr) {
          Some(node) => path.push(node)
          None => break
        }
        if curr == start_id {
          break
        }
        match prev.get(curr) {
          Some(p) => curr = p
          None => return None
        }
      }
      let rev_path = []
      for i in 0..<path.length() {
        rev_path.push(path[path.length() - 1 - i])
      }
      Some((rev_path, total_cost))
    }
    None => None
  }
}

///|
/// Finds optimal path between arbitrary coordinates `start_coord` and `end_coord` by snapping to nearest road nodes.
pub fn RoadNetwork::find_path_by_coords(
  self : RoadNetwork,
  start_coord : @coord.Coord,
  end_coord : @coord.Coord
) -> (Array[Node], Double)? {
  let start_node = match self.nearest_node(start_coord) {
    Some((node, _)) => node
    None => return None
  }
  let end_node = match self.nearest_node(end_coord) {
    Some((node, _)) => node
    None => return None
  }
  self.a_star(start_node.id, end_node.id)
}
