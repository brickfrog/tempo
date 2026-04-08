# tempo

UTC date/time library for MoonBit. RFC 3339 parsing, Unix timestamp conversion,
basic arithmetic. No external dependencies.

In your `moon.pkg`:

```
import {
  "brickfrog/tempo/src" @tempo,
}
```

## Quick start

```moonbit nocheck
///|
test {
  let dt = @tempo.DateTime::parse("2026-03-28T14:31:43Z")
  inspect(dt.date.year, content="2026")
  inspect(dt.date.month, content="3")
  inspect(dt.time.hour, content="14")
  inspect(dt.format(), content="2026-03-28T14:31:43Z")
}
```

## Types

| Type | Description |
|---|---|
| `Date` | `year`, `month` (1–12), `day` (1–31) |
| `Time` | `hour`, `minute`, `second`, `nanosecond` |
| `DateTime` | Combined UTC date and time |
| `Duration` | Signed duration, stored as nanoseconds |

All types implement `Eq`, `Compare`, and `Show`.

## Constructing values

```moonbit nocheck
///|
test {
  let d = @tempo.Date::new(2026, 3, 28)
  let t = @tempo.Time::new(14, 31, 43, 0)
  let dt = @tempo.DateTime::new(d, t)
  inspect(dt.format(), content="2026-03-28T14:31:43Z")
}
```

```moonbit nocheck
///|
test {
  let dt = @tempo.DateTime::from_unix_seconds(0L)
  inspect(dt.format(), content="1970-01-01T00:00:00Z")

  let dt2 = @tempo.DateTime::from_unix_nanos(1_000_000_000L)
  inspect(dt2.format(), content="1970-01-01T00:00:01Z")
}
```

## Parsing

Accepts RFC 3339 / ISO 8601. Only UTC offsets (`Z`, `+00:00`, `-00:00`) are
accepted — others raise `TempoError`.

```moonbit nocheck
///|
test {
  let dt = @tempo.DateTime::parse("2026-03-28T14:31:43.125Z")
  inspect(dt.time.nanosecond, content="125000000")
}
```

```moonbit nocheck
///|
test {
  let result = try {
    @tempo.DateTime::parse("2026-03-28T14:31:43+09:00") |> ignore
    "ok"
  } catch {
    @tempo.TempoError(_) => "error"
  }
  assert_eq(result, "error")
}
```

## Formatting

`DateTime::format` produces RFC 3339 with a `Z` suffix. Fractional seconds are
included only when `nanosecond ≠ 0`, trailing zeros trimmed.

```moonbit nocheck
///|
test {
  let dt = @tempo.DateTime::from_unix_nanos(1_711_630_303_100_000_000L)
  inspect(dt.format(), content="2024-03-28T14:31:43.1Z")
}
```

## Arithmetic

```moonbit nocheck
///|
test {
  let dt = @tempo.DateTime::parse("2026-03-28T12:00:00Z")
  let dt2 = dt.add(@tempo.Duration::hours(2L))
  inspect(dt2.time.hour, content="14")

  let dt3 = dt.sub(@tempo.Duration::minutes(30L))
  inspect(dt3.time.minute, content="30")

  let gap = dt2.diff(dt)
  inspect(gap.as_hours(), content="2")
}
```

```moonbit nocheck
///|
test {
  let a = @tempo.Duration::hours(1L)
  let b = @tempo.Duration::minutes(30L)
  inspect((a + b).as_minutes(), content="90")
  inspect((-a).as_nanoseconds(), content="-3600000000000")
}
```

## Duration constructors

```moonbit nocheck
///|
test {
  inspect(@tempo.Duration::weeks(1L).as_days(), content="7")
  inspect(@tempo.Duration::days(1L).as_hours(), content="24")
  inspect(@tempo.Duration::hours(1L).as_minutes(), content="60")
  inspect(@tempo.Duration::minutes(1L).as_seconds(), content="60")
  inspect(@tempo.Duration::seconds(1L).as_milliseconds(), content="1000")
  inspect(@tempo.Duration::milliseconds(1L).as_microseconds(), content="1000")
  inspect(@tempo.Duration::microseconds(1L).as_nanoseconds(), content="1000")
}
```

## Duration accessors

All accessors truncate toward zero (e.g. 90 minutes → 1 hour).

```moonbit nocheck
///|
test {
  inspect(@tempo.Duration::days(3L).as_days(), content="3")
  inspect(@tempo.Duration::weeks(1L).as_weeks(), content="1")
  inspect(@tempo.Duration::days(7L).as_weeks(), content="1")
}
```

## Duration predicates

```moonbit nocheck
///|
test {
  assert_eq(@tempo.Duration::seconds(0L).is_zero(), true)
  assert_eq(@tempo.Duration::seconds(1L).is_zero(), false)
  assert_eq(@tempo.Duration::seconds(-1L).is_negative(), true)
  assert_eq(@tempo.Duration::seconds(1L).is_negative(), false)
}
```

## Date arithmetic

```moonbit nocheck
///|
test {
  let d = @tempo.Date::new(2024, 3, 15)

  // Add/remove days
  let d2 = d.add_days(10)
  inspect(d2.day, content="25")

  // ISO weekday: Monday = 1 … Sunday = 7
  assert_eq(d.day_of_week(), 5) // Friday

  // Day of year (1-based)
  assert_eq(d.day_of_year(), 75)

  // Days between two dates
  let other = @tempo.Date::new(2024, 3, 1)
  assert_eq(d.days_until(other), -14)
}
```

## Date and Time parsing/formatting

```moonbit nocheck
///|
test {
  // Date-only parse/format
  let d = @tempo.Date::parse("2024-03-15")
  inspect(d.format(), content="2024-03-15")

  // Time-only parse/format
  let t = @tempo.Time::parse("14:31:43.500")
  inspect(t.format(), content="14:31:43.5")
}
```

## Current time

```moonbit nocheck
///|
test {
  // Millisecond precision on js/wasm-gc, whole seconds on native.
  let now = @tempo.DateTime::now()
  assert_eq(now > @tempo.DateTime::epoch(), true)
}
```

## Calendar helpers

```moonbit nocheck
///|
test {
  assert_eq(@tempo.is_leap_year(2000), true)
  assert_eq(@tempo.is_leap_year(1900), false)
  assert_eq(@tempo.is_leap_year(2024), true)
  assert_eq(@tempo.days_in_month(2024, 2), 29)
  assert_eq(@tempo.days_in_month(2023, 2), 28)
}
```

## Not included

- **Timezones / DST** — planned as a separate `tempo-tz` package
- **Locale-aware formatting** — `strftime` patterns, localized names
- **Leap seconds** — POSIX ignores them, so does tempo

See [ROADMAP.md](ROADMAP.md).
