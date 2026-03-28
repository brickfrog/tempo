// tempo — UTC-only date/time library for MoonBit
// Types: Date, Time, DateTime, Duration
// Features: Unix timestamps, RFC 3339 parsing/formatting, arithmetic

///|
/// Error type for all tempo operations.
pub(all) suberror TempoError {
  TempoError(String)
}

///|
pub impl Show for TempoError with output(self, logger) {
  match self {
    TempoError(msg) => logger.write_string("TempoError: " + msg)
  }
}

// ─── Core types ──────────────────────────────────────────────────────────────

///|
/// A calendar date in the proleptic Gregorian calendar (UTC).
pub struct Date {
  year : Int
  month : Int // 1–12
  day : Int // 1–31
} derive(Eq, Compare)

///|
/// A time of day with nanosecond precision (UTC).
pub struct Time {
  hour : Int // 0–23
  minute : Int // 0–59
  second : Int // 0–59
  nanosecond : Int // 0–999_999_999
} derive(Eq, Compare)

///|
/// A combined UTC date and time.
pub struct DateTime {
  date : Date
  time : Time
} derive(Eq, Compare)

///|
/// A signed duration stored as total nanoseconds.
pub struct Duration {
  nanoseconds : Int64
} derive(Eq, Compare)

// ─── Calendar helpers ─────────────────────────────────────────────────────────

///|
pub fn is_leap_year(year : Int) -> Bool {
  (year % 4 == 0 && year % 100 != 0) || year % 400 == 0
}

///|
pub fn days_in_month(year : Int, month : Int) -> Int {
  match month {
    1 | 3 | 5 | 7 | 8 | 10 | 12 => 31
    4 | 6 | 9 | 11 => 30
    2 => if is_leap_year(year) { 29 } else { 28 }
    _ => 0
  }
}

// Floor division for Int64 (rounds toward negative infinity).

///|
fn floor_div64(a : Int64, b : Int64) -> Int64 {
  let q = a / b
  if (a < 0L) != (b < 0L) && q * b != a {
    q - 1L
  } else {
    q
  }
}

// Howard Hinnant's civil_from_days: days-since-epoch → (year, month, day)

///|
fn civil_from_days(z : Int64) -> (Int, Int, Int) {
  let z = z + 719468L
  let era = floor_div64(z, 146097L)
  let doe = (z - era * 146097L).to_int() // 0..146096
  let yoe = (doe - doe / 1460 + doe / 36524 - doe / 146096) / 365 // 0..399
  let y = yoe + (era * 400L).to_int()
  let doy = doe - (365 * yoe + yoe / 4 - yoe / 100) // 0..365
  let mp = (5 * doy + 2) / 153 // 0..11
  let d = doy - (153 * mp + 2) / 5 + 1 // 1..31
  let m = if mp < 10 { mp + 3 } else { mp - 9 } // 1..12
  let y = if m <= 2 { y + 1 } else { y }
  (y, m, d)
}

// Howard Hinnant's days_from_civil: (year, month, day) → days-since-epoch

///|
fn days_from_civil(year : Int, month : Int, day : Int) -> Int64 {
  let y = if month <= 2 { year - 1 } else { year }
  let y64 = y.to_int64()
  let era = floor_div64(y64, 400L)
  let yoe = y64 - era * 400L // 0..399
  let m_adj = if month > 2 { month - 3 } else { month + 9 }
  let doy = (153 * m_adj + 2) / 5 + day - 1 // 0..365
  let doe = yoe * 365L + yoe / 4L - yoe / 100L + doy.to_int64() // 0..146096
  era * 146097L + doe - 719468L
}

// ─── Constructors ─────────────────────────────────────────────────────────────

///|
pub fn Date::new(year : Int, month : Int, day : Int) -> Date raise TempoError {
  if month < 1 || month > 12 {
    raise TempoError("month \{month} out of range 1–12")
  }
  let max_day = days_in_month(year, month)
  if day < 1 || day > max_day {
    raise TempoError("day \{day} out of range for \{year}-\{month}")
  }
  { year, month, day }
}

