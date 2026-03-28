# tempo roadmap

UTC-only date/time library for MoonBit. The honest v1 is "UTC only, RFC 3339,
basic arithmetic" — already more useful than anything currently in the MoonBit
ecosystem. Timezones are essentially a separate library.

---

## v0.1 — shipped

- **Core types**: `Date`, `Time`, `DateTime`, `Duration`
- **Unix timestamps**: `from_unix_seconds`, `from_unix_nanos`, `to_unix_seconds`, `to_unix_nanos`
- **RFC 3339 / ISO 8601**: `DateTime::parse`, `DateTime::format`
- **Arithmetic**: `DateTime::add`, `DateTime::sub`, `DateTime::diff`, `Duration` ops (`+`, `-`, unary `-`)
- **Duration constructors**: `nanoseconds`, `microseconds`, `milliseconds`, `seconds`, `minutes`, `hours`, `days`
- **Duration accessors**: `as_nanoseconds` … `as_hours`
- **`DateTime::now()`**: target-specific — POSIX `time(2)` on native, `Date.now()` on js/wasm-gc
- **`Show`** for all types, **`Eq`** + **`Compare`** (ordering operators work)
- **Calendar helpers**: `is_leap_year`, `days_in_month`
- Tests pass on **native**, **js**, **wasm-gc**

---

## v0.2 — next

**`now()` precision on native**
Currently `time(2)` — whole seconds only. Fix: thin C stub wrapping
`clock_gettime(CLOCK_REALTIME)` returning nanoseconds. Requires a `.c` file
wired into the build; the FFI shape is already established.

**`Date` arithmetic**
`Date::add_days`, `Date::day_of_week`, `Date::day_of_year`, `Date::days_until`.
Useful without needing full `DateTime` + `Duration` round-tripping.

**Negative year formatting**
`pad4` silently misbehaves for BC dates (year < 0). Either document the
limitation or handle the sign properly.

**`Duration::weeks`**
Trivial omission. `7 * days`.

**Richer `Duration` display**
`to_string_repr` currently omits zero components (e.g. `"1h"` for exactly
3600s). Decide on a canonical format and document it.

---

## v1.0 — solid release target

**Sub-second `now()` on native**
See v0.2 note. Gate the release on this — millisecond precision everywhere is
a reasonable baseline.

**`Date::parse` / `Date::format`**
Parse and format date-only strings (`2026-03-28`) without requiring a full
datetime.

**`Time::parse` / `Time::format`**
Parse and format time-only strings (`14:31:43`, `14:31:43.123Z`).

**Docs + docstring coverage**
Public API has sparse docstrings. Fill them out; `moon info` output is already
clean, just needs prose.

**mooncakes.io publish**
Fill in `moon.mod.json`: `repository`, `keywords`, `description`. Publish as
`brickfrog/tempo`.

---

## future / explicitly deferred

**Timezones**
The IANA timezone database is ~3 MB of data alone. DST rules change several
times a year. This is realistically a separate library (`brickfrog/tempo-tz`
or similar) that depends on tempo for the UTC primitives. Not in scope here.

**Locale-aware formatting**
`strftime`-style patterns, month/day names in multiple languages. Depends on
locale data, which has the same "big external dataset" problem as timezones.

**Arbitrary format strings**
`DateTime::format_with("%Y-%m-%d %H:%M:%S")`. Useful but low priority given
RFC 3339 covers most machine-readable cases.

**Leap seconds**
POSIX time ignores leap seconds (Unix timestamps count them as part of the
previous second). Correct handling requires a leap-second table, updated
periodically. Out of scope for UTC-only v1; document the assumption.

**`wasm` target** (non-GC)
Currently only `wasm-gc` is tested. The older `wasm` target uses a different
memory model and would need its own `now_wasm_legacy.mbt`.

**Calendar systems**
Julian, Hebrew, Islamic, etc. Separate library territory.
