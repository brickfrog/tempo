// tempo — UTC-only date/time library for MoonBit
// Types: Date, Time, DateTime, FixedOffsetDateTime, Duration
// Features: Unix timestamps, RFC 3339 parsing/formatting, arithmetic

///|
/// Error type for all tempo operations.
pub(all) suberror TempoError {
  TempoError(String)
}

///|
pub impl Show for TempoError with fn output(self, logger) {
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
} derive(Eq, Compare, Hash)

///|
/// A calendar date interval with an inclusive end date: `[start, end]`.
///
/// This mirrors NodaTime's DateInterval-vs-Interval convention split:
/// DateInterval is inclusive-end for whole calendar dates, while `Interval` is
/// half-open for instants. Assumes `start <= end`; methods do not validate
/// inverted intervals.
pub(all) struct DateInterval {
  start : Date
  end : Date
} derive(Eq)

///|
/// ISO 8601 weekday, ordered Monday through Sunday.
pub(all) enum Weekday {
  Monday
  Tuesday
  Wednesday
  Thursday
  Friday
  Saturday
  Sunday
} derive(Eq, Compare, Hash)

///|
/// ISO 8601 weekday number: Monday = 1 through Sunday = 7.
pub fn Weekday::to_int(self : Weekday) -> Int {
  match self {
    Monday => 1
    Tuesday => 2
    Wednesday => 3
    Thursday => 4
    Friday => 5
    Saturday => 6
    Sunday => 7
  }
}

///|
/// Convert an ISO weekday number (1..7) to a `Weekday`.
pub fn Weekday::from_int(n : Int) -> Weekday? {
  match n {
    1 => Some(Monday)
    2 => Some(Tuesday)
    3 => Some(Wednesday)
    4 => Some(Thursday)
    5 => Some(Friday)
    6 => Some(Saturday)
    7 => Some(Sunday)
    _ => None
  }
}

///|
/// ISO 8601 weekday number: Monday = 1 through Sunday = 7.
pub fn Weekday::number_from_monday(self : Weekday) -> Int {
  self.to_int()
}

///|
/// Sunday-based weekday number: Sunday = 1 through Saturday = 7.
pub fn Weekday::number_from_sunday(self : Weekday) -> Int {
  match self {
    Sunday => 1
    Monday => 2
    Tuesday => 3
    Wednesday => 4
    Thursday => 5
    Friday => 6
    Saturday => 7
  }
}

///|
/// Next weekday, wrapping Sunday to Monday.
pub fn Weekday::next(self : Weekday) -> Weekday {
  match self {
    Monday => Tuesday
    Tuesday => Wednesday
    Wednesday => Thursday
    Thursday => Friday
    Friday => Saturday
    Saturday => Sunday
    Sunday => Monday
  }
}

///|
/// Previous weekday, wrapping Monday to Sunday.
pub fn Weekday::previous(self : Weekday) -> Weekday {
  match self {
    Monday => Sunday
    Tuesday => Monday
    Wednesday => Tuesday
    Thursday => Wednesday
    Friday => Thursday
    Saturday => Friday
    Sunday => Saturday
  }
}

///|
pub impl Show for Weekday with fn output(self, logger) {
  match self {
    Monday => logger.write_string("Monday")
    Tuesday => logger.write_string("Tuesday")
    Wednesday => logger.write_string("Wednesday")
    Thursday => logger.write_string("Thursday")
    Friday => logger.write_string("Friday")
    Saturday => logger.write_string("Saturday")
    Sunday => logger.write_string("Sunday")
  }
}

///|
/// Calendar month, ordered January through December.
pub(all) enum Month {
  January
  February
  March
  April
  May
  June
  July
  August
  September
  October
  November
  December
} derive(Eq, Compare, Hash)

///|
/// Calendar month number: January = 1 through December = 12.
pub fn Month::to_int(self : Month) -> Int {
  match self {
    January => 1
    February => 2
    March => 3
    April => 4
    May => 5
    June => 6
    July => 7
    August => 8
    September => 9
    October => 10
    November => 11
    December => 12
  }
}

///|
/// Convert a calendar month number (1..12) to a `Month`.
pub fn Month::from_int(n : Int) -> Month? {
  match n {
    1 => Some(January)
    2 => Some(February)
    3 => Some(March)
    4 => Some(April)
    5 => Some(May)
    6 => Some(June)
    7 => Some(July)
    8 => Some(August)
    9 => Some(September)
    10 => Some(October)
    11 => Some(November)
    12 => Some(December)
    _ => None
  }
}

///|
/// Next month, wrapping December to January.
pub fn Month::next(self : Month) -> Month {
  match self {
    January => February
    February => March
    March => April
    April => May
    May => June
    June => July
    July => August
    August => September
    September => October
    October => November
    November => December
    December => January
  }
}

///|
/// Previous month, wrapping January to December.
pub fn Month::previous(self : Month) -> Month {
  match self {
    January => December
    February => January
    March => February
    April => March
    May => April
    June => May
    July => June
    August => July
    September => August
    October => September
    November => October
    December => November
  }
}

///|
/// Number of days in this month for `year`.
pub fn Month::days_in(self : Month, year : Int) -> Int {
  days_in_month(year, self.to_int())
}

///|
pub impl Show for Month with fn output(self, logger) {
  match self {
    January => logger.write_string("January")
    February => logger.write_string("February")
    March => logger.write_string("March")
    April => logger.write_string("April")
    May => logger.write_string("May")
    June => logger.write_string("June")
    July => logger.write_string("July")
    August => logger.write_string("August")
    September => logger.write_string("September")
    October => logger.write_string("October")
    November => logger.write_string("November")
    December => logger.write_string("December")
  }
}

///|
/// A time of day with nanosecond precision (UTC).
pub struct Time {
  hour : Int // 0–23
  minute : Int // 0–59
  second : Int // 0–59
  nanosecond : Int // 0–999_999_999
} derive(Eq, Compare, Hash)

///|
/// Units supported by `DateTime::truncate_to` and `DateTime::round_to`, ordered
/// smallest to largest.
pub(all) enum TimeUnit {
  Second
  Minute
  Hour
  Day
} derive(Eq, Compare, Hash)

///|
pub impl Show for TimeUnit with fn output(self, logger) {
  match self {
    Second => logger.write_string("Second")
    Minute => logger.write_string("Minute")
    Hour => logger.write_string("Hour")
    Day => logger.write_string("Day")
  }
}

///|
/// Rounding modes for `DateTime::round_to`, ordered from earlier-boundary
/// preference to nearest-boundary behavior.
pub(all) enum RoundMode {
  Floor
  Ceil
  HalfExpand
} derive(Eq, Compare, Hash)

///|
pub impl Show for RoundMode with fn output(self, logger) {
  match self {
    Floor => logger.write_string("Floor")
    Ceil => logger.write_string("Ceil")
    HalfExpand => logger.write_string("HalfExpand")
  }
}

///|
/// A combined UTC date and time.
pub struct DateTime {
  date : Date
  time : Time
} derive(Eq, Compare, Hash)

///|
/// A UTC instant paired with a fixed numeric display offset.
///
/// `DateTime` is tempo's primary timestamp type. Use `FixedOffsetDateTime` only
/// for wire formats and interop surfaces where a timestamp carries an explicit
/// numeric offset but no IANA time zone. The stored instant is normalized UTC;
/// the offset is retained only as a display hint.
pub struct FixedOffsetDateTime {
  priv utc : DateTime
  priv offset_seconds : Int
} derive(Eq, Compare, Hash)

///|
/// A DateTime interval with a half-open end instant: `[start, end)`.
///
/// This mirrors NodaTime's DateInterval-vs-Interval convention split:
/// `DateInterval` is inclusive-end for calendar dates, while Interval is
/// half-open for instants. Assumes `start <= end`; methods do not validate
/// inverted intervals.
pub(all) struct Interval {
  start : DateTime
  end : DateTime
} derive(Eq)

///|
/// A signed duration stored as total nanoseconds.
pub struct Duration {
  nanoseconds : Int64
} derive(Eq, Compare, Hash)

// ─── Calendar helpers ─────────────────────────────────────────────────────────

///|
/// `true` if `year` is a leap year in the proleptic Gregorian calendar.
pub fn is_leap_year(year : Int) -> Bool {
  (year % 4 == 0 && year % 100 != 0) || year % 400 == 0
}

