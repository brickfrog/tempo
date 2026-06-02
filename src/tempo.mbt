// tempo — UTC-only date/time library for MoonBit
// Types: Date, Time, DateTime, Duration
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
} derive(Eq, Compare)

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
} derive(Eq, Compare)

///|
/// Units supported by `DateTime::truncate_to`, ordered smallest to largest.
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
/// A combined UTC date and time.
pub struct DateTime {
  date : Date
  time : Time
} derive(Eq, Compare)

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
} derive(Eq, Compare)

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
/// **Note:** Int64 can represent ±292 years of nanoseconds from epoch, so
/// dates outside ~1678–2262 CE will overflow. For wider ranges use
/// `to_unix_seconds` instead.
pub fn DateTime::to_unix_nanos(self : DateTime) -> Int64 {
  self.to_unix_seconds() * 1_000_000_000L + self.time.nanosecond.to_int64()
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
let int64_min_value : Int64 = -9_223_372_036_854_775_808L

///|
let int64_max_value : Int64 = 9_223_372_036_854_775_807L

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
pub impl Add for Duration with fn add(self, other : Duration) -> Duration {
  { nanoseconds: self.nanoseconds + other.nanoseconds }
}

///|
pub impl Sub for Duration with fn sub(self, other : Duration) -> Duration {
  { nanoseconds: self.nanoseconds - other.nanoseconds }
}

///|
pub impl Neg for Duration with fn neg(self) -> Duration {
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
  let d = self.date
  let t = self.time
  let base = "\{pad4_year(d.year)}-\{pad2(d.month)}-\{pad2(d.day)}T\{pad2(t.hour)}:\{pad2(t.minute)}:\{pad2(t.second)}"
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
/// Parse an RFC 3339 / ISO 8601 datetime string.
/// Fixed numeric offsets are accepted and normalized to UTC.
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
  if offset_minutes == 0 {
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
