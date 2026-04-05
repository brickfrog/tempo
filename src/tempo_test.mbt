// Blackbox tests for brickfrog/tempo public API.

///|
test "Date::new valid" {
  let d = @tempo.Date::new(2024, 3, 15)
  assert_eq(d.year, 2024)
  assert_eq(d.month, 3)
  assert_eq(d.day, 15)
}

///|
test "Date::new leap day" {
  let d = @tempo.Date::new(2000, 2, 29)
  assert_eq(d.day, 29)
}

///|
test "Date::new non-leap day 28 ok" {
  let d = @tempo.Date::new(2001, 2, 28)
  assert_eq(d.day, 28)
}

///|
test "Date::new invalid month" {
  assert_true((try? @tempo.Date::new(2024, 13, 1)) is Err(_))
}

///|
test "Date::new invalid day" {
  assert_true((try? @tempo.Date::new(2024, 2, 30)) is Err(_))
}

///|
test "Date::new non-leap Feb 29 invalid" {
  assert_true((try? @tempo.Date::new(2001, 2, 29)) is Err(_))
}

///|
test "Date::add_days forward" {
  let d = @tempo.Date::new(2024, 3, 15)
  let d2 = d.add_days(10)
  assert_eq(d2.year, 2024)
  assert_eq(d2.month, 3)
  assert_eq(d2.day, 25)
}

///|
test "Date::add_days backward" {
  let d = @tempo.Date::new(2024, 3, 15)
  let d2 = d.add_days(-14)
  assert_eq(d2.month, 3)
  assert_eq(d2.day, 1)
}

///|
test "Date::add_days crosses month" {
  let d = @tempo.Date::new(2024, 1, 31)
  let d2 = d.add_days(1)
  assert_eq(d2.month, 2)
  assert_eq(d2.day, 1)
}

///|
test "Date::add_days leap day" {
  let d = @tempo.Date::new(2024, 2, 28)
  let d2 = d.add_days(1)
  assert_eq(d2.month, 2)
  assert_eq(d2.day, 29)
}

///|
test "Date::day_of_week ISO" {
  // 1970-01-01 Thursday; 2024-01-01 Monday; 2024-03-15 Friday
  assert_eq(@tempo.Date::new(1970, 1, 1).day_of_week(), 4)
  assert_eq(@tempo.Date::new(2024, 1, 1).day_of_week(), 1)
  assert_eq(@tempo.Date::new(2024, 3, 15).day_of_week(), 5)
  assert_eq(@tempo.Date::new(2024, 3, 17).day_of_week(), 7)
}

///|
test "Date::day_of_year" {
  assert_eq(@tempo.Date::new(2024, 1, 1).day_of_year(), 1)
  assert_eq(@tempo.Date::new(2024, 3, 15).day_of_year(), 75)
  assert_eq(@tempo.Date::new(2023, 12, 31).day_of_year(), 365)
  assert_eq(@tempo.Date::new(2024, 12, 31).day_of_year(), 366)
}

///|
test "Date::days_until" {
  let a = @tempo.Date::new(2024, 3, 1)
  let b = @tempo.Date::new(2024, 3, 15)
  assert_eq(a.days_until(b), 14)
  assert_eq(b.days_until(a), -14)
  assert_eq(a.days_until(a), 0)
}

///|
test "Date::parse valid" {
  let d = @tempo.Date::parse("2024-03-15")
  assert_eq(d.year, 2024)
  assert_eq(d.month, 3)
  assert_eq(d.day, 15)
}

///|
test "Date::format" {
  let d = @tempo.Date::new(2024, 3, 5)
  assert_eq(d.format(), "2024-03-05")
}

///|
test "Date::parse roundtrip" {
  let s = "2000-02-29"
  let d = @tempo.Date::parse(s)
  assert_eq(d.format(), s)
}

///|
test "Date::parse invalid month" {
  assert_true((try? @tempo.Date::parse("2024-13-01")) is Err(_))
}

///|
test "Date::parse trailing junk" {
  assert_true((try? @tempo.Date::parse("2024-01-01Z")) is Err(_))
}

