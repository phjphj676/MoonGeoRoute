///|
pub(all) suberror GeoJsonParseError {
  GeoJsonParseError(String)
} derive(Eq)

///|
/// GeoJSON Feature consisting of an optional ID, properties map, and geometry.
pub(all) struct Feature {
  id : String?
  properties : Map[String, Json]
  geometry : @coord.Geometry
} derive(Debug, Eq)

///|
/// GeoJSON FeatureCollection containing a list of `Feature` objects.
pub(all) struct FeatureCollection {
  features : Array[Feature]
} derive(Debug, Eq)

///|
/// Creates a new `Feature`.
pub fn Feature::new(
  geometry : @coord.Geometry,
  id? : String,
  properties? : Map[String, Json]
) -> Feature {
  let props = match properties {
    Some(m) => m
    None => {}
  }
  { id, properties: props, geometry }
}

///|
/// Creates a new `FeatureCollection`.
pub fn FeatureCollection::new(features : Array[Feature]) -> FeatureCollection {
  { features, }
}

///|
/// Helper to convert `Coord` to `[longitude, latitude]` JSON array per RFC 7946.
fn coord_to_json(c : @coord.Coord) -> Json {
  Json::array([Json::number(c.lon), Json::number(c.lat)])
}

///|
/// Helper to parse `[longitude, latitude]` JSON array into a `Coord`.
fn coord_from_json(json : Json) -> @coord.Coord raise GeoJsonParseError {
  match json {
    Json::Array([Json::Number(lon, ..), Json::Number(lat, ..), ..]) =>
      @coord.Coord::raw(lat, lon)
    _ => raise GeoJsonParseError("Expected [longitude, latitude] coordinate array")
  }
}

///|
/// Serializes a `Geometry` to its GeoJSON representation (`type` and `coordinates`).
pub fn geometry_to_json(geom : @coord.Geometry) -> Json {
  let map : Map[String, Json] = {}
  match geom {
    Point(c) => {
      map.set("type", Json::string("Point"))
      map.set("coordinates", coord_to_json(c))
    }
    MultiPoint(coords) => {
      map.set("type", Json::string("MultiPoint"))
      let arr = []
      for c in coords {
        arr.push(coord_to_json(c))
      }
      map.set("coordinates", Json::array(arr))
    }
    LineString(coords) => {
      map.set("type", Json::string("LineString"))
      let arr = []
      for c in coords {
        arr.push(coord_to_json(c))
      }
      map.set("coordinates", Json::array(arr))
    }
    MultiLineString(lines) => {
      map.set("type", Json::string("MultiLineString"))
      let outer = []
      for line in lines {
        let inner = []
        for c in line {
          inner.push(coord_to_json(c))
        }
        outer.push(Json::array(inner))
      }
      map.set("coordinates", Json::array(outer))
    }
    Polygon(rings) => {
      map.set("type", Json::string("Polygon"))
      let outer = []
      for ring in rings {
        let inner = []
        for c in ring {
          inner.push(coord_to_json(c))
        }
        outer.push(Json::array(inner))
      }
      map.set("coordinates", Json::array(outer))
    }
    MultiPolygon(polys) => {
      map.set("type", Json::string("MultiPolygon"))
      let top = []
      for poly in polys {
        let outer = []
        for ring in poly {
          let inner = []
          for c in ring {
            inner.push(coord_to_json(c))
          }
          outer.push(Json::array(inner))
        }
        top.push(Json::array(outer))
      }
      map.set("coordinates", Json::array(top))
    }
  }
  Json::object(map)
}

///|
/// Parses a GeoJSON `Geometry` object.
pub fn geometry_from_json(json : Json) -> @coord.Geometry raise GeoJsonParseError {
  match json {
    Json::Object(map) => {
      let type_str = match map.get("type") {
        Some(Json::String(s)) => s
        _ => raise GeoJsonParseError("Missing or invalid 'type' field in Geometry")
      }
      let coords_json = match map.get("coordinates") {
        Some(c) => c
        None => raise GeoJsonParseError("Missing 'coordinates' field in Geometry")
      }
      match type_str {
        "Point" => @coord.Geometry::Point(coord_from_json(coords_json))
        "MultiPoint" => match coords_json {
          Json::Array(arr) => {
            let pts = []
            for item in arr {
              pts.push(coord_from_json(item))
            }
            @coord.Geometry::MultiPoint(pts)
          }
          _ => raise GeoJsonParseError("Expected coordinates array for MultiPoint")
        }
        "LineString" => match coords_json {
          Json::Array(arr) => {
            let pts = []
            for item in arr {
              pts.push(coord_from_json(item))
            }
            @coord.Geometry::LineString(pts)
          }
          _ => raise GeoJsonParseError("Expected coordinates array for LineString")
        }
        "MultiLineString" => match coords_json {
          Json::Array(outer) => {
            let lines = []
            for line_json in outer {
              match line_json {
                Json::Array(arr) => {
                  let pts = []
                  for item in arr {
                    pts.push(coord_from_json(item))
                  }
                  lines.push(pts)
                }
                _ => raise GeoJsonParseError("Expected inner array for LineString in MultiLineString")
              }
            }
            @coord.Geometry::MultiLineString(lines)
          }
          _ => raise GeoJsonParseError("Expected outer array for MultiLineString")
        }
        "Polygon" => match coords_json {
          Json::Array(outer) => {
            let rings = []
            for ring_json in outer {
              match ring_json {
                Json::Array(arr) => {
                  let pts = []
                  for item in arr {
                    pts.push(coord_from_json(item))
                  }
                  rings.push(pts)
                }
                _ => raise GeoJsonParseError("Expected inner ring array for Polygon")
              }
            }
            @coord.Geometry::Polygon(rings)
          }
          _ => raise GeoJsonParseError("Expected outer rings array for Polygon")
        }
        _ => raise GeoJsonParseError("Unsupported geometry type: " + type_str)
      }
    }
    _ => raise GeoJsonParseError("Geometry must be a JSON object")
  }
}

