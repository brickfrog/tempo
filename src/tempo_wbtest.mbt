// Whitebox tests run within the package scope.
// Use them to validate internal helpers or invariants.

///|
test "civil_from_days roundtrip" {
  // Edge dates: epoch, year 1, year -1, far future, leap day
  let cases : Array[(Int, Int, Int)] = [
    (1970, 1, 1),
    (1, 1, 1),
    (-1, 12, 31),
    (9999, 12, 31),
    (2000, 2, 29),
    (0, 3, 1),
  ]
  for i = 0; i < cases.length(); i = i + 1 {
    let (y, m, d) = cases[i]
    let days = days_from_civil(y, m, d)
    let (y2, m2, d2) = civil_from_days(days)
    assert_eq((y2, m2, d2), (y, m, d))
  }
}

///|
test "floor_div64 negative dividend" {
  // -7 / 2 should be -4 (floor), not -3 (truncate)
  assert_eq(floor_div64(-7L, 2L), -4L)
}

///|
test "floor_div64 exact division" {
  assert_eq(floor_div64(-6L, 2L), -3L)
  assert_eq(floor_div64(6L, 2L), 3L)
}

///|
test "floor_div64 large values" {
  assert_eq(floor_div64(1_000_000_000_000L, 86400L), 11574074L)
}

///|
test "floor_mod64" {
  assert_eq(floor_mod64(-1L, 7L), 6L)
  assert_eq(floor_mod64(0L, 7L), 0L)
  assert_eq(floor_mod64(7L, 7L), 0L)
}