///|
/// Parse a calendar date in 'YYYY-MM-DD' format.
pub fn Date::parse(s : String) -> Date raise TempoError {
  let v = s.view()
  let (year, v) = parse_digits(v, 4)
  let v = consume(v, '-')
  let (month, v) = parse_digits(v, 2)
  let v = consume(v, '-')
  let (day, v) = parse_digits(v, 2)
  match v {
    [] => ()
    _ => raise TempoError("unexpected trailing characters")
  }
  Date::new(year, month, day)
}

///|
/// Format this date as 'YYYY-MM-DD'.
pub fn Date::format(self : Date) -> String {
  "\{pad4(self.year)}-\{pad2(self.month)}-\{pad2(self.day)}"
}

///|
pub fn Time::new(
  hour : Int,
  minute : Int,
  second : Int,
  nanosecond : Int,
) -> Time raise TempoError {
  if hour < 0 || hour > 23 {
    raise TempoError("hour \{hour} out of range 0–23")
  }
  if minute < 0 || minute > 59 {
    raise TempoError("minute \{minute} out of range 0–59")
  }
  if second < 0 || second > 59 {
    raise TempoError("second \{second} out of range 0–59")
  }
  if nanosecond < 0 || nanosecond > 999_999_999 {
    raise TempoError("nanosecond \{nanosecond} out of range 0–999_999_999")
  }
  { hour, minute, second, nanosecond }
}

///|
pub fn DateTime::new(date : Date, time : Time) -> DateTime {
  { date, time }
}

///|
/// The Unix epoch: 1970-01-01T00:00:00Z.
pub fn DateTime::epoch() -> DateTime {
  {
    date: { year: 1970, month: 1, day: 1 },
    time: { hour: 0, minute: 0, second: 0, nanosecond: 0 },
  }
}

// ─── Unix timestamp conversion ────────────────────────────────────────────────

///|
/// Convert a Unix timestamp (seconds since 1970-01-01T00:00:00Z) to DateTime.
pub fn DateTime::from_unix_seconds(ts : Int64) -> DateTime {
  let secs_per_day = 86400L
  let days = floor_div64(ts, secs_per_day)
  let sod = (ts - days * secs_per_day).to_int() // 0..86399
  let (year, month, day) = civil_from_days(days)
  let hour = sod / 3600
  let minute = sod % 3600 / 60
  let second = sod % 60
  { date: { year, month, day }, time: { hour, minute, second, nanosecond: 0 } }
}

///|
/// Convert a Unix timestamp in nanoseconds to DateTime.
pub fn DateTime::from_unix_nanos(ns : Int64) -> DateTime {
  let ts_sec = floor_div64(ns, ns_per_sec)
  let nanosecond = (ns - ts_sec * ns_per_sec).to_int()
  let dt = DateTime::from_unix_seconds(ts_sec)
  { ..dt, time: { ..dt.time, nanosecond, } }
}

///|
/// Convert this DateTime to a Unix timestamp in seconds (nanoseconds truncated).
pub fn DateTime::to_unix_seconds(self : DateTime) -> Int64 {
  let days = days_from_civil(self.date.year, self.date.month, self.date.day)
  let t = self.time
  let sod = (t.hour * 3600 + t.minute * 60 + t.second).to_int64()
  days * 86400L + sod
}

///|
/// Convert this DateTime to a Unix timestamp in nanoseconds.
pub fn DateTime::to_unix_nanos(self : DateTime) -> Int64 {
  self.to_unix_seconds() * 1_000_000_000L + self.time.nanosecond.to_int64()
}

// ─── Duration constructors ────────────────────────────────────────────────────

///|
let ns_per_us : Int64 = 1_000L

///|
let ns_per_ms : Int64 = 1_000_000L

///|
let ns_per_sec : Int64 = 1_000_000_000L

///|
let ns_per_min : Int64 = 60_000_000_000L

///|
let ns_per_hour : Int64 = 3_600_000_000_000L

