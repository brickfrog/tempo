// Blackbox tests for brickfrog/tempo public API.

///|
test "Date::new valid" {
  let d = @src.Date::new(2024, 3, 15)
  assert_eq(d.year, 2024)
  assert_eq(d.month, 3)
  assert_eq(d.day, 15)
}

///|
test "Date::new leap day" {
  let d = @src.Date::new(2000, 2, 29)
  assert_eq(d.day, 29)
}

///|
test "Date::new non-leap day 28 ok" {
  let d = @src.Date::new(2001, 2, 28)
  assert_eq(d.day, 28)
}

///|
test "Date::new invalid month" {
  let result = try {
    @src.Date::new(2024, 13, 1) |> ignore
    "ok"
  } catch {
    @src.TempoError(_) => "error"
  }
  assert_eq(result, "error")
}

///|
test "Date::new invalid day" {
  let result = try {
    @src.Date::new(2024, 2, 30) |> ignore
    "ok"
  } catch {
    @src.TempoError(_) => "error"
  }
  assert_eq(result, "error")
}

///|
test "Date::new non-leap Feb 29 invalid" {
  let result = try {
    @src.Date::new(2001, 2, 29) |> ignore
    "ok"
  } catch {
    @src.TempoError(_) => "error"
  }
  assert_eq(result, "error")
}

///|
test "Time::new valid" {
  let t = @src.Time::new(23, 59, 59, 999_999_999)
  assert_eq(t.hour, 23)
  assert_eq(t.minute, 59)
  assert_eq(t.second, 59)
  assert_eq(t.nanosecond, 999_999_999)
}

///|
test "Time::new invalid hour" {
  let result = try {
    @src.Time::new(24, 0, 0, 0) |> ignore
    "ok"
  } catch {
    @src.TempoError(_) => "error"
  }
  assert_eq(result, "error")
}

///|
test "is_leap_year" {
  assert_eq(@src.is_leap_year(2000), true)
  assert_eq(@src.is_leap_year(1900), false)
  assert_eq(@src.is_leap_year(2024), true)
  assert_eq(@src.is_leap_year(2023), false)
}

///|
test "days_in_month" {
  assert_eq(@src.days_in_month(2024, 2), 29)
  assert_eq(@src.days_in_month(2023, 2), 28)
  assert_eq(@src.days_in_month(2024, 1), 31)
  assert_eq(@src.days_in_month(2024, 4), 30)
}

///|
test "DateTime::epoch" {
  let e = @src.DateTime::epoch()
  assert_eq(e.date.year, 1970)
  assert_eq(e.date.month, 1)
  assert_eq(e.date.day, 1)
  assert_eq(e.time.hour, 0)
  assert_eq(e.time.nanosecond, 0)
}

///|
test "from_unix_seconds epoch" {
  let dt = @src.DateTime::from_unix_seconds(0L)
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
  let dt = @src.DateTime::from_unix_seconds(1710506096L)
  assert_eq(dt.date.year, 2024)
  assert_eq(dt.date.month, 3)
  assert_eq(dt.date.day, 15)
  assert_eq(dt.time.hour, 12)
  assert_eq(dt.time.minute, 34)
  assert_eq(dt.time.second, 56)
}

///|
test "to_unix_seconds epoch" {
  let dt = @src.DateTime::epoch()
  assert_eq(dt.to_unix_seconds(), 0L)
}

///|
test "to_unix_seconds roundtrip" {
  let ts = 1710506096L
  let dt = @src.DateTime::from_unix_seconds(ts)
  assert_eq(dt.to_unix_seconds(), ts)
}

///|
test "from_unix_seconds pre-epoch" {
  // 1969-12-31T23:59:59Z = -1
  let dt = @src.DateTime::from_unix_seconds(-1L)
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
  let dt = @src.DateTime::from_unix_nanos(ns)
  assert_eq(dt.date.year, 2024)
  assert_eq(dt.time.second, 56)
  assert_eq(dt.time.nanosecond, 1)
}

///|
test "to_unix_nanos roundtrip" {
  let ns = 1710506096_123_456_789L
  let dt = @src.DateTime::from_unix_nanos(ns)
  assert_eq(dt.to_unix_nanos(), ns)
}

///|
test "DateTime::format no sub-second" {
  let dt = @src.DateTime::from_unix_seconds(0L)
  assert_eq(dt.format(), "1970-01-01T00:00:00Z")
}

