///|
fn main {
  let area = @moongeoroute.bbox(0, 0, 6, 4)
  let route = match
    @moongeoroute.plan_route(
      @moongeoroute.point(0, 0),
      @moongeoroute.point(4, 3),
      [@moongeoroute.point(2, 0)],
      area,
    ) {
    Some(route) => route
    None => []
  }
  println("MoonGeoRoute demo: " + @moongeoroute.route_preview(route))
}