///|
/// Number of days in the given month (1–12). Returns `0` for invalid month
/// values outside 1–12.
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
/// Create a `Date`, validating that `month` is 1–12 and `day` fits the
/// calendar month (accounting for leap years in February).
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
/// Create a `Date` from `year` and day-of-year in 1..365, or 1..366 for a
/// leap year.
pub fn Date::from_ordinal(
  year : Int,
  day_of_year : Int,
) -> Date raise TempoError {
  let days_in_year = if is_leap_year(year) { 366 } else { 365 }
  if day_of_year < 1 || day_of_year > days_in_year {
    raise TempoError("day_of_year \{day_of_year} out of range for year \{year}")
  }
  Date::new(year, 1, 1).add_days(day_of_year - 1)
}

// ─── Date arithmetic ──────────────────────────────────────────────────────────

///|
fn shift_year_month(year : Int, month : Int, months : Int64) -> (Int, Int) {
  let total = year.to_int64() * 12L + (month - 1).to_int64() + months
  let new_year = floor_div64(total, 12L).to_int()
  let new_month = floor_mod64(total, 12L).to_int() + 1
  (new_year, new_month)
}

///|
fn Date::add_months64(self : Date, months : Int64) -> Date {
  let (year, month) = shift_year_month(self.year, self.month, months)
  let max_day = days_in_month(year, month)
  let day = if self.day > max_day { max_day } else { self.day }
  { year, month, day }
}

///|
/// Add a signed number of calendar months to this date.
///
/// If the original day does not exist in the target month, the result is
/// clamped to that month's last day. Clamping is non-sticky: 2024-02-28 plus
/// one month is 2024-03-28, not 2024-03-31.
pub fn Date::add_months(self : Date, months : Int) -> Date {
  self.add_months64(months.to_int64())
}

///|
/// Add a signed number of calendar years to this date.
///
/// If the original day does not exist in the target year/month, the result is
/// clamped to that month's last day, so leap day moves to February 28 in
/// non-leap target years.
pub fn Date::add_years(self : Date, years : Int) -> Date {
  self.add_months64(years.to_int64() * 12L)
}

///|
/// Return a copy of this date with `year` replaced, validating the result.
pub fn Date::with_year(self : Date, year : Int) -> Date raise TempoError {
  Date::new(year, self.month, self.day)
}

///|
/// Return a copy of this date with `month` replaced, validating the result.
///
/// This does not clamp. Chaining with `with_day` can raise on an intermediate
/// invalid date before a later update would make it valid.
pub fn Date::with_month(self : Date, month : Int) -> Date raise TempoError {
  Date::new(self.year, month, self.day)
}

///|
/// Return a copy of this date with `day` replaced, validating the result.
///
/// This does not clamp. Chaining with `with_month` can raise on an intermediate
/// invalid date before a later update would make it valid.
pub fn Date::with_day(self : Date, day : Int) -> Date raise TempoError {
  Date::new(self.year, self.month, day)
}

///|
/// Return the first day of this date's calendar month.
pub fn Date::start_of_month(self : Date) -> Date {
  { ..self, day: 1 }
}

///|
/// Return the last day of this date's calendar month.
pub fn Date::end_of_month(self : Date) -> Date {
  { ..self, day: days_in_month(self.year, self.month) }
}

///|
/// Return the first day of this date's calendar year.
pub fn Date::start_of_year(self : Date) -> Date {
  { ..self, month: 1, day: 1 }
}

///|
/// Return the last day of this date's calendar year.
pub fn Date::end_of_year(self : Date) -> Date {
  { ..self, month: 12, day: 31 }
}

///|
/// Add a signed number of calendar days to this date (proleptic Gregorian).
pub fn Date::add_days(self : Date, days : Int) -> Date {
  let base = days_from_civil(self.year, self.month, self.day)
  let (y, m, d) = civil_from_days(base + days.to_int64())
  { year: y, month: m, day: d }
}

///|
/// ISO 8601 weekday: Monday = 1 through Sunday = 7.
pub fn Date::day_of_week(self : Date) -> Int {
  let d = days_from_civil(self.year, self.month, self.day)
  // Align so Monday (1970-01-05, etc.) is remainder 0.
  let idx = floor_mod64(d - 4L, 7L)
  idx.to_int() + 1
}

///|
/// ISO 8601 weekday for this date.
pub fn Date::weekday(self : Date) -> Weekday {
  match self.day_of_week() {
    1 => Monday
    2 => Tuesday
    3 => Wednesday
    4 => Thursday
    5 => Friday
    6 => Saturday
    7 => Sunday
    _ => abort("Date::day_of_week returned out-of-range weekday")
  }
}

///|
fn positive_mod7(n : Int) -> Int {
  (n % 7 + 7) % 7
}

///|
/// Nearest date strictly after this date that falls on `wd`.
pub fn Date::next(self : Date, wd : Weekday) -> Date {
  let raw = positive_mod7(wd.to_int() - self.weekday().to_int())
  let delta = if raw == 0 { 7 } else { raw }
  self.add_days(delta)
}

///|
/// Nearest date strictly before this date that falls on `wd`.
pub fn Date::previous(self : Date, wd : Weekday) -> Date {
  let raw = positive_mod7(self.weekday().to_int() - wd.to_int())
  let delta = if raw == 0 { 7 } else { raw }
  self.add_days(-delta)
}

///|
/// This date if it falls on `wd`, otherwise the next such date.
pub fn Date::next_or_same(self : Date, wd : Weekday) -> Date {
  let delta = positive_mod7(wd.to_int() - self.weekday().to_int())
  self.add_days(delta)
}

///|
/// This date if it falls on `wd`, otherwise the previous such date.
pub fn Date::previous_or_same(self : Date, wd : Weekday) -> Date {
  let delta = positive_mod7(self.weekday().to_int() - wd.to_int())
  self.add_days(-delta)
}

///|
/// The nth occurrence of `wd` in `year`/`month`.
///
/// Positive `n` counts from the start of the month; negative `n` counts from
/// the end, so `n == -1` is the last occurrence.
pub fn Date::nth_weekday_of_month(
  year : Int,
  month : Int,
  wd : Weekday,
  n : Int,
) -> Date raise TempoError {
  if n == 0 {
    raise TempoError("weekday occurrence must not be zero")
  }
  if n > 0 {
    let first = Date::new(year, month, 1)
    let offset = positive_mod7(wd.to_int() - first.weekday().to_int())
    let first_match_day = 1 + offset
    let day = first_match_day.to_int64() + 7L * (n.to_int64() - 1L)
    let max_day = days_in_month(year, month).to_int64()
    if day < 1L || day > max_day {
      raise TempoError("weekday occurrence does not exist in month")
    } else {
      Date::new(year, month, day.to_int())
    }
  } else {
    let last_day = days_in_month(year, month)
    let last = Date::new(year, month, last_day)
    let back = positive_mod7(last.weekday().to_int() - wd.to_int())
    let last_match_day = last_day - back
    let day = last_match_day.to_int64() + 7L * (n.to_int64() + 1L)
    let max_day = last_day.to_int64()
    if day < 1L || day > max_day {
      raise TempoError("weekday occurrence does not exist in month")
    } else {
      Date::new(year, month, day.to_int())
    }
  }
}

///|
/// Calendar month for this date.
pub fn Date::month_enum(self : Date) -> Month {
  match Month::from_int(self.month) {
    Some(month) => month
    None => abort("Date month out of range")
  }
}

///|
/// Day of year in 1..366 (1 = January 1).
pub fn Date::day_of_year(self : Date) -> Int {
  let y = self.year
  let start = days_from_civil(y, 1, 1)
  let today = days_from_civil(self.year, self.month, self.day)
  (today - start).to_int() + 1
}

///|
/// Calendar days from `self` to `other` (`other` minus `self`). Negative if `other` is earlier.
pub fn Date::days_until(self : Date, other : Date) -> Int {
  let a = days_from_civil(self.year, self.month, self.day)
  let b = days_from_civil(other.year, other.month, other.day)
  (b - a).to_int()
}

///|
/// `true` if this date is earlier than `other`.
pub fn Date::is_before(self : Date, other : Date) -> Bool {
  self.compare(other) < 0
}