///|
pub fn Duration::nanoseconds(ns : Int64) -> Duration {
  { nanoseconds: ns }
}

///|
pub fn Duration::days(d : Int64) -> Duration {
  { nanoseconds: d * 86_400L * ns_per_sec }
}

///|
pub fn Duration::microseconds(us : Int64) -> Duration {
  { nanoseconds: us * ns_per_us }
}

///|
pub fn Duration::milliseconds(ms : Int64) -> Duration {
  { nanoseconds: ms * ns_per_ms }
}

///|
pub fn Duration::seconds(s : Int64) -> Duration {
  { nanoseconds: s * ns_per_sec }
}

///|
pub fn Duration::minutes(m : Int64) -> Duration {
  { nanoseconds: m * ns_per_min }
}

///|
pub fn Duration::hours(h : Int64) -> Duration {
  { nanoseconds: h * ns_per_hour }
}

// ─── Duration accessors ───────────────────────────────────────────────────────

///|
pub fn Duration::as_nanoseconds(self : Duration) -> Int64 {
  self.nanoseconds
}

///|
pub fn Duration::as_microseconds(self : Duration) -> Int64 {
  self.nanoseconds / ns_per_us
}

///|
pub fn Duration::as_milliseconds(self : Duration) -> Int64 {
  self.nanoseconds / ns_per_ms
}

///|
pub fn Duration::as_seconds(self : Duration) -> Int64 {
  self.nanoseconds / ns_per_sec
}

///|
pub fn Duration::as_minutes(self : Duration) -> Int64 {
  self.nanoseconds / ns_per_min
}

///|
pub fn Duration::as_hours(self : Duration) -> Int64 {
  self.nanoseconds / ns_per_hour
}

// ─── Duration arithmetic ──────────────────────────────────────────────────────

///|
pub impl Add for Duration with add(self, other : Duration) -> Duration {
  { nanoseconds: self.nanoseconds + other.nanoseconds }
}

///|
pub impl Sub for Duration with sub(self, other : Duration) -> Duration {
  { nanoseconds: self.nanoseconds - other.nanoseconds }
}

///|
pub impl Neg for Duration with neg(self) -> Duration {
  { nanoseconds: -self.nanoseconds }
}

// ─── DateTime arithmetic ──────────────────────────────────────────────────────

///|
/// Add a Duration to this DateTime.
pub fn DateTime::add(self : DateTime, d : Duration) -> DateTime {
  DateTime::from_unix_nanos(self.to_unix_nanos() + d.nanoseconds)
}

///|
/// Subtract a Duration from this DateTime.
pub fn DateTime::sub(self : DateTime, d : Duration) -> DateTime {
  DateTime::from_unix_nanos(self.to_unix_nanos() - d.nanoseconds)
}

///|
/// Compute `self - other` as a Duration (may be negative).
pub fn DateTime::diff(self : DateTime, other : DateTime) -> Duration {
  { nanoseconds: self.to_unix_nanos() - other.to_unix_nanos() }
}

// ─── Formatting ───────────────────────────────────────────────────────────────

// Zero-pad an integer to 2 digits.

///|
fn pad2(n : Int) -> String {
  if n < 10 {
    "0\{n}"
  } else {
    "\{n}"
  }
}

// Zero-pad an integer to 4 digits.

///|
fn pad4(n : Int) -> String {
  if n < 10 {
    "000\{n}"
  } else if n < 100 {
    "00\{n}"
  } else if n < 1000 {
    "0\{n}"
  } else {
    "\{n}"
  }
}

///|
fn pad9(n : Int) -> String {
  if n < 10 {
    "00000000\{n}"
  } else if n < 100 {
    "0000000\{n}"
  } else if n < 1000 {
    "000000\{n}"
  } else if n < 10000 {
    "00000\{n}"
  } else if n < 100000 {
    "0000\{n}"
  } else if n < 1000000 {
    "000\{n}"
  } else if n < 10000000 {
    "00\{n}"
  } else if n < 100000000 {
    "0\{n}"
  } else {
    "\{n}"
  }
}

