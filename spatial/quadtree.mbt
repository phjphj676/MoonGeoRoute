///|
/// A node in the hierarchical QuadTree spatial index.
pub(all) struct QuadTree[T] {
  bbox : @coord.BBox
  capacity : Int
  mut items : Array[SpatialItem[T]]
  mut divided : Bool
  mut nw : QuadTree[T]?
  mut ne : QuadTree[T]?
  mut sw : QuadTree[T]?
  mut se : QuadTree[T]?
}

///|
/// Creates a new QuadTree covering the specified `bbox` with bucket capacity (default 10 items before splitting).
pub fn[T] QuadTree::new(bbox : @coord.BBox, capacity? : Int) -> QuadTree[T] {
  let cap = match capacity {
    Some(c) => if c < 1 { 1 } else { c }
    None => 10
  }
  {
    bbox,
    capacity: cap,
    items: [],
    divided: false,
    nw: None,
    ne: None,
    sw: None,
    se: None,
  }
}

///|
/// Subdivides the QuadTree node into 4 child quadrants (NW, NE, SW, SE).
fn[T] QuadTree::subdivide(self : QuadTree[T]) -> Unit {
  let mid_lat = (self.bbox.min_lat + self.bbox.max_lat) / 2.0
  let mid_lon = (self.bbox.min_lon + self.bbox.max_lon) / 2.0

  let nw_box = @coord.BBox::new(mid_lat, self.bbox.min_lon, self.bbox.max_lat, mid_lon)
  let ne_box = @coord.BBox::new(mid_lat, mid_lon, self.bbox.max_lat, self.bbox.max_lon)
  let sw_box = @coord.BBox::new(self.bbox.min_lat, self.bbox.min_lon, mid_lat, mid_lon)
  let se_box = @coord.BBox::new(self.bbox.min_lat, mid_lon, mid_lat, self.bbox.max_lon)

  self.nw = Some(QuadTree::new(nw_box, capacity=self.capacity))
  self.ne = Some(QuadTree::new(ne_box, capacity=self.capacity))
  self.sw = Some(QuadTree::new(sw_box, capacity=self.capacity))
  self.se = Some(QuadTree::new(se_box, capacity=self.capacity))
  self.divided = true
}

///|
/// Helper to try inserting an item into an optional child QuadTree.
fn[T] insert_into_child(child : QuadTree[T]?, item : SpatialItem[T]) -> Bool {
  match child {
    Some(c) => c.insert(item)
    None => false
  }
}

///|
/// Inserts a spatial item into the QuadTree. Returns `true` if inserted, `false` if out of bounds.
pub fn[T] QuadTree::insert(self : QuadTree[T], item : SpatialItem[T]) -> Bool {
  if !self.bbox.contains(item.coord) {
    return false
  }
  if !self.divided && self.items.length() < self.capacity {
    self.items.push(item)
    return true
  }
  if !self.divided {
    self.subdivide()
    let old_items = self.items
    self.items = []
    for old in old_items {
      let ok = insert_into_child(self.nw, old) ||
        insert_into_child(self.ne, old) ||
        insert_into_child(self.sw, old) ||
        insert_into_child(self.se, old)
      if !ok {
        self.items.push(old)
      }
    }
  }
  let ok = insert_into_child(self.nw, item) ||
    insert_into_child(self.ne, item) ||
    insert_into_child(self.sw, item) ||
    insert_into_child(self.se, item)
  if !ok {
    self.items.push(item)
  }
  true
}

///|
/// Queries all items inside a query bounding box (`bbox`).
pub fn[T] QuadTree::query(self : QuadTree[T], query_box : @coord.BBox) -> Array[SpatialItem[T]] {
  let result = []
  if !self.bbox.intersects(query_box) {
    return result
  }
  for item in self.items {
    if query_box.contains(item.coord) {
      result.push(item)
    }
  }
  if self.divided {
    match self.nw {
      Some(child) => {
        let child_res = child.query(query_box)
        for x in child_res { result.push(x) }
      }
      None => ()
    }
    match self.ne {
      Some(child) => {
        let child_res = child.query(query_box)
        for x in child_res { result.push(x) }
      }
      None => ()
    }
    match self.sw {
      Some(child) => {
        let child_res = child.query(query_box)
        for x in child_res { result.push(x) }
      }
      None => ()
    }
    match self.se {
      Some(child) => {
        let child_res = child.query(query_box)
        for x in child_res { result.push(x) }
      }
      None => ()
    }
  }
  result
}
