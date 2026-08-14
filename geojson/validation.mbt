///|
/// Severity of a GeoJSON validation finding.
pub(all) enum ValidationLevel {
  Error
  Warning
} derive(Debug, Eq)

///|
/// A machine-readable validation finding with a stable code and location.
pub(all) struct ValidationIssue {
  level : ValidationLevel
  code : String
  path : String
  message : String
} derive(Debug, Eq)

///|
/// Validation result for a FeatureCollection.
pub(all) struct ValidationReport {
  issues : Array[ValidationIssue]
  feature_count : Int
  vertex_count : Int
} derive(Debug, Eq)

///|
fn add_issue(
  issues : Array[ValidationIssue],
  level : ValidationLevel,
  code : String,
  path : String,
  message : String,
) -> Unit {
  issues.push({ level, code, path, message })
}

///|
fn validate_coordinate(
  coord : @coord.Coord,
  path : String,
  issues : Array[ValidationIssue],
) -> Unit {
  if coord.lat < -90.0 || coord.lat > 90.0 {
    add_issue(
      issues,
      Error,
      "COORD_LATITUDE",
      path,
      "latitude must be within [-90, 90]",
    )
  }
  if coord.lon < -180.0 || coord.lon > 180.0 {
    add_issue(
      issues,
      Error,
      "COORD_LONGITUDE",
      path,
      "longitude must be within [-180, 180]",
    )
  }
}

///|
fn validate_coordinate_array(
  coords : Array[@coord.Coord],
  path : String,
  issues : Array[ValidationIssue],
  minimum : Int,
  require_closed : Bool,
) -> Int {
  if coords.length() < minimum {
    add_issue(
      issues,
      Error,
      "TOO_FEW_COORDINATES",
      path,
      "geometry does not contain enough coordinates",
    )
  }
  for i, coord in coords {
    validate_coordinate(
      coord,
      path + ".coordinates[" + i.to_string() + "]",
      issues,
    )
  }
  if require_closed && coords.length() >= 2 {
    let first = coords[0]
    let last = coords[coords.length() - 1]
    if first.lat != last.lat || first.lon != last.lon {
      add_issue(
        issues,
        Error,
        "RING_NOT_CLOSED",
        path,
        "polygon rings must repeat their first coordinate at the end",
      )
    }
  }
  coords.length()
}

///|
fn validate_geometry_value(
  geometry : @coord.Geometry,
  path : String,
  issues : Array[ValidationIssue],
) -> Int {
  match geometry {
    @coord.Geometry::Point(coord) => {
      validate_coordinate(coord, path + ".coordinates", issues)
      1
    }
    @coord.Geometry::MultiPoint(coords) => {
      for i, coord in coords {
        validate_coordinate(
          coord,
          path + ".coordinates[" + i.to_string() + "]",
          issues,
        )
      }
      coords.length()
    }
    @coord.Geometry::LineString(coords) =>
      validate_coordinate_array(coords, path, issues, 2, false)
    @coord.Geometry::MultiLineString(lines) => {
      let mut count = 0
      for i, line in lines {
        count = count +
          validate_coordinate_array(
            line,
            path + ".coordinates[" + i.to_string() + "]",
            issues,
            2,
            false,
          )
      }
      if lines.is_empty() {
        add_issue(
          issues,
          Warning,
          "EMPTY_MULTILINESTRING",
          path,
          "multi-line geometry contains no lines",
        )
      }
      count
    }
    @coord.Geometry::Polygon(rings) => {
      let mut count = 0
      for i, ring in rings {
        count = count +
          validate_coordinate_array(
            ring,
            path + ".coordinates[" + i.to_string() + "]",
            issues,
            4,
            true,
          )
      }
      if rings.is_empty() {
        add_issue(
          issues,
          Error,
          "EMPTY_POLYGON",
          path,
          "polygon must contain an exterior ring",
        )
      }
      count
    }
    @coord.Geometry::MultiPolygon(polygons) => {
      let mut count = 0
      for polygon_index, polygon in polygons {
        if polygon.is_empty() {
          add_issue(
            issues,
            Error,
            "EMPTY_POLYGON",
            path + ".coordinates[" + polygon_index.to_string() + "]",
            "polygon must contain a ring",
          )
        }
        for ring_index, ring in polygon {
          count = count +
            validate_coordinate_array(
              ring,
              path +
              ".coordinates[" +
              polygon_index.to_string() +
              "].rings[" +
              ring_index.to_string() +
              "]",
              issues,
              4,
              true,
            )
        }
      }
      count
    }
  }
}

///|
fn validate_feature_value(
  feature : Feature,
  index : Int,
  issues : Array[ValidationIssue],
) -> Int {
  let path = "features[" + index.to_string() + "]"
  match feature.id {
    Some(id) =>
      if id.is_empty() {
        add_issue(
          issues,
          Warning,
          "EMPTY_FEATURE_ID",
          path + ".id",
          "feature id is empty",
        )
      }
    None => ()
  }
  validate_geometry_value(feature.geometry, path + ".geometry", issues)
}

///|
/// Validates geometry structure, coordinate ranges, polygon ring closure,
/// and feature metadata without changing the input collection.
pub fn FeatureCollection::validate(
  self : FeatureCollection,
  allow_empty? : Bool = false,
) -> ValidationReport {
  let issues = []
  if self.features.is_empty() && !allow_empty {
    add_issue(
      issues,
      Warning,
      "EMPTY_COLLECTION",
      "features",
      "feature collection contains no features",
    )
  }
  let mut vertex_count = 0
  for index, feature in self.features {
    vertex_count = vertex_count + validate_feature_value(feature, index, issues)
  }
  { issues, feature_count: self.features.length(), vertex_count }
}

///|
pub fn ValidationReport::has_errors(self : ValidationReport) -> Bool {
  for issue in self.issues {
    if issue.level is Error {
      return true
    }
  }
  false
}

///|
pub fn ValidationReport::error_count(self : ValidationReport) -> Int {
  let mut count = 0
  for issue in self.issues {
    if issue.level is Error {
      count = count + 1
    }
  }
  count
}

///|
pub fn ValidationReport::warning_count(self : ValidationReport) -> Int {
  let mut count = 0
  for issue in self.issues {
    if issue.level is Warning {
      count = count + 1
    }
  }
  count
}

///|
/// Returns a stable human-readable summary suitable for CLI diagnostics.
pub fn ValidationReport::summary(self : ValidationReport) -> String {
  let mut result = "features=" +
    self.feature_count.to_string() +
    ", vertices=" +
    self.vertex_count.to_string() +
    ", errors=" +
    self.error_count().to_string() +
    ", warnings=" +
    self.warning_count().to_string()
  for issue in self.issues {
    let level = match issue.level {
      Error => "error"
      Warning => "warning"
    }
    result = result +
      "\n" +
      level +
      " " +
      issue.code +
      " at " +
      issue.path +
      ": " +
      issue.message
  }
  result
}

///|
/// Returns only issues at the requested severity.
pub fn ValidationReport::issues_at(
  self : ValidationReport,
  level : ValidationLevel,
) -> Array[ValidationIssue] {
  let result = []
  for issue in self.issues {
    if issue.level == level {
      result.push(issue)
    }
  }
  result
}