///|
test "Time::new valid" {
  let t = @tempo.Time::new(23, 59, 59, 999_999_999)
  assert_eq(t.hour, 23)
  assert_eq(t.minute, 59)
  assert_eq(t.second, 59)
  assert_eq(t.nanosecond, 999_999_999)
}

///|
test "Time::new invalid hour" {
  assert_true((try? @tempo.Time::new(24, 0, 0, 0)) is Err(_))
}

///|
test "is_leap_year" {
  assert_eq(@tempo.is_leap_year(2000), true)
  assert_eq(@tempo.is_leap_year(1900), false)
  assert_eq(@tempo.is_leap_year(2024), true)
  assert_eq(@tempo.is_leap_year(2023), false)
}

///|
test "days_in_month" {
  assert_eq(@tempo.days_in_month(2024, 2), 29)
  assert_eq(@tempo.days_in_month(2023, 2), 28)
  assert_eq(@tempo.days_in_month(2024, 1), 31)
  assert_eq(@tempo.days_in_month(2024, 4), 30)
}

///|
test "DateTime::epoch" {
  let e = @tempo.DateTime::epoch()
  assert_eq(e.date.year, 1970)
  assert_eq(e.date.month, 1)
  assert_eq(e.date.day, 1)
  assert_eq(e.time.hour, 0)
  assert_eq(e.time.nanosecond, 0)
}

///|
test "from_unix_seconds epoch" {
  let dt = @tempo.DateTime::from_unix_seconds(0L)
  assert_eq(dt.date.year, 1970)
  assert_eq(dt.date.month, 1)
  assert_eq(dt.date.day, 1)
  assert_eq(dt.time.hour, 0)
  assert_eq(dt.time.minute, 0)
  assert_eq(dt.time.second, 0)
}

///|
test "from_unix_seconds known date" {
  // 2024-03-15T12:34:56Z
  // python: datetime(2024,3,15,12,34,56,tzinfo=timezone.utc).timestamp() = 1710506096
  let dt = @tempo.DateTime::from_unix_seconds(1710506096L)
  assert_eq(dt.date.year, 2024)
  assert_eq(dt.date.month, 3)
  assert_eq(dt.date.day, 15)
  assert_eq(dt.time.hour, 12)
  assert_eq(dt.time.minute, 34)
  assert_eq(dt.time.second, 56)
}

///|
test "to_unix_seconds epoch" {
  let dt = @tempo.DateTime::epoch()
  assert_eq(dt.to_unix_seconds(), 0L)
}

///|
test "to_unix_seconds roundtrip" {
  let ts = 1710506096L
  let dt = @tempo.DateTime::from_unix_seconds(ts)
  assert_eq(dt.to_unix_seconds(), ts)
}

///|
test "from_unix_seconds pre-epoch" {
  // 1969-12-31T23:59:59Z = -1
  let dt = @tempo.DateTime::from_unix_seconds(-1L)
  assert_eq(dt.date.year, 1969)
  assert_eq(dt.date.month, 12)
  assert_eq(dt.date.day, 31)
  assert_eq(dt.time.hour, 23)
  assert_eq(dt.time.minute, 59)
  assert_eq(dt.time.second, 59)
}

///|
test "from_unix_nanos with sub-second" {
  let ns = 1710506096_000_000_001L
  let dt = @tempo.DateTime::from_unix_nanos(ns)
  assert_eq(dt.date.year, 2024)
  assert_eq(dt.time.second, 56)
  assert_eq(dt.time.nanosecond, 1)
}

///|
test "to_unix_nanos roundtrip" {
  let ns = 1710506096_123_456_789L
  let dt = @tempo.DateTime::from_unix_nanos(ns)
  assert_eq(dt.to_unix_nanos(), ns)
}

///|
test "DateTime::format no sub-second" {
  let dt = @tempo.DateTime::from_unix_seconds(0L)
  assert_eq(dt.format(), "1970-01-01T00:00:00Z")
}

///|
test "DateTime::format known date" {
  let dt = @tempo.DateTime::from_unix_seconds(1710506096L)
  assert_eq(dt.format(), "2024-03-15T12:34:56Z")
}

