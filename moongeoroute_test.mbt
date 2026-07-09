///|
test "bbox contains points" {
  let area = @moongeoroute.bbox(0, 0, 5, 5)
  assert_true(@moongeoroute.bbox_contains(area, @moongeoroute.point(2, 3)))
  assert_true(!@moongeoroute.bbox_contains(area, @moongeoroute.point(6, 3)))
}

///|
test "route length counts grid steps" {
  let route = [
    @moongeoroute.point(0, 0),
    @moongeoroute.point(2, 0),
    @moongeoroute.point(2, 3),
  ]
  assert_eq(@moongeoroute.route_length(route), 5)
}

///|
test "plan route prefers the direct l-shape" {
  let area = @moongeoroute.bbox(0, 0, 4, 4)
  let route = match
    @moongeoroute.plan_route(
      @moongeoroute.point(0, 0),
      @moongeoroute.point(3, 2),
      [],
      area,
    ) {
    Some(route) => route
    None => fail("expected a route")
  }
  assert_eq(@moongeoroute.route_length(route), 5)
  assert_eq(
    @moongeoroute.route_preview(route),
    "route with 6 points inside (0,0)-(3,2)",
  )
}

///|
test "plan route reroutes around a blocked corner" {
  let area = @moongeoroute.bbox(0, 0, 4, 4)
  let blocked = [@moongeoroute.point(1, 0)]
  let route = match
    @moongeoroute.plan_route(
      @moongeoroute.point(0, 0),
      @moongeoroute.point(2, 2),
      blocked,
      area,
    ) {
    Some(route) => route
    None => fail("expected a detour")
  }
  assert_true(@moongeoroute.route_length(route) >= 4)
  assert_true(@moongeoroute.route_is_clear(route, blocked, area))
}
