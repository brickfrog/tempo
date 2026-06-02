# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.6.0] - 2026-06-02

### Added

- `Hash` on `Date`, `Time`, `DateTime`, and `Duration`, so they can be used as
  keys in the stdlib hash `Map`/`Set`. (#31)
- `Duration::format_iso` / `parse_iso` for ISO 8601 duration strings (the
  `PnDTnHnMnS` subset with fractional seconds). Years and months are rejected as
  calendar units. (#32)
- JSON via `moonbitlang/core/json`: `ToJson` / `FromJson` for `Date`, `Time`,
  `DateTime`, and `Duration`, encoded as their canonical RFC 3339 / ISO 8601
  strings rather than field objects. (#33)
- Int64 overflow safety: `DateTime::min_unix_nanos` / `max_unix_nanos` and
  `to_unix_nanos_checked` (#29); `DateTime::checked_add` / `checked_sub` /
  `checked_diff` and `Duration::checked_add` / `checked_sub`, each returning
  `None` on overflow or an out-of-range operand (#30).

### Changed

- Documented that `to_unix_nanos` and the infallible `add` / `sub` / `diff`
  operators wrap on Int64 overflow; the `checked_*` variants are the
  overflow-safe alternative. (#29, #30)

## [0.5.0] - 2026-06-02

### Added

- `DateTime::start_of_day` / `end_of_day`, and `truncate_to(unit)` flooring to a
  `TimeUnit` (`Second` / `Minute` / `Hour` / `Day`). (#23)
- Comparison helpers `is_before` / `is_after` / `min` / `max` / `clamp` for
  `Date`, `Time`, and `DateTime`, plus wall-clock `DateTime::since` / `until`. (#24)
- `DateInterval` (inclusive `[start, end]`) and `Interval` (half-open
  `[start, end)`) range types with `contains`, `overlaps`, `intersection`, and
  `length_in_days` / `to_duration`. (#25)
- `DateTime::round_to(unit, mode)` with a `RoundMode` of `Floor` / `Ceil` /
  `HalfExpand` (ties round up). (#26)
- Weekday navigation on `Date`: `next` / `previous` / `next_or_same` /
  `previous_or_same`, and `nth_weekday_of_month` (negative `n` counts from the
  end; an occurrence outside the month raises `TempoError`). (#27)

## [0.4.0] - 2026-06-02

### Added

- `DateTime::parse` accepts fixed RFC 3339 numeric offsets (e.g.
  `2024-07-21T17:11:00-04:00`) and normalizes them to UTC. Out-of-range offsets
  raise `TempoError`. The original offset is not retained. (#14)
- `Date::add_months` and `Date::add_years`, with end-of-month clamping
  (`2024-01-31` + 1 month = `2024-02-29`; clamping is non-sticky). (#15)
- Month and year boundary adjusters on `Date` and `DateTime`: `start_of_month`,
  `end_of_month`, `start_of_year`, `end_of_year`. The `DateTime` variants adjust
  the date and preserve the time of day. (#16)
- `DateTime::to_date` and `DateTime::to_time` accessors. (#17)
- Immutable field updaters: `Date::with_year`/`with_month`/`with_day`,
  `Time::with_hour`/`with_minute`/`with_second`/`with_nanosecond`, and
  `DateTime::with_date`/`with_time` plus `with_year` through `with_nanosecond`.
  The fallible updaters validate through `Date::new`/`Time::new` and raise on an
  invalid result rather than clamping. (#17)
- `Weekday` (Monday–Sunday) and `Month` (January–December) enums implementing `Eq`,
  `Compare`, `Hash`, and `Show`, with `to_int`/`from_int`, cyclic
  `next`/`previous`, `Weekday::number_from_monday`/`number_from_sunday`, and
  `Month::days_in`. `Date::weekday` and `Date::month_enum` return them;
  `Date::day_of_week` (returning `Int`) is unchanged. (#18)
- `Duration::abs`, `is_positive`, `signum`, `multiply`, `checked_multiply`, and
  `divide`. `abs` saturates `Int64::min_value` to `Int64::max_value`; `multiply`
  wraps on overflow while `checked_multiply` returns `None`; `divide` truncates
  toward zero and raises on division by zero and on the `Int64::min_value / -1`
  overflow. (#19)
- `DateTime::from_unix_millis`/`to_unix_millis` and
  `from_unix_micros`/`to_unix_micros`. The conversions split into whole seconds
  plus a bounded sub-second remainder, so they hold across the full date range
  rather than only the ~292-year nanosecond window. (#20)

### Changed

- Migrated the module manifest from `moon.mod.json` to the TOML `moon.mod`, and
  trait implementations to the `with fn` syntax, for the May 2026 MoonBit
  toolchain. (#13)

## [0.3.4] - 2026-05-13

### Fixed
- Compatibility with the May 2026 MoonBit toolchain.

## [0.3.3] - 2026-04-29

### Changed
- Replaced a deprecated `StringView` allocation.

## [0.3.2] - 2026-04-12

### Fixed
- `Duration::to_string_repr` guards `Int64::min_value`, which cannot be negated.

## [0.3.1] - 2026-04-08

### Fixed
- JS backend: `Int64` FFI returns `BigInt` directly, for newer-runtime compatibility.

## [0.3.0] - 2026-04-08

### Added
- `Duration::is_zero`, `Duration::is_negative`, and the `Duration::as_days` accessor.

## [0.2.3] - 2026-04-05

### Changed
- Internal test coverage and design documentation.

## [0.2.2] - 2026-03-31

### Changed
- Internal migration from `loop` to `for`.

## [0.2.1] - 2026-03-28

### Fixed
- Added the `source` field to the manifest so the package resolves as `@tempo`.

## [0.2.0] - 2026-03-28

### Added
- `Date::parse` / `Date::format` for date-only strings (`2024-03-28`).
- `Time::parse` / `Time::format` for time-only strings (`14:31:43`, `14:31:43.123`).
- `Date` calendar arithmetic: `add_days`, `day_of_week`, `day_of_year`, `days_until`.
- `Duration::weeks` constructor and `Duration::as_weeks` accessor.
- ISO 8601 expanded-year formatting for negative years.

## [0.1.0] - 2026-03-28

### Added
- Core types `Date`, `Time`, `DateTime`, `Duration`.
- RFC 3339 / ISO 8601 `DateTime::parse` and `DateTime::format`.
- Unix timestamp conversion: `from_unix_seconds`/`from_unix_nanos` and `to_unix_seconds`/`to_unix_nanos`.
- `DateTime` arithmetic (`add`, `sub`, `diff`) and `Duration` operators.
- `Duration` constructors (`nanoseconds` … `days`) and accessors (`as_nanoseconds` … `as_hours`).
- `DateTime::now` (POSIX `time(2)` on native, `Date.now()` on js/wasm-gc).
- `Show`, `Eq`, `Compare` for all types.
- Calendar helpers `is_leap_year` and `days_in_month`.
