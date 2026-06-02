# tempo

UTC date/time library for MoonBit. RFC 3339 parsing, Unix timestamp conversion,
calendar and duration arithmetic. No external dependencies.

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

## Unix timestamps

```moonbit nocheck
///|
test {
  let dt = @tempo.DateTime::from_unix_seconds(0L)
  inspect(dt.format(), content="1970-01-01T00:00:00Z")
  inspect(dt.to_unix_seconds(), content="0")

  let dt2 = @tempo.DateTime::from_unix_nanos(1_000_000_000L)
  inspect(dt2.format(), content="1970-01-01T00:00:01Z")
  inspect(dt2.to_unix_nanos(), content="1000000000")

  let ms = @tempo.DateTime::from_unix_millis(1500L)
  inspect(ms.format(), content="1970-01-01T00:00:01.5Z")
  inspect(ms.to_unix_millis(), content="1500")

  let us = @tempo.DateTime::from_unix_micros(1_500_250L)
  inspect(us.format(), content="1970-01-01T00:00:01.50025Z")
  inspect(us.to_unix_micros(), content="1500250")
}
```

## Parsing

Accepts RFC 3339 / ISO 8601. UTC markers (`Z`, `+00:00`, `-00:00`) and fixed
numeric offsets are accepted. Parsed values are stored as UTC `DateTime`s; the
original offset is not retained. Out-of-range offsets raise `TempoError`.

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
  let dt = @tempo.DateTime::parse("2024-07-21T17:11:00-04:00")
  inspect(dt.format(), content="2024-07-21T21:11:00Z")
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
  assert_eq(@tempo.Duration::seconds(1L).is_positive(), true)
}
```

## Duration arithmetic

`Duration::abs`, `is_positive`, `signum`, `multiply`, `checked_multiply`, and
`divide` cover common signed-duration operations.
`Duration::divide` raises on division by zero and on the
`Int64::min_value / -1` overflow.

```moonbit nocheck
///|
test {
  let d = @tempo.Duration::seconds(-3L)
  inspect(d.abs().as_seconds(), content="3")
  assert_eq(d.signum(), -1)

  let doubled = @tempo.Duration::seconds(2L).multiply(3L)
  inspect(doubled.as_seconds(), content="6")
  assert_eq(
    @tempo.Duration::seconds(2L).checked_multiply(3L),
    Some(@tempo.Duration::seconds(6L)),
  )

  let half = @tempo.Duration::seconds(7L).divide(2L)
  inspect(half.as_seconds(), content="3")
}
```

## Calendar arithmetic

`Date::add_months` and `Date::add_years` clamp to the end of the target month
when needed. `Date` and `DateTime` both provide `start_of_month`,
`end_of_month`, `start_of_year`, and `end_of_year`; the `DateTime` variants
adjust the date and preserve the time of day.

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

```moonbit nocheck
///|
test {
  let end = @tempo.Date::new(2024, 1, 31)
  inspect(end.add_months(1).format(), content="2024-02-29")

  let leap = @tempo.Date::new(2024, 2, 29)
  inspect(leap.add_years(1).format(), content="2025-02-28")

  let mid = @tempo.Date::new(2024, 3, 15)
  inspect(mid.start_of_month().format(), content="2024-03-01")
  inspect(mid.end_of_month().format(), content="2024-03-31")
  inspect(mid.start_of_year().format(), content="2024-01-01")
  inspect(mid.end_of_year().format(), content="2024-12-31")

  let dt = @tempo.DateTime::parse("2024-03-15T14:31:43Z")
  inspect(dt.start_of_month().format(), content="2024-03-01T14:31:43Z")
  inspect(dt.end_of_year().format(), content="2024-12-31T14:31:43Z")
}
```

## Field updaters

`DateTime::to_date` and `DateTime::to_time` split a timestamp into its parts.
`Date` has `with_year`/`with_month`/`with_day`; `Time` has `with_hour` through
`with_nanosecond`; `DateTime` has `with_date`/`with_time` plus `with_year`
through `with_nanosecond`. Fallible updaters raise on invalid values rather
than clamping.

```moonbit nocheck
///|
test {
  let d = @tempo.Date::new(2024, 3, 15)
  inspect(d.with_day(1).format(), content="2024-03-01")

  let t = @tempo.Time::new(14, 31, 43, 125_000_000)
  inspect(t.with_nanosecond(0).format(), content="14:31:43")

  let dt = @tempo.DateTime::new(d, t)
  inspect(dt.to_date().format(), content="2024-03-15")
  inspect(dt.to_time().format(), content="14:31:43.125")
  inspect(
    dt.with_year(2025).with_hour(9).format(),
    content="2025-03-15T09:31:43.125Z",
  )
}
```

## Weekday and Month

`Date::weekday` and `Date::month_enum` return enums. `Weekday` and `Month` use
1-based numbers for `to_int`/`from_int`; `next` and `previous` wrap around.

```moonbit nocheck
///|
test {
  let d = @tempo.Date::new(2024, 3, 15)
  assert_eq(d.weekday(), @tempo.Friday)
  assert_eq(d.month_enum(), @tempo.March)

  assert_eq(@tempo.Friday.to_int(), 5)
  assert_eq(@tempo.Weekday::from_int(5), Some(@tempo.Friday))
  assert_eq(@tempo.Friday.next(), @tempo.Saturday)
  assert_eq(@tempo.Monday.previous(), @tempo.Sunday)

  assert_eq(@tempo.February.to_int(), 2)
  assert_eq(@tempo.Month::from_int(2), Some(@tempo.February))
  assert_eq(@tempo.February.days_in(2024), 29)
}
```

## Rounding and truncation

`start_of_day`/`end_of_day`, `truncate_to(unit)` (floor to a `TimeUnit`), and
`round_to(unit, mode)` snap a `DateTime` to a boundary. `round_to` takes a
`RoundMode` of `Floor`, `Ceil`, or `HalfExpand` (ties round up).

```moonbit nocheck
///|
test {
  let dt = @tempo.DateTime::parse("2024-03-15T14:31:43.125Z")
  inspect(dt.start_of_day().format(), content="2024-03-15T00:00:00Z")
  inspect(dt.truncate_to(@tempo.Hour).format(), content="2024-03-15T14:00:00Z")

  let half = @tempo.DateTime::parse("2024-03-15T14:30:00Z")
  inspect(
    half.round_to(@tempo.Hour, @tempo.HalfExpand).format(),
    content="2024-03-15T15:00:00Z",
  )
}
```

## Comparison

Named helpers over the derived ordering: `is_before`/`is_after`, `min`/`max`,
and `clamp` for `Date`/`Time`/`DateTime`, plus wall-clock `DateTime::since`/
`until` (over `diff`).

```moonbit nocheck
///|
test {
  let a = @tempo.Date::new(2024, 1, 1)
  let b = @tempo.Date::new(2024, 2, 1)
  assert_eq(a.is_before(b), true)
  assert_eq(a.max(b), b)

  let dt = @tempo.DateTime::parse("2024-03-15T12:00:00Z")
  let later = dt.add(@tempo.Duration::hours(2L))
  inspect(later.since(dt).as_hours(), content="2")
}
```

## Intervals

`DateInterval` is an inclusive `[start, end]` range of dates; `Interval` is a
half-open `[start, end)` range of datetimes. Both provide `contains`,
`overlaps`, and `intersection`.

```moonbit nocheck
///|
test {
  let span = @tempo.DateInterval::{
    start: @tempo.Date::new(2024, 1, 1),
    end: @tempo.Date::new(2024, 1, 10),
  }
  assert_eq(span.contains(@tempo.Date::new(2024, 1, 5)), true)
  inspect(span.length_in_days(), content="10")
}
```

## Weekday navigation

`Date::next`/`previous` find the nearest date on a weekday (strictly
after/before); `next_or_same`/`previous_or_same` include the date itself; and
`nth_weekday_of_month` finds the nth occurrence (a negative `n` counts from the
end).

```moonbit nocheck
///|
test {
  let fri = @tempo.Date::new(2024, 3, 15) // a Friday
  inspect(fri.next(@tempo.Monday).format(), content="2024-03-18")
  inspect(fri.previous(@tempo.Monday).format(), content="2024-03-11")

  // 3rd Tuesday of March 2024
  let t = @tempo.Date::nth_weekday_of_month(2024, 3, @tempo.Tuesday, 3)
  inspect(t.format(), content="2024-03-19")
}
```

## Hashing

`Date`, `Time`, `DateTime`, and `Duration` derive `Hash`, so they work as keys
in the stdlib hash `Map`/`Set`.

```moonbit nocheck
///|
test {
  let counts : Map[@tempo.Date, Int] = {}
  counts.set(@tempo.Date::new(2024, 3, 15), 3)
  assert_eq(counts.get(@tempo.Date::new(2024, 3, 15)), Some(3))
}
```

## ISO 8601 durations

`Duration::format_iso`/`parse_iso` round-trip the `PnDTnHnMnS` subset (days,
hours, minutes, seconds with fractions). Years and months are rejected as
calendar units.

```moonbit nocheck
///|
test {
  let d = @tempo.Duration::hours(2L) + @tempo.Duration::minutes(30L)
  inspect(d.format_iso(), content="PT2H30M")
  assert_eq(@tempo.Duration::parse_iso("PT2H30M"), d)
}
```

## JSON

`Date`, `Time`, `DateTime`, and `Duration` serialize to their canonical strings
(RFC 3339 / ISO 8601) via `moonbitlang/core/json` — not field objects.

```moonbit nocheck
///|
test {
  let dt = @tempo.DateTime::parse("2024-07-21T17:11:00Z")
  inspect(dt.to_json().stringify(), content="\"2024-07-21T17:11:00Z\"")
}
```

## Overflow safety

`to_unix_nanos` and the `add`/`sub`/`diff` operators wrap silently outside the
Int64-nanosecond range (~1677–2262). The checked variants return `None` instead:
`to_unix_nanos_checked`, `DateTime::checked_add`/`checked_sub`/`checked_diff`,
and `Duration::checked_add`/`checked_sub`. `min_unix_nanos`/`max_unix_nanos`
document the bounds.

```moonbit nocheck
///|
test {
  let far = @tempo.DateTime::parse("3000-01-01T00:00:00Z")
  assert_eq(far.to_unix_nanos_checked(), None)

  match @tempo.DateTime::epoch().checked_add(@tempo.Duration::hours(1L)) {
    Some(dt) => inspect(dt.format(), content="1970-01-01T01:00:00Z")
    None => ()
  }
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

## Year-month

`YearMonth` is a year-and-month value with no day — useful for billing periods
and month-granular keys. `length` is leap-aware; `plus_months` / `plus_years`
carry across years; `Compare` orders chronologically.

```moonbit nocheck
///|
test {
  let ym = @tempo.YearMonth::new(2024, 2)
  inspect(ym.format(), content="2024-02")
  inspect(ym.length(), content="29") // February 2024 is a leap year
  inspect(ym.at_day(15).format(), content="2024-02-15")
  inspect(ym.at_end_of_month().format(), content="2024-02-29")
  inspect(ym.plus_months(11).format(), content="2025-01")
  inspect(@tempo.YearMonth::parse("2025-01").format(), content="2025-01")
}
```

## Periods

`Period` is a calendar-aware `{ years, months, days }` value — the calendar
counterpart to the elapsed-time `Duration`. It stores its fields exactly and is
never auto-normalized (15 months stays 15 months), because applying a period is
anchor-dependent: adding one month clamps to the end of a short month, while
adding 30 days does not. `normalized` rolls months into years only.
`Date::until` returns the period between two dates and round-trips with
`add_period`. Operations that would overflow the `Int` fields raise.

```moonbit nocheck
///|
test {
  let p = @tempo.Period::of(1, 2, 10)
  inspect(p.format(), content="P1Y2M10D")
  inspect(@tempo.Period::of(0, 15, 0).normalized().format(), content="P1Y3M")

  // Anchor-dependent: months adjust (with clamping) before days.
  let d = @tempo.Date::new(2024, 1, 31)
  inspect(d.add_period(@tempo.Period::of(0, 1, 0)).format(), content="2024-02-29")
  inspect(d.add_period(@tempo.Period::of(0, 0, 30)).format(), content="2024-03-01")

  // until round-trips with add_period.
  let start = @tempo.Date::new(2024, 1, 15)
  let end = @tempo.Date::new(2024, 3, 20)
  let span = start.until(end)
  inspect(span.format(), content="P2M5D")
  assert_eq(start.add_period(span), end)
}
```

## ISO week and ordinal dates

`Date` exposes ISO 8601 week dates and ordinal (day-of-year) dates. The ISO
week-numbering year can differ from the calendar year for dates near January 1
and December 31.

```moonbit nocheck
///|
test {
  let d = @tempo.Date::new(2021, 1, 1)
  assert_eq(d.iso_week_year(), 2020) // belongs to ISO week-year 2020
  assert_eq(d.iso_week(), 53)
  inspect(d.format_iso_week(), content="2020-W53-5")
  inspect(@tempo.Date::from_iso_week(2020, 53, 5).format(), content="2021-01-01")

  // Ordinal (day-of-year) dates, leap-aware.
  inspect(@tempo.Date::from_ordinal(2024, 60).format(), content="2024-02-29")
  inspect(@tempo.Date::new(2024, 12, 31).format_ordinal(), content="2024-366")

  // Parse the string forms (inverses of the format_* methods).
  inspect(
    @tempo.Date::parse_iso_week("2020-W53-5").format(),
    content="2021-01-01",
  )
  inspect(@tempo.Date::parse_ordinal("2024-060").format(), content="2024-02-29")
}
```

## Quarters

```moonbit nocheck
///|
test {
  let d = @tempo.Date::new(2024, 5, 15)
  assert_eq(d.quarter(), 2)
  inspect(d.start_of_quarter().format(), content="2024-04-01")
  inspect(d.end_of_quarter().format(), content="2024-06-30")
  assert_eq(d.days_in_year(), 366)
  assert_eq(d.is_leap(), true)
}
```

## Fractional and human-readable durations

`as_seconds_f64` / `as_minutes_f64` / `as_hours_f64` give fractional totals as
`Double`. `humanize` renders an English elapsed string (days/hours/minutes/
seconds, non-zero components only, `-` prefix for negatives).

```moonbit nocheck
///|
test {
  inspect(@tempo.Duration::minutes(90).as_hours_f64(), content="1.5")
  inspect(@tempo.Duration::milliseconds(1500).as_seconds_f64(), content="1.5")

  let d = @tempo.Duration::hours(2) + @tempo.Duration::minutes(30)
  inspect(d.humanize(), content="2 hours 30 minutes")
  inspect(@tempo.Duration::seconds(1).humanize(), content="1 second")
  inspect(@tempo.Duration::minutes(-90).humanize(), content="-1 hour 30 minutes")
}
```

## Custom formatting

`format_fixed` produces a fixed-width timestamp (always nine fractional digits)
whose byte order matches chronological order for years 0–9999 — handy for log
lines and database keys. `format_with` is a brace-token DSL: the tokens
`{YYYY}`, `{MM}`, `{DD}`, `{HH}`, `{mm}`, `{ss}`, `{fff}`, and `{nnnnnnnnn}`
substitute, everything else is literal, `{{` and `}}` emit literal braces, and
an unknown token or unmatched brace raises.

```moonbit nocheck
///|
test {
  let dt = @tempo.DateTime::parse("2024-07-21T17:11:00.5Z")
  inspect(dt.format_fixed(), content="2024-07-21T17:11:00.500000000Z")
  inspect(dt.format_with("{YYYY}/{MM}/{DD} {HH}:{mm}"), content="2024/07/21 17:11")
}
```

## Not included

- **Timezones / DST** — planned as a separate `tempo-tz` package
- **Locale-aware formatting** — `strftime` patterns, localized names
- **Leap seconds** — POSIX ignores them, so does tempo

See [ROADMAP.md](ROADMAP.md).