///|
/// Serializes a `Feature` to GeoJSON object format.
pub fn Feature::to_json(self : Feature) -> Json {
  let map : Map[String, Json] = {}
  map.set("type", Json::string("Feature"))
  match self.id {
    Some(id_str) => map.set("id", Json::string(id_str))
    None => ()
  }
  map.set("geometry", geometry_to_json(self.geometry))
  map.set("properties", Json::object(self.properties))
  Json::object(map)
}

///|
/// Parses a GeoJSON `Feature` object.
pub fn Feature::from_json_value(json : Json) -> Feature raise GeoJsonParseError {
  match json {
    Json::Object(map) => {
      let type_str = match map.get("type") {
        Some(Json::String(s)) => s
        _ => raise GeoJsonParseError("Feature missing valid 'type'")
      }
      if type_str != "Feature" {
        raise GeoJsonParseError("Expected type 'Feature', got: " + type_str)
      }
      let id = match map.get("id") {
        Some(Json::String(s)) => Some(s)
        Some(Json::Number(n, ..)) => Some(n.to_string())
        _ => None
      }
      let geom = match map.get("geometry") {
        Some(geom_json) => geometry_from_json(geom_json)
        None => raise GeoJsonParseError("Feature missing 'geometry'")
      }
      let props = match map.get("properties") {
        Some(Json::Object(m)) => m
        Some(Json::Null) => {}
        None => {}
        _ => raise GeoJsonParseError("Feature properties must be an object or null")
      }
      { id, properties: props, geometry: geom }
    }
    _ => raise GeoJsonParseError("Feature must be a JSON object")
  }
}

///|
/// Serializes a `FeatureCollection` to GeoJSON format.
pub fn FeatureCollection::to_json(self : FeatureCollection) -> Json {
  let map : Map[String, Json] = {}
  map.set("type", Json::string("FeatureCollection"))
  let arr = []
  for f in self.features {
    arr.push(f.to_json())
  }
  map.set("features", Json::array(arr))
  Json::object(map)
}

///|
/// Parses a GeoJSON `FeatureCollection` object.
pub fn FeatureCollection::from_json_value(json : Json) -> FeatureCollection raise GeoJsonParseError {
  match json {
    Json::Object(map) => {
      let type_str = match map.get("type") {
        Some(Json::String(s)) => s
        _ => raise GeoJsonParseError("FeatureCollection missing valid 'type'")
      }
      if type_str != "FeatureCollection" {
        raise GeoJsonParseError("Expected type 'FeatureCollection', got: " + type_str)
      }
      let features_json = match map.get("features") {
        Some(Json::Array(arr)) => arr
        _ => raise GeoJsonParseError("FeatureCollection missing 'features' array")
      }
      let features = []
      for f_json in features_json {
        features.push(Feature::from_json_value(f_json))
      }
      { features, }
    }
    _ => raise GeoJsonParseError("FeatureCollection must be a JSON object")
  }
}

///|
/// Parses GeoJSON text string directly into a `FeatureCollection`.
pub fn parse_geojson(text : String) -> FeatureCollection raise GeoJsonParseError {
  let json = try {
    @json.parse(text)
  } catch {
    _ => raise GeoJsonParseError("Invalid JSON string format")
  }
  FeatureCollection::from_json_value(json)
}

///|
/// Converts a `FeatureCollection` to pretty string format.
pub fn FeatureCollection::stringify_geojson(self : FeatureCollection, indent? : Int) -> String {
  let ind = match indent {
    Some(n) => n
    None => 2
  }
  self.to_json().stringify(indent=ind)
}