///|
test "DateTime::format with nanoseconds" {
  let dt = @tempo.DateTime::from_unix_nanos(1710506096_100_000_000L)
  assert_eq(dt.format(), "2024-03-15T12:34:56.1Z")
}

///|
test "DateTime::format nanosecond precision" {
  let dt = @tempo.DateTime::from_unix_nanos(1710506096_123_456_789L)
  assert_eq(dt.format(), "2024-03-15T12:34:56.123456789Z")
}

///|
test "DateTime::format negative year" {
  let d = @tempo.Date::new(-500, 6, 15)
  let t = @tempo.Time::new(12, 0, 0, 0)
  let dt = @tempo.DateTime::new(d, t)
  assert_eq(dt.format(), "-0500-06-15T12:00:00Z")
}

///|
test "DateTime::format negative year -0001" {
  let d = @tempo.Date::new(-1, 1, 1)
  let t = @tempo.Time::new(0, 0, 0, 0)
  let dt = @tempo.DateTime::new(d, t)
  assert_eq(dt.format(), "-0001-01-01T00:00:00Z")
}

///|
test "Time::format no sub-second" {
  let t = @tempo.Time::new(0, 0, 0, 0)
  assert_eq(t.format(), "00:00:00")
}

///|
test "Time::format with nanoseconds trimmed" {
  let t = @tempo.Time::new(12, 34, 56, 100_000_000)
  assert_eq(t.format(), "12:34:56.1")
}

///|
test "Time::format nanosecond precision" {
  let t = @tempo.Time::new(12, 34, 56, 123_456_789)
  assert_eq(t.format(), "12:34:56.123456789")
}

///|
test "Time::parse basic" {
  let t = @tempo.Time::parse("12:34:56")
  assert_eq(t.hour, 12)
  assert_eq(t.minute, 34)
  assert_eq(t.second, 56)
  assert_eq(t.nanosecond, 0)
}

///|
test "Time::parse midnight" {
  let t = @tempo.Time::parse("00:00:00")
  assert_eq(t.hour, 0)
  assert_eq(t.nanosecond, 0)
}

///|
test "Time::parse with fractional seconds" {
  let t = @tempo.Time::parse("12:34:56.123456789")
  assert_eq(t.nanosecond, 123_456_789)
}

///|
test "Time::parse fractional seconds trimmed" {
  let t = @tempo.Time::parse("12:34:56.1")
  assert_eq(t.nanosecond, 100_000_000)
}

///|
test "Time::parse fractional seconds >9 digits truncated" {
  let t = @tempo.Time::parse("12:34:56.123456789999")
  assert_eq(t.nanosecond, 123_456_789)
}

///|
test "Time::parse invalid hour" {
  assert_true((try? @tempo.Time::parse("24:00:00")) is Err(_))
}

///|
test "Time::parse invalid format" {
  assert_true((try? @tempo.Time::parse("not-a-time")) is Err(_))
}

///|
test "Time::parse unexpected trailing" {
  assert_true((try? @tempo.Time::parse("12:34:56Z")) is Err(_))
}

///|
test "Time::parse roundtrip" {
  let s = "12:34:56.123456789"
  let t = @tempo.Time::parse(s)
  assert_eq(t.format(), s)
}

///|
test "DateTime::parse basic" {
  let dt = @tempo.DateTime::parse("1970-01-01T00:00:00Z")
  assert_eq(dt.to_unix_seconds(), 0L)
}

///|
test "DateTime::parse known date" {
  let dt = @tempo.DateTime::parse("2024-03-15T12:34:56Z")
  assert_eq(dt.to_unix_seconds(), 1710506096L)
}

///|
test "DateTime::parse lowercase t" {
  let dt = @tempo.DateTime::parse("2024-03-15t12:34:56Z")
  assert_eq(dt.to_unix_seconds(), 1710506096L)
}

///|
test "DateTime::parse with fractional seconds" {
  let dt = @tempo.DateTime::parse("2024-03-15T12:34:56.123456789Z")
  assert_eq(dt.time.nanosecond, 123_456_789)
}

///|
test "DateTime::parse fractional seconds trimmed" {
  let dt = @tempo.DateTime::parse("2024-03-15T12:34:56.1Z")
  assert_eq(dt.time.nanosecond, 100_000_000)
}