// Format nanoseconds as a fractional-seconds string, trimming trailing zeros.

///|
fn fmt_frac(ns : Int) -> String {
  let s = pad9(ns)
  let mut end = s.length()
  while end > 1 && s[end - 1] == '0' {
    end -= 1
  }
  s[:end].to_string()
}

///|
/// Format this DateTime as an RFC 3339 / ISO 8601 string (UTC, 'Z' suffix).
/// Sub-second precision is included only when nanoseconds ≠ 0.
pub fn DateTime::format(self : DateTime) -> String {
  let d = self.date
  let t = self.time
  let base = "\{pad4(d.year)}-\{pad2(d.month)}-\{pad2(d.day)}T\{pad2(t.hour)}:\{pad2(t.minute)}:\{pad2(t.second)}"
  if t.nanosecond == 0 {
    base + "Z"
  } else {
    base + "." + fmt_frac(t.nanosecond) + "Z"
  }
}

///|
/// Format this time as `HH:MM:SS` or `HH:MM:SS.fraction` (nanoseconds trimmed,
/// consistent with `DateTime::format`).
pub fn Time::format(self : Time) -> String {
  let base = "\{pad2(self.hour)}:\{pad2(self.minute)}:\{pad2(self.second)}"
  if self.nanosecond == 0 {
    base
  } else {
    base + "." + fmt_frac(self.nanosecond)
  }
}

///|
pub impl Show for Date with output(self, logger) {
  logger.write_string(
    "\{pad4(self.year)}-\{pad2(self.month)}-\{pad2(self.day)}",
  )
}

///|
pub impl Show for Time with output(self, logger) {
  logger.write_string(self.format())
}

///|
pub impl Show for DateTime with output(self, logger) {
  logger.write_string(self.format())
}

///|
pub impl Show for Duration with output(self, logger) {
  logger.write_string(self.to_string_repr())
}

///|
fn Duration::to_string_repr(self : Duration) -> String {
  let ns = self.nanoseconds
  if ns == 0L {
    return "0s"
  }
  let (sign, abs_ns) = if ns < 0L { ("-", -ns) } else { ("", ns) }
  let h = abs_ns / ns_per_hour
  let rem = abs_ns - h * ns_per_hour
  let m = rem / ns_per_min
  let rem = rem - m * ns_per_min
  let s = rem / ns_per_sec
  let rem = rem - s * ns_per_sec
  let ms = rem / ns_per_ms
  let rem = rem - ms * ns_per_ms
  let us = rem / ns_per_us
  let sub_ns = (rem - us * ns_per_us).to_int()
  let buf = StringBuilder::new()
  buf.write_string(sign)
  if h > 0L {
    buf.write_string("\{h}h")
  }
  if m > 0L {
    buf.write_string("\{m}m")
  }
  if s > 0L || (h == 0L && m == 0L) {
    buf.write_string("\{s}s")
  }
  if ms > 0L {
    buf.write_string("\{ms}ms")
  }
  if us > 0L {
    buf.write_string("\{us}µs")
  }
  if sub_ns > 0 {
    buf.write_string("\{sub_ns}ns")
  }
  buf.to_string()
}

// ─── RFC 3339 parsing ─────────────────────────────────────────────────────────

// Parse exactly `n` ASCII decimal digits from a StringView,
// returning (value, rest).

///|
fn parse_digits(
  view : StringView,
  n : Int,
) -> (Int, StringView) raise TempoError {
  loop (view, n, 0) {
    (v, 0, acc) => (acc, v)
    (v, remaining, acc) =>
      match v {
        ['0'..='9' as c, .. rest] =>
          continue (rest, remaining - 1, acc * 10 + c.to_int() - '0')
        [c, ..] => raise TempoError("expected digit, got '\{c}'")
        [] => raise TempoError("unexpected end of input, expected digit")
      }
  }
}

// Consume a literal character, returning the rest.

///|
fn consume(view : StringView, expected : Char) -> StringView raise TempoError {
  match view {
    [c, .. rest] if c == expected => rest
    [c, ..] => raise TempoError("expected '\{expected}', got '\{c}'")
    [] => raise TempoError("unexpected end of input, expected '\{expected}'")
  }
}

