# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
- `Weekday` (Monday–Sunday) and `Month` (January–December) enums deriving `Eq`,
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