///|
test "DateTime::parse fractional seconds >9 digits truncated" {
  // 12 digits: first 9 significant, rest discarded without overflow
  let dt = @tempo.DateTime::parse("2024-03-15T12:34:56.123456789999Z")
  assert_eq(dt.time.nanosecond, 123_456_789)
}

///|
test "DateTime::parse fractional seconds all nines overflow safe" {
  let dt = @tempo.DateTime::parse("2024-03-15T12:34:56.99999999999Z")
  assert_eq(dt.time.nanosecond, 999_999_999)
}

///|
test "DateTime::parse +00:00 offset" {
  let dt = @tempo.DateTime::parse("2024-03-15T12:34:56+00:00")
  assert_eq(dt.to_unix_seconds(), 1710506096L)
}

///|
test "DateTime::parse -00:00 offset" {
  let dt = @tempo.DateTime::parse("2024-03-15T12:34:56-00:00")
  assert_eq(dt.to_unix_seconds(), 1710506096L)
}

///|
test "DateTime::parse non-UTC offset rejected" {
  assert_true((try? @tempo.DateTime::parse("2024-03-15T12:34:56+05:30")) is Err(_))
}

///|
test "DateTime::parse invalid format" {
  assert_true((try? @tempo.DateTime::parse("not-a-date")) is Err(_))
}

///|
test "DateTime::parse roundtrip" {
  let s = "2024-03-15T12:34:56.123456789Z"
  let dt = @tempo.DateTime::parse(s)
  assert_eq(dt.format(), s)
}

///|
test "Duration::days" {
  let d = @tempo.Duration::days(1L)
  assert_eq(d.as_seconds(), 86_400L)
  assert_eq(d.as_hours(), 24L)
}

///|
test "Duration::weeks" {
  let w = @tempo.Duration::weeks(2L)
  assert_eq(w.as_nanoseconds(), 2L * 7L * 86_400L * 1_000_000_000L)
  assert_eq(w.as_seconds(), 2L * 7L * 86_400L)
  assert_eq(w.as_weeks(), 2L)
}

///|
test "Duration::as_weeks" {
  assert_eq(@tempo.Duration::days(14L).as_weeks(), 2L)
  assert_eq(@tempo.Duration::days(13L).as_weeks(), 1L)
  assert_eq(@tempo.Duration::days(1L).as_weeks(), 0L)
}

///|
test "Duration::days arithmetic" {
  let dt = @tempo.DateTime::parse("2024-01-31T00:00:00Z")
  let dt2 = dt.add(@tempo.Duration::days(1L))
  assert_eq(dt2.date.month, 2)
  assert_eq(dt2.date.day, 1)
}

///|
test "DateTime::now is after epoch" {
  assert_eq(@tempo.DateTime::now() > @tempo.DateTime::epoch(), true)
}

///|
test "Duration::seconds" {
  let d = @tempo.Duration::seconds(90L)
  assert_eq(d.as_seconds(), 90L)
  assert_eq(d.as_minutes(), 1L)
  assert_eq(d.as_nanoseconds(), 90_000_000_000L)
}

///|
test "Duration::minutes" {
  let d = @tempo.Duration::minutes(2L)
  assert_eq(d.as_seconds(), 120L)
}

///|
test "Duration::hours" {
  let d = @tempo.Duration::hours(1L)
  assert_eq(d.as_minutes(), 60L)
}

///|
test "Duration op_add" {
  let a = @tempo.Duration::seconds(30L)
  let b = @tempo.Duration::seconds(30L)
  let c = a + b
  assert_eq(c.as_seconds(), 60L)
}

///|
test "Duration op_sub" {
  let a = @tempo.Duration::seconds(60L)
  let b = @tempo.Duration::seconds(10L)
  let c = a - b
  assert_eq(c.as_seconds(), 50L)
}

///|
test "Duration op_neg" {
  let d = @tempo.Duration::seconds(5L)
  let neg = -d
  assert_eq(neg.as_nanoseconds(), -5_000_000_000L)
}