///|
/// `true` if this date is later than `other`.
pub fn Date::is_after(self : Date, other : Date) -> Bool {
  self.compare(other) > 0
}

///|
/// Return the earlier of this date and `other`.
pub fn Date::min(self : Date, other : Date) -> Date {
  if self.compare(other) <= 0 {
    self
  } else {
    other
  }
}

///|
/// Return the later of this date and `other`.
pub fn Date::max(self : Date, other : Date) -> Date {
  if self.compare(other) >= 0 {
    self
  } else {
    other
  }
}

///|
/// Clamp this date to the inclusive range `[lo, hi]`. Assumes `lo <= hi`.
pub fn Date::clamp(self : Date, lo : Date, hi : Date) -> Date {
  if self.compare(lo) < 0 {
    lo
  } else if self.compare(hi) > 0 {
    hi
  } else {
    self
  }
}

// ─── DateInterval helpers ────────────────────────────────────────────────────

///|
/// `true` if `d` is in this inclusive-end date interval `[start, end]`.
pub fn DateInterval::contains(self : DateInterval, d : Date) -> Bool {
  self.start <= d && d <= self.end
}

///|
/// `true` if this inclusive-end date interval shares at least one date with
/// `other`.
pub fn DateInterval::overlaps(
  self : DateInterval,
  other : DateInterval,
) -> Bool {
  self.start <= other.end && other.start <= self.end
}

///|
/// Return the inclusive-end overlap between this date interval and `other`.
pub fn DateInterval::intersection(
  self : DateInterval,
  other : DateInterval,
) -> DateInterval? {
  let s = self.start.max(other.start)
  let e = self.end.min(other.end)
  if s <= e {
    Some({ start: s, end: e })
  } else {
    None
  }
}

///|
/// Inclusive day count for this date interval.
pub fn DateInterval::length_in_days(self : DateInterval) -> Int {
  self.start.days_until(self.end) + 1
}

