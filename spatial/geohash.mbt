///|
let base32_chars : String = "0123456789bcdefghjkmnpqrstuvwxyz"

///|
/// Encodes a `Coord` into a standard Geohash string of length `precision` (between 1 and 12).
pub fn encode_geohash(coord : @coord.Coord, precision : Int) -> String {
  let p = if precision < 1 { 1 } else if precision > 12 { 12 } else { precision }
  let mut min_lat = -90.0
  let mut max_lat = 90.0
  let mut min_lon = -180.0
  let mut max_lon = 180.0
  let mut is_even = true
  let mut bit = 0
  let mut ch = 0
  let mut result = ""

  while result.length() < p {
    if is_even {
      let mid = (min_lon + max_lon) / 2.0
      if coord.lon >= mid {
        ch = ch | (1 << (4 - bit))
        min_lon = mid
      } else {
        max_lon = mid
      }
    } else {
      let mid = (min_lat + max_lat) / 2.0
      if coord.lat >= mid {
        ch = ch | (1 << (4 - bit))
        min_lat = mid
      } else {
        max_lat = mid
      }
    }
    is_even = !is_even
    if bit < 4 {
      bit = bit + 1
    } else {
      let code_unit : UInt16 = base32_chars[ch]
      let c = code_unit.to_int().unsafe_to_char()
      result = result + c.to_string()
      bit = 0
      ch = 0
    }
  }
  result
}

///|
/// Helper to get bit value of char code in base32 alphabet.
fn base32_char_to_val(c : UInt16) -> Int {
  for i in 0..<32 {
    if base32_chars[i] == c {
      return i
    }
  }
  -1
}

///|
/// Decodes a Geohash string to its approximate center `Coord` and its spatial bounding box `BBox`.
pub fn decode_geohash(hash : String) -> (@coord.Coord, @coord.BBox)? {
  if hash.length() == 0 {
    return None
  }
  let mut min_lat = -90.0
  let mut max_lat = 90.0
  let mut min_lon = -180.0
  let mut max_lon = 180.0
  let mut is_even = true

  for i in 0..<hash.length() {
    let c : UInt16 = hash[i]
    let val = base32_char_to_val(c)
    if val < 0 {
      return None
    }
    for bit in 0..<5 {
      let mask = 1 << (4 - bit)
      if is_even {
        let mid = (min_lon + max_lon) / 2.0
        if (val & mask) != 0 {
          min_lon = mid
        } else {
          max_lon = mid
        }
      } else {
        let mid = (min_lat + max_lat) / 2.0
        if (val & mask) != 0 {
          min_lat = mid
        } else {
          max_lat = mid
        }
      }
      is_even = !is_even
    }
  }

  let center_lat = (min_lat + max_lat) / 2.0
  let center_lon = (min_lon + max_lon) / 2.0
  let center = @coord.Coord::raw(center_lat, center_lon)
  let bbox = @coord.BBox::new(min_lat, min_lon, max_lat, max_lon)
  Some((center, bbox))
}
