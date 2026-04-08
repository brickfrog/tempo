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

## v0.3 — next

**Sub-second `now()` on native**
See v0.2. Requires a `.c` stub in the build.

**`Date::parse` / `Date::format`**
Date-only strings: `2026-03-28`.

**`Time::parse` / `Time::format`**
Time-only strings: `14:31:43`, `14:31:43.123Z`.

**Docstring coverage**
Public API docstrings are sparse.

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
