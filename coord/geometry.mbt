///|
/// Core GIS Geometry Enum supporting OGC / GeoJSON standard geometry types.
pub(all) enum Geometry {
  Point(Coord)
  MultiPoint(Array[Coord])
  LineString(Array[Coord])
  MultiLineString(Array[Array[Coord]])
  Polygon(Array[Array[Coord]])
  MultiPolygon(Array[Array[Array[Coord]]])
} derive(Debug, Eq)

///|
/// Extracts all `Coord` vertices from a `Geometry` as a flat array.
pub fn Geometry::to_coords(self : Geometry) -> Array[Coord] {
  match self {
    Point(c) => [c]
    MultiPoint(arr) => arr
    LineString(arr) => arr
    MultiLineString(lines) => {
      let result = []
      for line in lines {
        for c in line {
          result.push(c)
        }
      }
      result
    }
    Polygon(rings) => {
      let result = []
      for ring in rings {
        for c in ring {
          result.push(c)
        }
      }
      result
    }
    MultiPolygon(polys) => {
      let result = []
      for poly in polys {
        for ring in poly {
          for c in ring {
            result.push(c)
          }
        }
      }
      result
    }
  }
}

///|
/// Computes the bounding box `BBox` of this geometry. Returns `None` if the geometry has no points.
pub fn Geometry::bbox(self : Geometry) -> BBox? {
  BBox::from_coords(self.to_coords())
}

///|
/// Returns the vertex count of this geometry.
pub fn Geometry::vertex_count(self : Geometry) -> Int {
  self.to_coords().length()
}