///|
test "Duration compare" {
  let a = @tempo.Duration::seconds(1L)
  let b = @tempo.Duration::seconds(2L)
  assert_eq(a < b, true)
  assert_eq(b > a, true)
  assert_eq(a == a, true)
}

///|
test "DateTime::add" {
  let dt = @tempo.DateTime::from_unix_seconds(0L)
  let dt2 = dt.add(@tempo.Duration::hours(1L))
  assert_eq(dt2.time.hour, 1)
  assert_eq(dt2.to_unix_seconds(), 3600L)
}

///|
test "DateTime::sub" {
  let dt = @tempo.DateTime::from_unix_seconds(3600L)
  let dt2 = dt.sub(@tempo.Duration::hours(1L))
  assert_eq(dt2.to_unix_seconds(), 0L)
}

///|
test "DateTime::diff" {
  let a = @tempo.DateTime::from_unix_seconds(0L)
  let b = @tempo.DateTime::from_unix_seconds(3600L)
  let d = b.diff(a)
  assert_eq(d.as_hours(), 1L)
}

///|
test "DateTime::diff negative" {
  let a = @tempo.DateTime::from_unix_seconds(3600L)
  let b = @tempo.DateTime::from_unix_seconds(0L)
  let d = b.diff(a)
  assert_eq(d.as_nanoseconds(), -3_600_000_000_000L)
}

///|
test "DateTime::add crosses day boundary" {
  let dt = @tempo.DateTime::parse("2024-03-15T23:00:00Z")
  let dt2 = dt.add(@tempo.Duration::hours(2L))
  assert_eq(dt2.date.day, 16)
  assert_eq(dt2.time.hour, 1)
}

///|
test "DateTime::add crosses month boundary" {
  let dt = @tempo.DateTime::parse("2024-01-31T12:00:00Z")
  let dt2 = dt.add(@tempo.Duration::hours(24L))
  assert_eq(dt2.date.month, 2)
  assert_eq(dt2.date.day, 1)
}

///|
test "DateTime compare" {
  let a = @tempo.DateTime::from_unix_seconds(0L)
  let b = @tempo.DateTime::from_unix_seconds(1L)
  assert_eq(a < b, true)
  assert_eq(b > a, true)
  assert_eq(a == a, true)
}

///|
test "Show Date" {
  let d = @tempo.Date::new(2024, 3, 5)
  inspect(d, content="2024-03-05")
}

///|
test "Show Date negative year" {
  let d = @tempo.Date::new(-500, 6, 15)
  inspect(d, content="-0500-06-15")
}

///|
test "Show Date negative year -0001" {
  let d = @tempo.Date::new(-1, 1, 1)
  inspect(d, content="-0001-01-01")
}

///|
test "Show Time" {
  let t = @tempo.Time::new(9, 5, 3, 0)
  inspect(t, content="09:05:03")
}

///|
test "Show DateTime" {
  let dt = @tempo.DateTime::from_unix_seconds(1710506096L)
  inspect(dt, content="2024-03-15T12:34:56Z")
}

///|
test "Show DateTime negative year" {
  let d = @tempo.Date::new(-500, 6, 15)
  let t = @tempo.Time::new(12, 0, 0, 0)
  let dt = @tempo.DateTime::new(d, t)
  inspect(dt, content="-0500-06-15T12:00:00Z")
}

///|
test "Show Duration zero" {
  let d = @tempo.Duration::seconds(0L)
  inspect(d, content="0s")
}

///|
test "Show Duration seconds" {
  let d = @tempo.Duration::seconds(5L)
  inspect(d, content="5s")
}

///|
test "Show Duration hours minutes seconds" {
  let d = @tempo.Duration::seconds(3661L)
  inspect(d, content="1h1m1s")
}

///|
test "Show Duration negative" {
  let d = -@tempo.Duration::seconds(5L)
  inspect(d, content="-5s")
}

// ─── Duration constructors/accessors (audit 3.1) ─────────────────────────────

///|
test "Duration::nanoseconds" {
  let d = @tempo.Duration::nanoseconds(42L)
  assert_eq(d.as_nanoseconds(), 42L)
}

