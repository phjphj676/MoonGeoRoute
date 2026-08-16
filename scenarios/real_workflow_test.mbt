///|
test "real city coverage to route audit workflow" {
  let report = run_city_workflow()
  inspect(report.feature_count, content="5")
  inspect(report.valid_input, content="true")
  inspect(report.northern_count, content="1")
  inspect(report.nearest_city, content="shanghai")
  inspect(report.density_count, content="5")
  inspect(report.route_start, content="shenzhen")
  inspect(report.route_end, content="beijing")
  inspect(report.route_connected, content="true")
  inspect(report.route_node_count >= 3, content="true")
  inspect(report.route_within_limits, content="true")
}