///|
fn floor_mod64(a : Int64, b : Int64) -> Int64 {
  a - floor_div64(a, b) * b
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
/// Format this date as 'YYYY-DDD', where `DDD` is day-of-year in 001..366.
pub fn Date::format_ordinal(self : Date) -> String {
  "\{pad4_year(self.year)}-\{pad3(self.day_of_year())}"
}

///|
/// Create a `Time`, validating that each field is within its canonical range:
/// `hour` 0–23, `minute` 0–59, `second` 0–59, `nanosecond` 0–999_999_999.
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
/// Return a copy of this time with `hour` replaced, validating the result.
pub fn Time::with_hour(self : Time, hour : Int) -> Time raise TempoError {
  Time::new(hour, self.minute, self.second, self.nanosecond)
}

///|
/// Return a copy of this time with `minute` replaced, validating the result.
pub fn Time::with_minute(self : Time, minute : Int) -> Time raise TempoError {
  Time::new(self.hour, minute, self.second, self.nanosecond)
}

///|
/// Return a copy of this time with `second` replaced, validating the result.
pub fn Time::with_second(self : Time, second : Int) -> Time raise TempoError {
  Time::new(self.hour, self.minute, second, self.nanosecond)
}

///|
/// Return a copy of this time with `nanosecond` replaced, validating the result.
pub fn Time::with_nanosecond(
  self : Time,
  nanosecond : Int,
) -> Time raise TempoError {
  Time::new(self.hour, self.minute, self.second, nanosecond)
}

///|
/// `true` if this time is earlier than `other`.
pub fn Time::is_before(self : Time, other : Time) -> Bool {
  self.compare(other) < 0
}

///|
/// `true` if this time is later than `other`.
pub fn Time::is_after(self : Time, other : Time) -> Bool {
  self.compare(other) > 0
}

///|
/// Return the earlier of this time and `other`.
pub fn Time::min(self : Time, other : Time) -> Time {
  if self.compare(other) <= 0 {
    self
  } else {
    other
  }
}

///|
/// Return the later of this time and `other`.
pub fn Time::max(self : Time, other : Time) -> Time {
  if self.compare(other) >= 0 {
    self
  } else {
    other
  }
}

///|
/// Clamp this time to the inclusive range `[lo, hi]`. Assumes `lo <= hi`.
pub fn Time::clamp(self : Time, lo : Time, hi : Time) -> Time {
  if self.compare(lo) < 0 {
    lo
  } else if self.compare(hi) > 0 {
    hi
  } else {
    self
  }
}

///|
/// Create a `DateTime` from a validated `Date` and `Time`.
/// Both arguments should be constructed via `Date::new` / `Time::new` (which
/// validate). This constructor performs no additional checks.
pub fn DateTime::new(date : Date, time : Time) -> DateTime {
  { date, time }
}

///|
/// Return the date component of this `DateTime`.
pub fn DateTime::to_date(self : DateTime) -> Date {
  self.date
}

///|
/// Return the time component of this `DateTime`.
pub fn DateTime::to_time(self : DateTime) -> Time {
  self.time
}

///|
/// Bundle a UTC instant with a fixed numeric display offset in seconds.
///
/// The `utc` argument is the UTC instant and is stored as-is. `DateTime`
/// remains tempo's primary timestamp type; this wrapper is for wire-format
/// interop when a timestamp carries an explicit numeric offset but no IANA
/// time zone.
///
/// Raises `TempoError` when `offset_seconds` is not whole-minute granularity or
/// is outside the RFC 3339 fixed-offset range ±23:59.
pub fn FixedOffsetDateTime::from_datetime_and_offset(
  utc : DateTime,
  offset_seconds : Int,
) -> FixedOffsetDateTime raise TempoError {
  validate_fixed_offset_seconds(offset_seconds)
  { utc, offset_seconds }
}

///|
fn validate_fixed_offset_seconds(offset_seconds : Int) -> Unit raise TempoError {
  if offset_seconds % 60 != 0 {
    raise TempoError("fixed offset must be whole-minute granularity")
  }
  let max_offset_seconds = 23 * 3600 + 59 * 60
  if offset_seconds < -max_offset_seconds || offset_seconds > max_offset_seconds {
    raise TempoError("fixed offset out of RFC 3339 range ±23:59")
  }
}

///|
/// Return the stored UTC instant.
pub fn FixedOffsetDateTime::to_utc(self : FixedOffsetDateTime) -> DateTime {
  self.utc
}

///|
/// Return the retained fixed display offset in seconds.
pub fn FixedOffsetDateTime::offset_seconds(self : FixedOffsetDateTime) -> Int {
  self.offset_seconds
}

///|
/// Return a copy of this `DateTime` with `date` replaced.
pub fn DateTime::with_date(self : DateTime, date : Date) -> DateTime {
  { ..self, date, }
}

///|
/// Return a copy of this `DateTime` with `time` replaced.
pub fn DateTime::with_time(self : DateTime, time : Time) -> DateTime {
  { ..self, time, }
}

///|
/// Return a copy of this `DateTime` with its date year replaced.
pub fn DateTime::with_year(
  self : DateTime,
  year : Int,
) -> DateTime raise TempoError {
  { ..self, date: self.date.with_year(year) }
}

///|
/// Return a copy of this `DateTime` with its date month replaced.
pub fn DateTime::with_month(
  self : DateTime,
  month : Int,
) -> DateTime raise TempoError {
  { ..self, date: self.date.with_month(month) }
}

///|
/// Return a copy of this `DateTime` with its date day replaced.
pub fn DateTime::with_day(
  self : DateTime,
  day : Int,
) -> DateTime raise TempoError {
  { ..self, date: self.date.with_day(day) }
}

///|
/// Return a copy of this `DateTime` with its time hour replaced.
pub fn DateTime::with_hour(
  self : DateTime,
  hour : Int,
) -> DateTime raise TempoError {
  { ..self, time: self.time.with_hour(hour) }
}

///|
/// Return a copy of this `DateTime` with its time minute replaced.
pub fn DateTime::with_minute(
  self : DateTime,
  minute : Int,
) -> DateTime raise TempoError {
  { ..self, time: self.time.with_minute(minute) }
}

///|
/// Return a copy of this `DateTime` with its time second replaced.
pub fn DateTime::with_second(
  self : DateTime,
  second : Int,
) -> DateTime raise TempoError {
  { ..self, time: self.time.with_second(second) }
}

///|
/// Return a copy of this `DateTime` with its time nanosecond replaced.
pub fn DateTime::with_nanosecond(
  self : DateTime,
  nanosecond : Int,
) -> DateTime raise TempoError {
  { ..self, time: self.time.with_nanosecond(nanosecond) }
}

///|
/// The Unix epoch: 1970-01-01T00:00:00Z.
pub fn DateTime::epoch() -> DateTime {
  {
    date: { year: 1970, month: 1, day: 1 },
    time: { hour: 0, minute: 0, second: 0, nanosecond: 0 },
  }
}

///|
/// Return this DateTime at the start of its calendar month.
/// Preserves the time-of-day; rebuild with `DateTime::new` and a zero `Time` if
/// midnight is desired.
pub fn DateTime::start_of_month(self : DateTime) -> DateTime {
  DateTime::new(self.date.start_of_month(), self.time)
}

///|
/// Return this DateTime at the end of its calendar month.
/// Preserves the time-of-day; rebuild with `DateTime::new` and a zero `Time` if
/// midnight is desired.
pub fn DateTime::end_of_month(self : DateTime) -> DateTime {
  DateTime::new(self.date.end_of_month(), self.time)
}

///|
/// Return this DateTime at the start of its calendar year.
/// Preserves the time-of-day; rebuild with `DateTime::new` and a zero `Time` if
/// midnight is desired.
pub fn DateTime::start_of_year(self : DateTime) -> DateTime {
  DateTime::new(self.date.start_of_year(), self.time)
}

///|
/// Return this DateTime at the end of its calendar year.
/// Preserves the time-of-day; rebuild with `DateTime::new` and a zero `Time` if
/// midnight is desired.
pub fn DateTime::end_of_year(self : DateTime) -> DateTime {
  DateTime::new(self.date.end_of_year(), self.time)
}

///|
/// Return this DateTime at the start of its calendar day.
pub fn DateTime::start_of_day(self : DateTime) -> DateTime {
  { ..self, time: { hour: 0, minute: 0, second: 0, nanosecond: 0 } }
}

///|
/// Return this DateTime at the end of its calendar day.
pub fn DateTime::end_of_day(self : DateTime) -> DateTime {
  {
    ..self,
    time: { hour: 23, minute: 59, second: 59, nanosecond: 999_999_999 },
  }
}

///|
/// Floor this DateTime to the requested unit boundary.
///
/// Day truncation is anchored to the calendar day: it returns midnight UTC on
/// the same date, rather than truncating a duration since the Unix epoch.
pub fn DateTime::truncate_to(self : DateTime, unit : TimeUnit) -> DateTime {
  match unit {
    Second => { ..self, time: { ..self.time, nanosecond: 0 } }
    Minute => { ..self, time: { ..self.time, second: 0, nanosecond: 0 } }
    Hour =>
      { ..self, time: { ..self.time, minute: 0, second: 0, nanosecond: 0 } }
    Day => self.start_of_day()
  }
}

///|
/// Round this DateTime to the requested unit boundary.
///
/// `Floor` is equivalent to `truncate_to(unit)`. `Ceil` rounds to the next
/// boundary only when there is a remainder. `HalfExpand` rounds to the nearest
/// boundary, with exact half-unit ties rounded up toward the later boundary.
///
/// Rounding is anchored to the calendar day and carries with `Date::add_days`,
/// avoiding Unix-nanosecond conversion for dates outside the Int64 nanosecond
/// timestamp range.
pub fn DateTime::round_to(
  self : DateTime,
  unit : TimeUnit,
  mode : RoundMode,
) -> DateTime {
  let floored = self.truncate_to(unit)
  let t = self.time
  let unit_ns = match unit {
    Second => ns_per_sec
    Minute => ns_per_min
    Hour => ns_per_hour
    Day => 86_400L * ns_per_sec
  }
  let rem_ns = match unit {
    Second => t.nanosecond.to_int64()
    Minute => t.second.to_int64() * ns_per_sec + t.nanosecond.to_int64()
    Hour =>
      (t.minute.to_int64() * 60L + t.second.to_int64()) * ns_per_sec +
      t.nanosecond.to_int64()
    Day =>
      (
        t.hour.to_int64() * 3600L +
        t.minute.to_int64() * 60L +
        t.second.to_int64()
      ) *
      ns_per_sec +
      t.nanosecond.to_int64()
  }
  let round_up = match mode {
    Floor => false
    Ceil => rem_ns > 0L
    HalfExpand => rem_ns * 2L >= unit_ns
  }
  if !round_up {
    floored
  } else {
    let unit_secs = match unit {
      Second => 1
      Minute => 60
      Hour => 3600
      Day => 86_400
    }
    let ft = floored.time
    let sod = ft.hour * 3600 + ft.minute * 60 + ft.second
    let total = sod + unit_secs
    let day_carry = total / 86_400
    let r = total % 86_400
    {
      date: floored.date.add_days(day_carry),
      time: {
        hour: r / 3600,
        minute: r % 3600 / 60,
        second: r % 60,
        nanosecond: 0,
      },
    }
  }
}

// ─── Unix timestamp conversion ────────────────────────────────────────────────

///|
/// Convert a Unix timestamp (seconds since 1970-01-01T00:00:00Z) to a `DateTime`.
/// Negative values represent dates before the Unix epoch. The year range is
/// limited by what `Int64` can represent as days (~±100 billion years).
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
/// Convert a Unix timestamp in nanoseconds to a `DateTime`.
/// Nanosecond resolution is preserved. Negative values represent dates before
/// the Unix epoch.
pub fn DateTime::from_unix_nanos(ns : Int64) -> DateTime {
  let ts_sec = floor_div64(ns, ns_per_sec)
  let nanosecond = (ns - ts_sec * ns_per_sec).to_int()
  let dt = DateTime::from_unix_seconds(ts_sec)
  { ..dt, time: { ..dt.time, nanosecond, } }
}

///|
/// Convert a Unix timestamp in milliseconds to a `DateTime`.
/// Negative values represent dates before the Unix epoch.
pub fn DateTime::from_unix_millis(ms : Int64) -> DateTime {
  let ts_sec = floor_div64(ms, 1000L)
  let nanosecond = ((ms - ts_sec * 1000L) * ns_per_ms).to_int()
  let dt = DateTime::from_unix_seconds(ts_sec)
  { ..dt, time: { ..dt.time, nanosecond, } }
}

///|
/// Convert a Unix timestamp in microseconds to a `DateTime`.
/// Negative values represent dates before the Unix epoch.
pub fn DateTime::from_unix_micros(us : Int64) -> DateTime {
  let ts_sec = floor_div64(us, 1_000_000L)
  let nanosecond = ((us - ts_sec * 1_000_000L) * ns_per_us).to_int()
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
/// Convert this `DateTime` to a Unix timestamp in nanoseconds.
///
/// **Overflow note:** this method silently wraps on `Int64` overflow. Use
/// `to_unix_nanos_checked` when dates outside the representable nanosecond
/// range should return `None`; use `to_unix_seconds` for wider ranges.
pub fn DateTime::to_unix_nanos(self : DateTime) -> Int64 {
  self.to_unix_seconds() * 1_000_000_000L + self.time.nanosecond.to_int64()
}

///|
/// Minimum Unix timestamp in nanoseconds representable by an `Int64`.
pub fn DateTime::min_unix_nanos() -> Int64 {
  int64_min_value
}

///|
/// Maximum Unix timestamp in nanoseconds representable by an `Int64`.
pub fn DateTime::max_unix_nanos() -> Int64 {
  int64_max_value
}

///|
/// Convert this `DateTime` to a Unix timestamp in nanoseconds.
///
/// Returns `None` when the instant is outside the representable `Int64`
/// nanosecond range.
pub fn DateTime::to_unix_nanos_checked(self : DateTime) -> Int64? {
  let sec = self.to_unix_seconds()
  let ns = self.time.nanosecond.to_int64()
  let min_sec = floor_div64(int64_min_value, ns_per_sec)
  let min_ns_remainder = int64_min_value % ns_per_sec
  let min_ns = if min_ns_remainder < 0L {
    min_ns_remainder + ns_per_sec
  } else {
    min_ns_remainder
  }
  let max_sec = int64_max_value / ns_per_sec
  let max_ns = int64_max_value % ns_per_sec
  if sec < min_sec ||
    sec > max_sec ||
    (sec == min_sec && ns < min_ns) ||
    (sec == max_sec && ns > max_ns) {
    None
  } else if sec == min_sec {
    Some(int64_min_value + (ns - min_ns))
  } else {
    let prod = sec * ns_per_sec
    if sec != 0L && prod / ns_per_sec != sec {
      None
    } else if prod > int64_max_value - ns {
      None
    } else {
      Some(prod + ns)
    }
  }
}

///|
/// Convert this `DateTime` to a Unix timestamp in milliseconds.
pub fn DateTime::to_unix_millis(self : DateTime) -> Int64 {
  self.to_unix_seconds() * 1000L + (self.time.nanosecond / 1_000_000).to_int64()
}

///|
/// Convert this `DateTime` to a Unix timestamp in microseconds.
pub fn DateTime::to_unix_micros(self : DateTime) -> Int64 {
  self.to_unix_seconds() * 1_000_000L +
  (self.time.nanosecond / 1_000).to_int64()
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
let ns_per_day : Int64 = 86_400_000_000_000L

///|
let int64_min_value : Int64 = -9_223_372_036_854_775_808L

///|
let int64_max_value : Int64 = 9_223_372_036_854_775_807L

///|
fn checked_i64_add(a : Int64, b : Int64) -> Int64? {
  if (b > 0L && a > int64_max_value - b) || (b < 0L && a < int64_min_value - b) {
    None
  } else {
    Some(a + b)
  }
}

///|
fn checked_i64_sub(a : Int64, b : Int64) -> Int64? {
  if (b < 0L && a > int64_max_value + b) || (b > 0L && a < int64_min_value + b) {
    None
  } else {
    Some(a - b)
  }
}

///|
/// Create a Duration from a number of nanoseconds.
pub fn Duration::nanoseconds(ns : Int64) -> Duration {
  { nanoseconds: ns }
}

///|
/// Create a Duration representing the given number of days (86 400 seconds each).
pub fn Duration::days(d : Int64) -> Duration {
  { nanoseconds: d * 86_400L * ns_per_sec }
}

///|
/// Create a Duration representing the given number of weeks (7 × 86 400 seconds).
pub fn Duration::weeks(w : Int64) -> Duration {
  { nanoseconds: w * 7L * 86_400L * ns_per_sec }
}

///|
/// Create a Duration representing the given number of microseconds.
pub fn Duration::microseconds(us : Int64) -> Duration {
  { nanoseconds: us * ns_per_us }
}

///|
/// Create a Duration representing the given number of milliseconds.
pub fn Duration::milliseconds(ms : Int64) -> Duration {
  { nanoseconds: ms * ns_per_ms }
}

///|
/// Create a Duration representing the given number of seconds.
pub fn Duration::seconds(s : Int64) -> Duration {
  { nanoseconds: s * ns_per_sec }
}

///|
/// Create a Duration representing the given number of minutes.
pub fn Duration::minutes(m : Int64) -> Duration {
  { nanoseconds: m * ns_per_min }
}

///|
/// Create a Duration representing the given number of hours.
pub fn Duration::hours(h : Int64) -> Duration {
  { nanoseconds: h * ns_per_hour }
}

// ─── Duration accessors ───────────────────────────────────────────────────────

///|
/// Total nanoseconds in this duration.
pub fn Duration::as_nanoseconds(self : Duration) -> Int64 {
  self.nanoseconds
}

///|
/// Total whole microseconds in this duration (truncated toward zero).
pub fn Duration::as_microseconds(self : Duration) -> Int64 {
  self.nanoseconds / ns_per_us
}

///|
/// Total whole milliseconds in this duration (truncated toward zero).
pub fn Duration::as_milliseconds(self : Duration) -> Int64 {
  self.nanoseconds / ns_per_ms
}

///|
/// Total whole seconds in this duration (truncated toward zero).
pub fn Duration::as_seconds(self : Duration) -> Int64 {
  self.nanoseconds / ns_per_sec
}

///|
/// Total whole minutes in this duration (truncated toward zero).
pub fn Duration::as_minutes(self : Duration) -> Int64 {
  self.nanoseconds / ns_per_min
}

///|
/// Total whole hours in this duration (truncated toward zero).
pub fn Duration::as_hours(self : Duration) -> Int64 {
  self.nanoseconds / ns_per_hour
}

///|
/// Total whole days in this duration (truncated toward zero).
pub fn Duration::as_days(self : Duration) -> Int64 {
  self.nanoseconds / (86_400L * ns_per_sec)
}

///|
pub fn Duration::as_weeks(self : Duration) -> Int64 {
  self.nanoseconds / (7L * 86_400L * ns_per_sec)
}

///|
/// `true` when this duration is exactly zero.
pub fn Duration::is_zero(self : Duration) -> Bool {
  self.nanoseconds == 0L
}

///|
/// `true` when this duration is negative.
pub fn Duration::is_negative(self : Duration) -> Bool {
  self.nanoseconds < 0L
}

///|
/// Absolute value of this duration.
///
/// `Int64::min_value` cannot be negated as an `Int64`, so that edge saturates
/// to `Int64::max_value` instead of raising or wrapping.
pub fn Duration::abs(self : Duration) -> Duration {
  if self.nanoseconds == int64_min_value {
    { nanoseconds: int64_max_value }
  } else if self.nanoseconds < 0L {
    { nanoseconds: -self.nanoseconds }
  } else {
    self
  }
}

///|
/// `true` when this duration is greater than zero.
pub fn Duration::is_positive(self : Duration) -> Bool {
  self.nanoseconds > 0L
}

///|
/// Sign of this duration: `-1` for negative, `0` for zero, `1` for positive.
pub fn Duration::signum(self : Duration) -> Int {
  if self.nanoseconds < 0L {
    -1
  } else if self.nanoseconds > 0L {
    1
  } else {
    0
  }
}

// ─── Duration arithmetic ──────────────────────────────────────────────────────

///|
/// Multiply this duration by an `Int64` scalar.
///
/// This wraps on `Int64` overflow. Use `checked_multiply` when overflow should
/// return `None`.
pub fn Duration::multiply(self : Duration, n : Int64) -> Duration {
  { nanoseconds: self.nanoseconds * n }
}

///|
/// Multiply this duration by an `Int64` scalar, returning `None` on overflow.
pub fn Duration::checked_multiply(self : Duration, n : Int64) -> Duration? {
  if n == 0L {
    Some({ nanoseconds: 0L })
  } else {
    let product = self.nanoseconds * n
    if product == int64_min_value && n == -1L {
      None
    } else if product / n == self.nanoseconds {
      Some({ nanoseconds: product })
    } else {
      None
    }
  }
}

///|
/// Divide this duration by an `Int64` scalar, truncating toward zero.
///
/// Division by zero raises `TempoError`. The `Int64::min_value / -1` overflow
/// edge also raises `TempoError` instead of trapping on backends where signed
/// division overflow is a runtime error.
pub fn Duration::divide(
  self : Duration,
  n : Int64,
) -> Duration raise TempoError {
  if n == 0L {
    raise TempoError("duration division by zero")
  }
  if self.nanoseconds == int64_min_value && n == -1L {
    raise TempoError("duration division overflow")
  }
  { nanoseconds: self.nanoseconds / n }
}

///|
/// Add two durations.
///
/// This wraps on `Int64` overflow. Use `checked_add` when overflow should
/// return `None`.
pub impl Add for Duration with fn add(self, other : Duration) -> Duration {
  { nanoseconds: self.nanoseconds + other.nanoseconds }
}

///|
/// Subtract one duration from another.
///
/// This wraps on `Int64` overflow. Use `checked_sub` when overflow should
/// return `None`.
pub impl Sub for Duration with fn sub(self, other : Duration) -> Duration {
  { nanoseconds: self.nanoseconds - other.nanoseconds }
}

///|
/// Add two durations, returning `None` on `Int64` overflow.
pub fn Duration::checked_add(self : Duration, other : Duration) -> Duration? {
  match checked_i64_add(self.nanoseconds, other.nanoseconds) {
    Some(ns) => Some(Duration::nanoseconds(ns))
    None => None
  }
}

///|
/// Subtract one duration from another, returning `None` on `Int64` overflow.
pub fn Duration::checked_sub(self : Duration, other : Duration) -> Duration? {
  match checked_i64_sub(self.nanoseconds, other.nanoseconds) {
    Some(ns) => Some(Duration::nanoseconds(ns))
    None => None
  }
}

///|
pub impl Neg for Duration with fn neg(self) -> Duration {
  { nanoseconds: -self.nanoseconds }
}

// ─── DateTime arithmetic ──────────────────────────────────────────────────────

///|
/// Add a Duration to this DateTime.
///
/// This wraps on `Int64` overflow. Use `checked_add` when overflow or a
/// DateTime outside the representable Unix-nanoseconds range should return
/// `None`.
pub fn DateTime::add(self : DateTime, d : Duration) -> DateTime {
  DateTime::from_unix_nanos(self.to_unix_nanos() + d.nanoseconds)
}

///|
/// Subtract a Duration from this DateTime.
///
/// This wraps on `Int64` overflow. Use `checked_sub` when overflow or a
/// DateTime outside the representable Unix-nanoseconds range should return
/// `None`.
pub fn DateTime::sub(self : DateTime, d : Duration) -> DateTime {
  DateTime::from_unix_nanos(self.to_unix_nanos() - d.nanoseconds)
}

///|
/// Compute `self - other` as a Duration (may be negative).
///
/// This wraps on `Int64` overflow. Use `checked_diff` when overflow or a
/// DateTime outside the representable Unix-nanoseconds range should return
/// `None`.
pub fn DateTime::diff(self : DateTime, other : DateTime) -> Duration {
  { nanoseconds: self.to_unix_nanos() - other.to_unix_nanos() }
}

///|
/// Add a Duration to this DateTime, returning `None` on `Int64` overflow or
/// when this DateTime is outside the representable Unix-nanoseconds range.
pub fn DateTime::checked_add(self : DateTime, d : Duration) -> DateTime? {
  match self.to_unix_nanos_checked() {
    Some(ns) =>
      match checked_i64_add(ns, d.nanoseconds) {
        Some(result) => Some(DateTime::from_unix_nanos(result))
        None => None
      }
    None => None
  }
}

///|
/// Subtract a Duration from this DateTime, returning `None` on `Int64` overflow
/// or when this DateTime is outside the representable Unix-nanoseconds range.
pub fn DateTime::checked_sub(self : DateTime, d : Duration) -> DateTime? {
  match self.to_unix_nanos_checked() {
    Some(ns) =>
      match checked_i64_sub(ns, d.nanoseconds) {
        Some(result) => Some(DateTime::from_unix_nanos(result))
        None => None
      }
    None => None
  }
}

///|
/// Compute `self - other` as a Duration, returning `None` on `Int64` overflow
/// or when either DateTime is outside the representable Unix-nanoseconds range.
pub fn DateTime::checked_diff(self : DateTime, other : DateTime) -> Duration? {
  match (self.to_unix_nanos_checked(), other.to_unix_nanos_checked()) {
    (Some(a), Some(b)) =>
      match checked_i64_sub(a, b) {
        Some(ns) => Some(Duration::nanoseconds(ns))
        None => None
      }
    _ => None
  }
}

///|
/// `true` if this DateTime is earlier than `other`.
pub fn DateTime::is_before(self : DateTime, other : DateTime) -> Bool {
  self.compare(other) < 0
}

///|
/// `true` if this DateTime is later than `other`.
pub fn DateTime::is_after(self : DateTime, other : DateTime) -> Bool {
  self.compare(other) > 0
}

///|
/// Return the earlier of this DateTime and `other`.
pub fn DateTime::min(self : DateTime, other : DateTime) -> DateTime {
  if self.compare(other) <= 0 {
    self
  } else {
    other
  }
}

///|
/// Return the later of this DateTime and `other`.
pub fn DateTime::max(self : DateTime, other : DateTime) -> DateTime {
  if self.compare(other) >= 0 {
    self
  } else {
    other
  }
}

///|
/// Clamp this DateTime to the inclusive range `[lo, hi]`. Assumes `lo <= hi`.
pub fn DateTime::clamp(
  self : DateTime,
  lo : DateTime,
  hi : DateTime,
) -> DateTime {
  if self.compare(lo) < 0 {
    lo
  } else if self.compare(hi) > 0 {
    hi
  } else {
    self
  }
}

// ─── Interval helpers ────────────────────────────────────────────────────────

///|
/// `true` if `dt` is in this half-open DateTime interval `[start, end)`.
pub fn Interval::contains(self : Interval, dt : DateTime) -> Bool {
  self.start <= dt && dt < self.end
}

///|
/// `true` if this half-open DateTime interval shares at least one instant with
/// `other`.
pub fn Interval::overlaps(self : Interval, other : Interval) -> Bool {
  self.start < other.end && other.start < self.end
}

///|
/// Return the half-open overlap between this DateTime interval and `other`.
pub fn Interval::intersection(self : Interval, other : Interval) -> Interval? {
  let s = self.start.max(other.start)
  let e = self.end.min(other.end)
  if s < e {
    Some({ start: s, end: e })
  } else {
    None
  }
}

///|
/// Duration of this half-open DateTime interval (`end - start`).
pub fn Interval::to_duration(self : Interval) -> Duration {
  self.end.diff(self.start)
}

///|
/// Wall-clock duration elapsed since `earlier` (`self - earlier`).
pub fn DateTime::since(self : DateTime, earlier : DateTime) -> Duration {
  self.diff(earlier)
}

///|
/// Wall-clock duration until `later` (`later - self`).
pub fn DateTime::until(self : DateTime, later : DateTime) -> Duration {
  later.diff(self)
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

// Zero-pad an integer to 3 digits.

///|
fn pad3(n : Int) -> String {
  if n < 10 {
    "00\{n}"
  } else if n < 100 {
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

// Proleptic Gregorian year for text output: optional leading `-` for years
// before 1 CE, then the absolute year number zero-padded to at least four
// decimal digits (same rules as `pad4`). Years with |year| ≥ 10000 use more
// than four digits. RFC 3339 `date-time` only allows four-digit positive years;
// this formatting follows ISO 8601-style expanded years for arbitrary `Date`
// values. `Int::min_value` cannot be negated to a positive `Int`; that case is
// rejected here.

///|
fn pad4_year(year : Int) -> String {
  if year < 0 {
    if year == @int.MIN_VALUE {
      abort("pad4_year: year is Int::min_value, cannot format magnitude")
    }
    "-" + pad4(-year)
  } else {
    pad4(year)
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
  s[:end].to_owned()
}

///|
/// Format this DateTime as an RFC 3339-style string (UTC, `Z` suffix) when the
/// year is in the usual four-digit range; negative years and years ≥ 10000 use
/// ISO 8601 expanded-year conventions (see `pad4_year`). Sub-second precision
/// is included only when nanoseconds ≠ 0.
/// Note: expanded-year output (years outside 0000–9999) cannot be round-tripped
/// through `DateTime::parse`, which accepts only 4-digit positive years (RFC 3339).
pub fn DateTime::format(self : DateTime) -> String {
  format_datetime_without_zone(self) + "Z"
}

///|
fn format_datetime_without_zone(dt : DateTime) -> String {
  let d = dt.date
  let t = dt.time
  let base = "\{pad4_year(d.year)}-\{pad2(d.month)}-\{pad2(d.day)}T\{pad2(t.hour)}:\{pad2(t.minute)}:\{pad2(t.second)}"
  if t.nanosecond == 0 {
    base
  } else {
    base + "." + fmt_frac(t.nanosecond)
  }
}

///|
fn shift_datetime_by_seconds(dt : DateTime, offset_seconds : Int) -> DateTime {
  let t = dt.time
  let seconds_of_day = t.hour * 3600 + t.minute * 60 + t.second
  let total_seconds = seconds_of_day.to_int64() + offset_seconds.to_int64()
  let day_delta = floor_div64(total_seconds, 86400L).to_int()
  let local_second = floor_mod64(total_seconds, 86400L).to_int()
  {
    date: dt.date.add_days(day_delta),
    time: {
      hour: local_second / 3600,
      minute: local_second % 3600 / 60,
      second: local_second % 60,
      nanosecond: t.nanosecond,
    },
  }
}

///|
fn format_offset_suffix(offset_seconds : Int) -> String {
  if offset_seconds == 0 {
    "Z"
  } else {
    let offset = offset_seconds.to_int64()
    let sign = if offset < 0L { "-" } else { "+" }
    let abs_seconds = if offset < 0L { -offset } else { offset }
    let total_minutes = abs_seconds / 60L
    let hours = (total_minutes / 60L).to_int()
    let minutes = (total_minutes % 60L).to_int()
    "\{sign}\{pad2(hours)}:\{pad2(minutes)}"
  }
}

///|
/// Format the local wall-clock time with the retained fixed offset.
///
/// The local wall-clock is computed as the stored UTC instant plus
/// `offset_seconds`; the fixed offset suffix is `Z` for zero and `+HH:MM` /
/// `-HH:MM` otherwise. This is for RFC 3339-style interop only; `DateTime`
/// remains the primary UTC timestamp type.
///
/// Note: formatting can abort when the local-time projection carries the year
/// near the `Int` extremes — it uses the same bounded-`Int` date arithmetic
/// (`Date::add_days`) and year padding (`pad4_year`) as `Date`/`DateTime`.
/// This is a known implementation boundary shared with those primitives, not a
/// property unique to `FixedOffsetDateTime`; it lies outside the current
/// arithmetic envelope (year ≈ ±2.1e9, far past where `Date::add_days` already
/// overflows). Ordinary timestamps and calendar dates are unaffected. The real
/// fix is a core-arithmetic hardening pass (checked / Int64 epoch-day
/// intermediates), tracked in tempo-oj8.
pub fn FixedOffsetDateTime::format(self : FixedOffsetDateTime) -> String {
  let wall_clock = shift_datetime_by_seconds(self.utc, self.offset_seconds)
  format_datetime_without_zone(wall_clock) +
  format_offset_suffix(self.offset_seconds)
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
/// Format this fixed-length duration as a canonical ISO 8601 duration string.
///
/// Calendar units (years and months) are not representable as a fixed
/// nanosecond duration and are therefore never emitted.
pub fn Duration::format_iso(self : Duration) -> String {
  let ns = self.nanoseconds
  if ns == 0L {
    "PT0S"
  } else {
    let sign = if ns < 0L { "-" } else { "" }
    // Divide before taking absolute values so Int64::min_value formats without
    // negating the whole duration.
    let days = ns / ns_per_day
    let rem = ns - days * ns_per_day
    let hours = rem / ns_per_hour
    let rem = rem - hours * ns_per_hour
    let minutes = rem / ns_per_min
    let rem = rem - minutes * ns_per_min
    let seconds = rem / ns_per_sec
    let frac_ns = rem - seconds * ns_per_sec
    let days = if days < 0L { -days } else { days }
    let hours = if hours < 0L { -hours } else { hours }
    let minutes = if minutes < 0L { -minutes } else { minutes }
    let seconds = if seconds < 0L { -seconds } else { seconds }
    let frac_ns = (if frac_ns < 0L { -frac_ns } else { frac_ns }).to_int()
    let has_time = hours > 0L || minutes > 0L || seconds > 0L || frac_ns > 0
    let buf = StringBuilder()
    buf.write_string(sign)
    buf.write_string("P")
    if days > 0L {
      buf.write_string("\{days}D")
    }
    if has_time {
      buf.write_string("T")
      if hours > 0L {
        buf.write_string("\{hours}H")
      }
      if minutes > 0L {
        buf.write_string("\{minutes}M")
      }
      if frac_ns > 0 {
        buf.write_string("\{seconds}.\{fmt_frac(frac_ns)}S")
      } else if seconds > 0L {
        buf.write_string("\{seconds}S")
      }
    }
    buf.to_string()
  }
}

///|
fn[T] json_decode_error(
  path : @json.JsonPath,
  msg : String,
) -> T raise @json.JsonDecodeError {
  raise @json.JsonDecodeError((path, msg))
}

///|
pub impl ToJson for Date with fn to_json(self : Date) -> Json {
  Json::string(self.format())
}

///|
pub impl @json.FromJson for Date with fn from_json(json, path) {
  guard json is String(s) else {
    json_decode_error(path, "Date::from_json: expected string")
  }
  Date::parse(s) catch {
    TempoError(msg) => json_decode_error(path, "Date::from_json: " + msg)
  }
}

///|
pub impl ToJson for Time with fn to_json(self : Time) -> Json {
  Json::string(self.format())
}

///|
pub impl @json.FromJson for Time with fn from_json(json, path) {
  guard json is String(s) else {
    json_decode_error(path, "Time::from_json: expected string")
  }
  Time::parse(s) catch {
    TempoError(msg) => json_decode_error(path, "Time::from_json: " + msg)
  }
}

///|
pub impl ToJson for DateTime with fn to_json(self : DateTime) -> Json {
  Json::string(self.format())
}

///|
pub impl @json.FromJson for DateTime with fn from_json(json, path) {
  guard json is String(s) else {
    json_decode_error(path, "DateTime::from_json: expected string")
  }
  DateTime::parse(s) catch {
    TempoError(msg) => json_decode_error(path, "DateTime::from_json: " + msg)
  }
}

///|
pub impl ToJson for Duration with fn to_json(self : Duration) -> Json {
  Json::string(self.format_iso())
}

///|
pub impl @json.FromJson for Duration with fn from_json(json, path) {
  guard json is String(s) else {
    json_decode_error(path, "Duration::from_json: expected string")
  }
  Duration::parse_iso(s) catch {
    TempoError(msg) => json_decode_error(path, "Duration::from_json: " + msg)
  }
}

///|
pub impl Show for Date with fn output(self, logger) {
  logger.write_string(
    "\{pad4_year(self.year)}-\{pad2(self.month)}-\{pad2(self.day)}",
  )
}

///|
pub impl Show for Time with fn output(self, logger) {
  logger.write_string(self.format())
}

///|
pub impl Show for DateTime with fn output(self, logger) {
  logger.write_string(self.format())
}

///|
pub impl Show for FixedOffsetDateTime with fn output(self, logger) {
  logger.write_string(self.format())
}

///|
pub impl Show for Duration with fn output(self, logger) {
  logger.write_string(self.to_string_repr())
}

///|
fn Duration::to_string_repr(self : Duration) -> String {
  let ns = self.nanoseconds
  if ns == 0L {
    "0s"
  } else {
    let sign = if ns < 0L { "-" } else { "" }
    // Decompose with signed arithmetic first, then abs each component
    // individually. Each component's magnitude is bounded (|h| ≤ 2_562_047,
    // |m| < 60, etc.), so the per-component negation is always safe and avoids
    // the Int64::min_value overflow that `-ns` would trigger.
    let h = ns / ns_per_hour
    let rem = ns - h * ns_per_hour
    let m = rem / ns_per_min
    let rem = rem - m * ns_per_min
    let s = rem / ns_per_sec
    let rem = rem - s * ns_per_sec
    let ms = rem / ns_per_ms
    let rem = rem - ms * ns_per_ms
    let us = rem / ns_per_us
    let sub_ns = rem - us * ns_per_us
    let h = if h < 0L { -h } else { h }
    let m = if m < 0L { -m } else { m }
    let s = if s < 0L { -s } else { s }
    let ms = if ms < 0L { -ms } else { ms }
    let us = if us < 0L { -us } else { us }
    let sub_ns = (if sub_ns < 0L { -sub_ns } else { sub_ns }).to_int()
    let buf = StringBuilder()
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
}

// ─── RFC 3339 parsing ─────────────────────────────────────────────────────────

// Parse exactly `n` ASCII decimal digits from a StringView,
// returning (value, rest).

///|
fn parse_digits(
  view : StringView,
  n : Int,
) -> (Int, StringView) raise TempoError {
  for v = view, remaining = n, acc = 0 {
    if remaining == 0 {
      break (acc, v)
    }
    match v {
      ['0'..='9' as c, .. rest] =>
        continue rest, remaining - 1, acc * 10 + c.to_int() - '0'
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
  for v = view, count = 0, acc = 0 {
    match v {
      ['0'..='9' as c, .. rest] =>
        if count < 9 {
          // Still within 9 significant digits — accumulate normally.
          continue rest, count + 1, acc * 10 + c.to_int() - '0'
        } else {
          // Beyond 9 digits: skip without touching acc to avoid overflow.
          continue rest, count + 1, acc
        }
      _ => {
        if count == 0 {
          raise TempoError("expected digits after '.'")
        }
        // Pad up to 9 digits if fewer were provided (e.g. ".1" → 100_000_000).
        let ns = for a = acc, r = 9 - count.clamp(min=0, max=9) {
          if r == 0 {
            break a
          }
          continue a * 10, r - 1
        }
        break (ns, v)
      }
    }
  }
}

///|
let duration_calendar_units_error : String = "calendar units (years/months) are not representable as a fixed Duration; use a calendar-period representation instead"

///|
fn parse_duration_number(
  view : StringView,
) -> (Int64, StringView) raise TempoError {
  for v = view, count = 0, acc = 0L {
    match v {
      ['0'..='9' as c, .. rest] => {
        let digit = (c.to_int() - '0').to_int64()
        if acc > (int64_max_value - digit) / 10L {
          raise TempoError("duration component overflows Int64")
        }
        continue rest, count + 1, acc * 10L + digit
      }
      _ => {
        if count == 0 {
          raise TempoError("expected duration component digits")
        }
        break (acc, v)
      }
    }
  }
}

///|
fn duration_component_ns(
  amount : Int64,
  unit : Int64,
) -> Int64 raise TempoError {
  match Duration::nanoseconds(unit).checked_multiply(amount) {
    Some(d) => d.nanoseconds
    None => raise TempoError("duration component overflows Int64 nanoseconds")
  }
}

///|
fn duration_accumulate(
  total : Int64,
  component : Int64,
  negative : Bool,
) -> Int64 raise TempoError {
  let next = if negative {
    checked_i64_sub(total, component)
  } else {
    checked_i64_add(total, component)
  }
  match next {
    Some(ns) => ns
    None => raise TempoError("duration overflows Int64 nanoseconds")
  }
}

///|
fn duration_reject_time_component_without_t(
  unit : Char,
) -> Unit raise TempoError {
  raise TempoError("time component '\{unit}' requires 'T'")
}

///|
fn duration_reject_time_order() -> Unit raise TempoError {
  raise TempoError("duration time components are repeated or out of order")
}

///|
/// Parse an ISO 8601 duration string in the fixed-nanosecond subset:
/// `PnDTnHnMnS`, with optional fractional seconds and leading sign.
///
/// Calendar units (`Y` years or date-part `M` months) raise `TempoError`; use a
/// calendar-period representation for those units.
pub fn Duration::parse_iso(s : String) -> Duration raise TempoError {
  let (negative, v) = match s.view() {
    ['-', .. rest] => (true, rest)
    ['+', .. rest] => (false, rest)
    v => (false, v)
  }
  let v = match v {
    ['P', .. rest] => rest
    [c, ..] => raise TempoError("expected 'P', got '\{c}'")
    [] => raise TempoError("unexpected end of input, expected 'P'")
  }
  let total = for v = v, total = 0L, saw_component = false, in_time = false, saw_day = false, time_rank = 0 {
    match v {
      [] =>
        if saw_component {
          break total
        } else {
          raise TempoError("expected duration component")
        }
      ['T', .. rest] => {
        if in_time {
          raise TempoError("duration contains repeated 'T'")
        }
        match rest {
          [] => raise TempoError("expected time component after 'T'")
          _ => continue rest, total, saw_component, true, saw_day, time_rank
        }
      }
      ['0'..='9', ..] => {
        let (amount, rest) = parse_duration_number(v)
        match rest {
          ['Y', ..] => raise TempoError(duration_calendar_units_error)
          ['D', .. rest] => {
            if in_time {
              raise TempoError("date component 'D' is not allowed after 'T'")
            }
            if saw_day {
              raise TempoError("duration day component is repeated")
            }
            let component = duration_component_ns(amount, ns_per_day)
            let total = duration_accumulate(total, component, negative)
            continue rest, total, true, in_time, true, time_rank
          }
          ['H', .. rest] => {
            if !in_time {
              duration_reject_time_component_without_t('H')
            }
            if time_rank >= 1 {
              duration_reject_time_order()
            }
            let component = duration_component_ns(amount, ns_per_hour)
            let total = duration_accumulate(total, component, negative)
            continue rest, total, true, in_time, saw_day, 1
          }
          ['M', .. rest] =>
            if in_time {
              if time_rank >= 2 {
                duration_reject_time_order()
              }
              let component = duration_component_ns(amount, ns_per_min)
              let total = duration_accumulate(total, component, negative)
              continue rest, total, true, in_time, saw_day, 2
            } else {
              raise TempoError(duration_calendar_units_error)
            }
          ['S', .. rest] => {
            if !in_time {
              duration_reject_time_component_without_t('S')
            }
            if time_rank >= 3 {
              duration_reject_time_order()
            }
            let component = duration_component_ns(amount, ns_per_sec)
            let total = duration_accumulate(total, component, negative)
            continue rest, total, true, in_time, saw_day, 3
          }
          ['.', .. frac_view] => {
            if !in_time {
              raise TempoError(
                "fractional components are only supported for seconds in the time part after 'T'",
              )
            }
            if time_rank >= 3 {
              duration_reject_time_order()
            }
            let seconds = duration_component_ns(amount, ns_per_sec)
            let total = duration_accumulate(total, seconds, negative)
            let (frac_ns, rest) = parse_frac_ns(frac_view)
            let rest = match rest {
              ['S', .. rest] => rest
              [c, ..] => raise TempoError("expected 'S', got '\{c}'")
              [] => raise TempoError("unexpected end of input, expected 'S'")
            }
            let total = duration_accumulate(total, frac_ns.to_int64(), negative)
            continue rest, total, true, in_time, saw_day, 3
          }
          [] =>
            raise TempoError("unexpected end of input, expected duration unit")
          [c, ..] => raise TempoError("expected duration unit, got '\{c}'")
        }
      }
      ['Y', ..] => raise TempoError(duration_calendar_units_error)
      [c, ..] => raise TempoError("expected duration component, got '\{c}'")
    }
  }
  Duration::nanoseconds(total)
}

///|
/// Parse an RFC 3339 / ISO 8601 datetime string.
/// Fixed numeric offsets are accepted and normalized to UTC.
pub fn DateTime::parse(s : String) -> DateTime raise TempoError {
  let (utc, _) = parse_rfc3339_parts(s)
  utc
}

///|
/// Parse an RFC 3339 datetime string, retaining the explicit fixed offset.
///
/// The stored instant is normalized UTC. The parsed numeric offset is retained
/// only for formatting/interoperability; it is not an IANA time zone.
pub fn FixedOffsetDateTime::parse(
  s : String,
) -> FixedOffsetDateTime raise TempoError {
  let (utc, offset_seconds) = parse_rfc3339_parts(s)
  FixedOffsetDateTime::from_datetime_and_offset(utc, offset_seconds)
}

///|
fn parse_rfc3339_parts(s : String) -> (DateTime, Int) raise TempoError {
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
  // Timezone: Z or ±HH:MM.
  let (v, offset_minutes) = match v {
    ['Z' | 'z', .. rest] => (rest, 0)
    ['+' | '-' as sign, .. rest] => {
      let (tz_h, rest) = parse_digits(rest, 2)
      let rest = consume(rest, ':')
      let (tz_m, rest) = parse_digits(rest, 2)
      if tz_h > 23 || tz_m > 59 {
        raise TempoError(
          "offset '\{sign}\{pad2(tz_h)}:\{pad2(tz_m)}' out of range",
        )
      }
      let minutes = tz_h * 60 + tz_m
      let minutes = if sign == '-' { -minutes } else { minutes }
      (rest, minutes)
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
  let base = { date, time }
  let utc = if offset_minutes == 0 {
    base
  } else {
    let total_min = (hour * 60 + minute - offset_minutes).to_int64()
    let day_delta = floor_div64(total_min, 1440L).to_int()
    let minute_of_day = floor_mod64(total_min, 1440L).to_int()
    {
      date: date.add_days(day_delta),
      time: Time::new(
        minute_of_day / 60,
        minute_of_day % 60,
        second,
        nanosecond,
      ),
    }
  }
  (utc, offset_minutes * 60)
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
