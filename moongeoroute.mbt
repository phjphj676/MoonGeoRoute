///|
/// A point on the fixed-point route grid.
pub fn point(x : Int, y : Int) -> (Int, Int) {
  (x, y)
}

///|
/// A bounding box represented as `(min_x, min_y, max_x, max_y)`.
pub fn bbox(
  min_x : Int,
  min_y : Int,
  max_x : Int,
  max_y : Int,
) -> (Int, Int, Int, Int) {
  (min_x, min_y, max_x, max_y)
}

///|
pub fn bbox_contains(area : (Int, Int, Int, Int), p : (Int, Int)) -> Bool {
  p.0 >= area.0 && p.0 <= area.2 && p.1 >= area.1 && p.1 <= area.3
}

///|
pub fn bbox_union(
  a : (Int, Int, Int, Int),
  b : (Int, Int, Int, Int),
) -> (Int, Int, Int, Int) {
  (
    if a.0 < b.0 {
      a.0
    } else {
      b.0
    },
    if a.1 < b.1 {
      a.1
    } else {
      b.1
    },
    if a.2 > b.2 {
      a.2
    } else {
      b.2
    },
    if a.3 > b.3 {
      a.3
    } else {
      b.3
    },
  )
}

///|
pub fn manhattan_distance(a : (Int, Int), b : (Int, Int)) -> Int {
  let dx = if a.0 >= b.0 { a.0 - b.0 } else { b.0 - a.0 }
  let dy = if a.1 >= b.1 { a.1 - b.1 } else { b.1 - a.1 }
  dx + dy
}

///|
fn route_length_loop(route : Array[(Int, Int)], idx : Int, acc : Int) -> Int {
  if idx >= route.length() {
    acc
  } else {
    route_length_loop(
      route,
      idx + 1,
      acc + manhattan_distance(route[idx - 1], route[idx]),
    )
  }
}

///|
fn contains_point_loop(
  points : Array[(Int, Int)],
  target : (Int, Int),
  idx : Int,
) -> Bool {
  if idx >= points.length() {
    false
  } else if points[idx] == target {
    true
  } else {
    contains_point_loop(points, target, idx + 1)
  }
}

///|
fn route_is_clear_loop(
  route : Array[(Int, Int)],
  blocked : Array[(Int, Int)],
  area : (Int, Int, Int, Int),
  idx : Int,
) -> Bool {
  if idx >= route.length() {
    true
  } else {
    let p = route[idx]
    bbox_contains(area, p) &&
    !contains_point_loop(blocked, p, 0) &&
    route_is_clear_loop(route, blocked, area, idx + 1)
  }
}

///|
fn append_line(
  route : Array[(Int, Int)],
  from : (Int, Int),
  to : (Int, Int),
  include_first : Bool,
) -> Unit {
  if include_first {
    route.push(from)
  }
  if from == to {
    ()
  } else if from.0 != to.0 {
    let step = if from.0 < to.0 { 1 } else { -1 }
    append_line(route, (from.0 + step, from.1), to, true)
  } else {
    let step = if from.1 < to.1 { 1 } else { -1 }
    append_line(route, (from.0, from.1 + step), to, true)
  }
}

///|
fn build_polyline_loop(
  route : Array[(Int, Int)],
  waypoints : Array[(Int, Int)],
  idx : Int,
) -> Array[(Int, Int)] {
  if idx >= waypoints.length() {
    route
  } else {
    append_line(route, waypoints[idx - 1], waypoints[idx], false)
    build_polyline_loop(route, waypoints, idx + 1)
  }
}

///|
fn route_bounds_loop(
  route : Array[(Int, Int)],
  idx : Int,
  current : (Int, Int, Int, Int),
) -> (Int, Int, Int, Int) {
  if idx >= route.length() {
    current
  } else {
    let p = route[idx]
    route_bounds_loop(
      route,
      idx + 1,
      (
        if p.0 < current.0 {
          p.0
        } else {
          current.0
        },
        if p.1 < current.1 {
          p.1
        } else {
          current.1
        },
        if p.0 > current.2 {
          p.0
        } else {
          current.2
        },
        if p.1 > current.3 {
          p.1
        } else {
          current.3
        },
      ),
    )
  }
}

///|
pub fn route_length(route : Array[(Int, Int)]) -> Int {
  if route.length() < 2 {
    0
  } else {
    route_length_loop(route, 1, 0)
  }
}

///|
pub fn route_is_clear(
  route : Array[(Int, Int)],
  blocked : Array[(Int, Int)],
  area : (Int, Int, Int, Int),
) -> Bool {
  route_is_clear_loop(route, blocked, area, 0)
}

///|
fn build_polyline(waypoints : Array[(Int, Int)]) -> Array[(Int, Int)] {
  let route = []
  if waypoints.length() == 0 {
    route
  } else {
    route.push(waypoints[0])
    build_polyline_loop(route, waypoints, 1)
  }
}

///|
fn try_route(
  waypoints : Array[(Int, Int)],
  blocked : Array[(Int, Int)],
  area : (Int, Int, Int, Int),
) -> Array[(Int, Int)]? {
  let route = build_polyline(waypoints)
  if route_is_clear(route, blocked, area) {
    Some(route)
  } else {
    None
  }
}

///|
pub fn route_bounds(route : Array[(Int, Int)]) -> (Int, Int, Int, Int)? {
  if route.length() == 0 {
    None
  } else {
    Some(
      route_bounds_loop(
        route,
        1,
        (route[0].0, route[0].1, route[0].0, route[0].1),
      ),
    )
  }
}

///|
/// Plan a simple grid route by trying the two direct L-shapes first and
/// then detouring around the bounding-box edges.
pub fn plan_route(
  start : (Int, Int),
  goal : (Int, Int),
  blocked : Array[(Int, Int)],
  area : (Int, Int, Int, Int),
) -> Array[(Int, Int)]? {
  let direct_h = try_route([start, (goal.0, start.1), goal], blocked, area)
  match direct_h {
    Some(route) => Some(route)
    None => {
      let direct_v = try_route([start, (start.0, goal.1), goal], blocked, area)
      match direct_v {
        Some(route) => Some(route)
        None => {
          let top = try_route(
            [start, (start.0, area.3), (goal.0, area.3), goal],
            blocked,
            area,
          )
          match top {
            Some(route) => Some(route)
            None => {
              let bottom = try_route(
                [start, (start.0, area.1), (goal.0, area.1), goal],
                blocked,
                area,
              )
              match bottom {
                Some(route) => Some(route)
                None => {
                  let left = try_route(
                    [start, (area.0, start.1), (area.0, goal.1), goal],
                    blocked,
                    area,
                  )
                  match left {
                    Some(route) => Some(route)
                    None =>
                      try_route(
                        [start, (area.2, start.1), (area.2, goal.1), goal],
                        blocked,
                        area,
                      )
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}

///|
pub fn route_preview(route : Array[(Int, Int)]) -> String {
  if route.length() == 0 {
    "empty route"
  } else {
    let bounds = match route_bounds(route) {
      Some(b) => b
      None => bbox(0, 0, 0, 0)
    }
    "route with " +
    route.length().to_string() +
    " points inside " +
    "(" +
    bounds.0.to_string() +
    "," +
    bounds.1.to_string() +
    ")-(" +
    bounds.2.to_string() +
    "," +
    bounds.3.to_string() +
    ")"
  }
}
