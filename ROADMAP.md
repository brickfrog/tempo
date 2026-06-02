# tempo roadmap

---

## v0.1 — shipped

- **Core types**: `Date`, `Time`, `DateTime`, `Duration`
- **Unix timestamps**: `from_unix_seconds`, `from_unix_nanos`, `to_unix_seconds`, `to_unix_nanos`
- **RFC 3339 / ISO 8601**: `DateTime::parse`, `DateTime::format`
- **Arithmetic**: `DateTime::add`, `DateTime::sub`, `DateTime::diff`, `Duration` ops (`+`, `-`, unary `-`)
- **Duration constructors**: `nanoseconds`, `microseconds`, `milliseconds`, `seconds`, `minutes`, `hours`, `days`
- **Duration accessors**: `as_nanoseconds` … `as_hours`
- **`DateTime::now()`**: POSIX `time(2)` on native, `Date.now()` on js/wasm-gc
- **`Show`** for all types, **`Eq`** + **`Compare`**
- **Calendar helpers**: `is_leap_year`, `days_in_month`
- Tests pass on **native**, **js**, **wasm-gc**

---

## v0.2 — shipped

**`Date` arithmetic**
`Date::add_days`, `Date::day_of_week`, `Date::day_of_year`, `Date::days_until`.

**`Date::parse` / `Date::format`**
Date-only strings: `2024-03-28`.

**`Time::parse` / `Time::format`**
Time-only strings: `14:31:43`, `14:31:43.123`.

**`Duration::weeks`**
`7 * days`.

**`Duration::as_days`**
Whole-day accessor, completes constructor/accessor symmetry.

**`Duration::is_zero` / `Duration::is_negative`**
Common predicates.

**`Duration::as_weeks`**
Whole-week accessor.

**Negative year formatting**
`pad4_year` now handles negative years via ISO 8601 expanded-year conventions.

**Docstrings**
Added to all public functions.

---

## v0.3 — shipped

Maintenance and toolchain compatibility (JS backend `Int64` FFI, MoonBit
toolchain updates).

---

## v0.4 — shipped

**Fixed-offset parsing**
`DateTime::parse` accepts RFC 3339 numeric offsets (`-04:00`, `+09:00`) and
normalizes to UTC.

**Calendar arithmetic**
`Date::add_months`, `Date::add_years` (end-of-month clamping);
`start_of_month` / `end_of_month` / `start_of_year` / `end_of_year` on `Date`
and `DateTime`.

**Field updaters & accessors**
`with_year` … `with_nanosecond` on `Date` / `Time` / `DateTime`;
`DateTime::to_date` / `to_time`.

**Typed enums**
`Weekday` and `Month` (Int conversions, navigation); `Date::weekday`,
`Date::month_enum`.

**Duration scalar ops**
`abs`, `is_positive`, `signum`, `multiply`, `checked_multiply`, `divide`.

**Timestamp interop**
`from_unix_millis` / `to_unix_millis`, `from_unix_micros` / `to_unix_micros`.

---

## next

**Sub-second `now()` on native**
Requires a `.c` stub in the build.

**`FixedOffsetDateTime`**
Retain the display offset instead of normalizing to UTC.

**Calendar-aware `Period` / `YearMonth`**
Year/month durations distinct from the nanosecond `Duration`.

**Rounding & comparison helpers**
`truncate_to` / `round_to`, `start_of_day`, `is_before` / `is_after` / `clamp`,
date intervals.

**ISO week & ordinal dates**
`iso_week`, `from_ordinal`, week-date / ordinal string formats.

**Hash & JSON**
`derive(Hash)` for map keys; `ToJson` / `FromJson`.

---

## deferred

**Timezones**
IANA database is ~3 MB and updated several times a year. Separate library.

**Locale-aware formatting**
`strftime` patterns, localized month/day names. Requires locale data.

**Arbitrary format strings**
`DateTime::format_with("%Y-%m-%d %H:%M:%S")`.

**Leap seconds**
POSIX ignores them. Correct handling needs a periodically-updated table.

**`wasm` target** (non-GC)
Different memory model from `wasm-gc`. Would need its own `now` implementation.

**Calendar systems**
Julian, Hebrew, Islamic, etc.