// Parse the fractional-seconds part (digits after '.'), normalize to nanoseconds.
// Collects up to 9 significant digits (truncating, not rounding), then skips
// any remaining digits to avoid Int overflow.

///|
fn parse_frac_ns(view : StringView) -> (Int, StringView) raise TempoError {
  loop (view, 0, 0) {
    (v, count, acc) =>
      match v {
        ['0'..='9' as c, .. rest] =>
          if count < 9 {
            // Still within 9 significant digits — accumulate normally.
            continue (rest, count + 1, acc * 10 + c.to_int() - '0')
          } else {
            // Beyond 9 digits: skip without touching acc to avoid overflow.
            continue (rest, count + 1, acc)
          }
        _ => {
          if count == 0 {
            raise TempoError("expected digits after '.'")
          }
          // Pad up to 9 digits if fewer were provided (e.g. ".1" → 100_000_000).
          let ns = loop (acc, 9 - count.clamp(min=0, max=9)) {
            (a, 0) => a
            (a, r) => continue (a * 10, r - 1)
          }
          (ns, v)
        }
      }
  }
}

///|
/// Parse an RFC 3339 / ISO 8601 datetime string.
/// Only UTC is accepted: 'Z', '+00:00', or '-00:00'.
pub fn DateTime::parse(s : String) -> DateTime raise TempoError {
  let v = s.view()
  let (year, v) = parse_digits(v, 4)
  let v = consume(v, '-')
  let (month, v) = parse_digits(v, 2)
  let v = consume(v, '-')
  let (day, v) = parse_digits(v, 2)
  // Date/time separator: T or t
  let v = match v {
    ['T' | 't', .. rest] => rest
    [c, ..] => raise TempoError("expected 'T', got '\{c}'")
    [] => raise TempoError("unexpected end of input, expected 'T'")
  }
  let (hour, v) = parse_digits(v, 2)
  let v = consume(v, ':')
  let (minute, v) = parse_digits(v, 2)
  let v = consume(v, ':')
  let (second, v) = parse_digits(v, 2)
  // Optional fractional seconds
  let (nanosecond, v) = match v {
    ['.', .. rest] => parse_frac_ns(rest)
    _ => (0, v)
  }
  // Timezone: Z or ±HH:MM (only UTC accepted)
  let v = match v {
    ['Z' | 'z', .. rest] => rest
    ['+' | '-' as sign, .. rest] => {
      let (tz_h, rest) = parse_digits(rest, 2)
      let rest = consume(rest, ':')
      let (tz_m, rest) = parse_digits(rest, 2)
      if tz_h != 0 || tz_m != 0 {
        raise TempoError(
          "non-UTC offset '\{sign}\{pad2(tz_h)}:\{pad2(tz_m)}' not supported",
        )
      }
      rest
    }
    [c, ..] => raise TempoError("expected timezone, got '\{c}'")
    [] => raise TempoError("unexpected end of input, expected timezone")
  }
  // Must have consumed the entire string
  match v {
    [] => ()
    _ => raise TempoError("unexpected trailing characters")
  }
  let date = Date::new(year, month, day)
  let time = Time::new(hour, minute, second, nanosecond)
  { date, time }
}

///|
/// Parse a time-of-day string: `HH:MM:SS` or `HH:MM:SS.fraction`.
pub fn Time::parse(s : String) -> Time raise TempoError {
  let v = s.view()
  let (hour, v) = parse_digits(v, 2)
  let v = consume(v, ':')
  let (minute, v) = parse_digits(v, 2)
  let v = consume(v, ':')
  let (second, v) = parse_digits(v, 2)
  let (nanosecond, v) = match v {
    ['.', .. rest] => parse_frac_ns(rest)
    _ => (0, v)
  }
  match v {
    [] => ()
    _ => raise TempoError("unexpected trailing characters")
  }
  Time::new(hour, minute, second, nanosecond)
}