///|
test "DateTime::format known date" {
  let dt = @src.DateTime::from_unix_seconds(1710506096L)
  assert_eq(dt.format(), "2024-03-15T12:34:56Z")
}

///|
test "DateTime::format with nanoseconds" {
  let dt = @src.DateTime::from_unix_nanos(1710506096_100_000_000L)
  assert_eq(dt.format(), "2024-03-15T12:34:56.1Z")
}

///|
test "DateTime::format nanosecond precision" {
  let dt = @src.DateTime::from_unix_nanos(1710506096_123_456_789L)
  assert_eq(dt.format(), "2024-03-15T12:34:56.123456789Z")
}

///|
test "DateTime::parse basic" {
  let dt = @src.DateTime::parse("1970-01-01T00:00:00Z")
  assert_eq(dt.to_unix_seconds(), 0L)
}

///|
test "DateTime::parse known date" {
  let dt = @src.DateTime::parse("2024-03-15T12:34:56Z")
  assert_eq(dt.to_unix_seconds(), 1710506096L)
}

///|
test "DateTime::parse lowercase t" {
  let dt = @src.DateTime::parse("2024-03-15t12:34:56Z")
  assert_eq(dt.to_unix_seconds(), 1710506096L)
}

///|
test "DateTime::parse with fractional seconds" {
  let dt = @src.DateTime::parse("2024-03-15T12:34:56.123456789Z")
  assert_eq(dt.time.nanosecond, 123_456_789)
}

///|
test "DateTime::parse fractional seconds trimmed" {
  let dt = @src.DateTime::parse("2024-03-15T12:34:56.1Z")
  assert_eq(dt.time.nanosecond, 100_000_000)
}

///|
test "DateTime::parse fractional seconds >9 digits truncated" {
  // 12 digits: first 9 significant, rest discarded without overflow
  let dt = @src.DateTime::parse("2024-03-15T12:34:56.123456789999Z")
  assert_eq(dt.time.nanosecond, 123_456_789)
}

///|
test "DateTime::parse fractional seconds all nines overflow safe" {
  let dt = @src.DateTime::parse("2024-03-15T12:34:56.99999999999Z")
  assert_eq(dt.time.nanosecond, 999_999_999)
}

///|
test "DateTime::parse +00:00 offset" {
  let dt = @src.DateTime::parse("2024-03-15T12:34:56+00:00")
  assert_eq(dt.to_unix_seconds(), 1710506096L)
}

///|
test "DateTime::parse -00:00 offset" {
  let dt = @src.DateTime::parse("2024-03-15T12:34:56-00:00")
  assert_eq(dt.to_unix_seconds(), 1710506096L)
}

///|
test "DateTime::parse non-UTC offset rejected" {
  let result = try {
    @src.DateTime::parse("2024-03-15T12:34:56+05:30") |> ignore
    "ok"
  } catch {
    @src.TempoError(_) => "error"
  }
  assert_eq(result, "error")
}

///|
test "DateTime::parse invalid format" {
  let result = try {
    @src.DateTime::parse("not-a-date") |> ignore
    "ok"
  } catch {
    @src.TempoError(_) => "error"
  }
  assert_eq(result, "error")
}

///|
test "DateTime::parse roundtrip" {
  let s = "2024-03-15T12:34:56.123456789Z"
  let dt = @src.DateTime::parse(s)
  assert_eq(dt.format(), s)
}

///|
test "Duration::days" {
  let d = @src.Duration::days(1L)
  assert_eq(d.as_seconds(), 86_400L)
  assert_eq(d.as_hours(), 24L)
}

///|
test "Duration::weeks" {
  let w = @src.Duration::weeks(2L)
  assert_eq(w.as_nanoseconds(), 2L * 7L * 86_400L * 1_000_000_000L)
  assert_eq(w.as_seconds(), 2L * 7L * 86_400L)
  assert_eq(w.as_weeks(), 2L)
}

///|
test "Duration::as_weeks" {
  assert_eq(@src.Duration::days(14L).as_weeks(), 2L)
  assert_eq(@src.Duration::days(13L).as_weeks(), 1L)
  assert_eq(@src.Duration::days(1L).as_weeks(), 0L)
}

///|
test "Duration::days arithmetic" {
  let dt = @src.DateTime::parse("2024-01-31T00:00:00Z")
  let dt2 = dt.add(@src.Duration::days(1L))
  assert_eq(dt2.date.month, 2)
  assert_eq(dt2.date.day, 1)
}