///|
test "Duration::microseconds" {
  let d = @tempo.Duration::microseconds(100L)
  assert_eq(d.as_nanoseconds(), 100_000L)
  assert_eq(d.as_microseconds(), 100L)
}

///|
test "Duration::milliseconds" {
  let d = @tempo.Duration::milliseconds(5L)
  assert_eq(d.as_nanoseconds(), 5_000_000L)
  assert_eq(d.as_milliseconds(), 5L)
}

// ─── Time::new validation (audit 3.2) ────────────────────────────────────────

///|
test "Time::new invalid minute" {
  assert_true((try? @tempo.Time::new(0, 60, 0, 0)) is Err(_))
}

///|
test "Time::new invalid second" {
  assert_true((try? @tempo.Time::new(0, 0, 60, 0)) is Err(_))
}

///|
test "Time::new invalid nanosecond negative" {
  assert_true((try? @tempo.Time::new(0, 0, 0, -1)) is Err(_))
}

///|
test "Time::new invalid nanosecond upper" {
  assert_true((try? @tempo.Time::new(0, 0, 0, 1_000_000_000)) is Err(_))
}

// ─── Duration Show branches (audit 3.3) ──────────────────────────────────────

///|
test "Show Duration milliseconds" {
  inspect(@tempo.Duration::milliseconds(500L), content="0s500ms")
}

///|
test "Show Duration microseconds" {
  inspect(@tempo.Duration::microseconds(1L), content="0s1µs")
}

///|
test "Show Duration nanoseconds" {
  inspect(@tempo.Duration::nanoseconds(1L), content="0s1ns")
}

///|
test "Show Duration complex" {
  let d = @tempo.Duration::hours(1L) + @tempo.Duration::milliseconds(500L)
  inspect(d, content="1h500ms")
}

///|
test "Show Duration negative complex" {
  let d = -(@tempo.Duration::hours(1L) + @tempo.Duration::milliseconds(500L))
  inspect(d, content="-1h500ms")
}

// ─── Parsing error paths (audit 3.4) ─────────────────────────────────────────

///|
test "DateTime::parse unexpected EOF in digits" {
  assert_true((try? @tempo.DateTime::parse("2024-03-1")) is Err(_))
}

///|
test "DateTime::parse bad separator" {
  assert_true((try? @tempo.DateTime::parse("2024-03-15X12:00:00Z")) is Err(_))
}

///|
test "DateTime::parse dot without fraction" {
  assert_true((try? @tempo.DateTime::parse("2024-03-15T12:00:00.Z")) is Err(_))
}

///|
test "DateTime::parse bad timezone char" {
  assert_true((try? @tempo.DateTime::parse("2024-03-15T12:00:00Q")) is Err(_))
}

///|
test "DateTime::parse trailing after Z" {
  assert_true((try? @tempo.DateTime::parse("2024-03-15T12:00:00Zextra")) is Err(_))
}

// ─── Edge cases (audit 3.5) ──────────────────────────────────────────────────

///|
test "Date::add_days zero is identity" {
  let d = @tempo.Date::new(2024, 6, 15)
  let d2 = d.add_days(0)
  assert_eq(d, d2)
}

///|
test "Date::add_days across year boundary" {
  let d = @tempo.Date::new(2024, 12, 31)
  let d2 = d.add_days(1)
  assert_eq(d2.year, 2025)
  assert_eq(d2.month, 1)
  assert_eq(d2.day, 1)
}

///|
test "days_in_month invalid month" {
  assert_eq(@tempo.days_in_month(2024, 0), 0)
  assert_eq(@tempo.days_in_month(2024, 13), 0)
}

///|
test "DateTime::from_unix_nanos negative" {
  let dt = @tempo.DateTime::from_unix_nanos(-1L)
  assert_eq(dt.date.year, 1969)
  assert_eq(dt.date.month, 12)
  assert_eq(dt.date.day, 31)
  assert_eq(dt.time.hour, 23)
  assert_eq(dt.time.minute, 59)
  assert_eq(dt.time.second, 59)
  assert_eq(dt.time.nanosecond, 999_999_999)
}

///|
test "Show TempoError" {
  let err = @tempo.TempoError("test message")
  inspect(err, content="TempoError: test message")
}