///|
test "DateTime::now is after epoch" {
  assert_eq(@src.DateTime::now() > @src.DateTime::epoch(), true)
}

///|
test "Duration::seconds" {
  let d = @src.Duration::seconds(90L)
  assert_eq(d.as_seconds(), 90L)
  assert_eq(d.as_minutes(), 1L)
  assert_eq(d.as_nanoseconds(), 90_000_000_000L)
}

///|
test "Duration::minutes" {
  let d = @src.Duration::minutes(2L)
  assert_eq(d.as_seconds(), 120L)
}

///|
test "Duration::hours" {
  let d = @src.Duration::hours(1L)
  assert_eq(d.as_minutes(), 60L)
}

///|
test "Duration op_add" {
  let a = @src.Duration::seconds(30L)
  let b = @src.Duration::seconds(30L)
  let c = a + b
  assert_eq(c.as_seconds(), 60L)
}

///|
test "Duration op_sub" {
  let a = @src.Duration::seconds(60L)
  let b = @src.Duration::seconds(10L)
  let c = a - b
  assert_eq(c.as_seconds(), 50L)
}

///|
test "Duration op_neg" {
  let d = @src.Duration::seconds(5L)
  let neg = -d
  assert_eq(neg.as_nanoseconds(), -5_000_000_000L)
}

///|
test "Duration compare" {
  let a = @src.Duration::seconds(1L)
  let b = @src.Duration::seconds(2L)
  assert_eq(a < b, true)
  assert_eq(b > a, true)
  assert_eq(a == a, true)
}

///|
test "DateTime::add" {
  let dt = @src.DateTime::from_unix_seconds(0L)
  let dt2 = dt.add(@src.Duration::hours(1L))
  assert_eq(dt2.time.hour, 1)
  assert_eq(dt2.to_unix_seconds(), 3600L)
}

///|
test "DateTime::sub" {
  let dt = @src.DateTime::from_unix_seconds(3600L)
  let dt2 = dt.sub(@src.Duration::hours(1L))
  assert_eq(dt2.to_unix_seconds(), 0L)
}

///|
test "DateTime::diff" {
  let a = @src.DateTime::from_unix_seconds(0L)
  let b = @src.DateTime::from_unix_seconds(3600L)
  let d = b.diff(a)
  assert_eq(d.as_hours(), 1L)
}

///|
test "DateTime::diff negative" {
  let a = @src.DateTime::from_unix_seconds(3600L)
  let b = @src.DateTime::from_unix_seconds(0L)
  let d = b.diff(a)
  assert_eq(d.as_nanoseconds(), -3_600_000_000_000L)
}

///|
test "DateTime::add crosses day boundary" {
  let dt = @src.DateTime::parse("2024-03-15T23:00:00Z")
  let dt2 = dt.add(@src.Duration::hours(2L))
  assert_eq(dt2.date.day, 16)
  assert_eq(dt2.time.hour, 1)
}

///|
test "DateTime::add crosses month boundary" {
  let dt = @src.DateTime::parse("2024-01-31T12:00:00Z")
  let dt2 = dt.add(@src.Duration::hours(24L))
  assert_eq(dt2.date.month, 2)
  assert_eq(dt2.date.day, 1)
}

///|
test "DateTime compare" {
  let a = @src.DateTime::from_unix_seconds(0L)
  let b = @src.DateTime::from_unix_seconds(1L)
  assert_eq(a < b, true)
  assert_eq(b > a, true)
  assert_eq(a == a, true)
}

///|
test "Show Date" {
  let d = @src.Date::new(2024, 3, 5)
  inspect(d, content="2024-03-05")
}

///|
test "Show Time" {
  let t = @src.Time::new(9, 5, 3, 0)
  inspect(t, content="09:05:03")
}

///|
test "Show DateTime" {
  let dt = @src.DateTime::from_unix_seconds(1710506096L)
  inspect(dt, content="2024-03-15T12:34:56Z")
}

///|
test "Show Duration zero" {
  let d = @src.Duration::seconds(0L)
  inspect(d, content="0s")
}

///|
test "Show Duration seconds" {
  let d = @src.Duration::seconds(5L)
  inspect(d, content="5s")
}

///|
test "Show Duration hours minutes seconds" {
  let d = @src.Duration::seconds(3661L)
  inspect(d, content="1h1m1s")
}

///|
test "Show Duration negative" {
  let d = -@src.Duration::seconds(5L)
  inspect(d, content="-5s")
}
