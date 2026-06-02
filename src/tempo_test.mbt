// Blackbox tests for brickfrog/tempo public API.

///|
test "Date::new valid" {
  let d = @tempo.Date::new(2024, 3, 15)
  assert_eq(d.year, 2024)
  assert_eq(d.month, 3)
  assert_eq(d.day, 15)
}

///|
test "Date::new leap day" {
  let d = @tempo.Date::new(2000, 2, 29)
  assert_eq(d.day, 29)
}

///|
test "Date::new non-leap day 28 ok" {
  let d = @tempo.Date::new(2001, 2, 28)
  assert_eq(d.day, 28)
}

///|
test "Date::new invalid month" {
  assert_true((try? @tempo.Date::new(2024, 13, 1)) is Err(_))
}

///|
test "Date::new invalid day" {
  assert_true((try? @tempo.Date::new(2024, 2, 30)) is Err(_))
}

///|
test "Date::new non-leap Feb 29 invalid" {
  assert_true((try? @tempo.Date::new(2001, 2, 29)) is Err(_))
}

///|
test "Date::add_days forward" {
  let d = @tempo.Date::new(2024, 3, 15)
  let d2 = d.add_days(10)
  assert_eq(d2.year, 2024)
  assert_eq(d2.month, 3)
  assert_eq(d2.day, 25)
}

///|
test "Date::add_days backward" {
  let d = @tempo.Date::new(2024, 3, 15)
  let d2 = d.add_days(-14)
  assert_eq(d2.month, 3)
  assert_eq(d2.day, 1)
}

///|
test "Date::add_days crosses month" {
  let d = @tempo.Date::new(2024, 1, 31)
  let d2 = d.add_days(1)
  assert_eq(d2.month, 2)
  assert_eq(d2.day, 1)
}

///|
test "Date::add_days leap day" {
  let d = @tempo.Date::new(2024, 2, 28)
  let d2 = d.add_days(1)
  assert_eq(d2.month, 2)
  assert_eq(d2.day, 29)
}

///|
test "Date::add_months clamps end of month" {
  assert_eq(
    @tempo.Date::new(2023, 1, 31).add_months(1),
    @tempo.Date::new(2023, 2, 28),
  )
  assert_eq(
    @tempo.Date::new(2024, 1, 31).add_months(1),
    @tempo.Date::new(2024, 2, 29),
  )
  assert_eq(
    @tempo.Date::new(2024, 3, 31).add_months(1),
    @tempo.Date::new(2024, 4, 30),
  )
}

///|
test "Date::add_months preserves valid target day" {
  assert_eq(
    @tempo.Date::new(2024, 1, 31).add_months(2),
    @tempo.Date::new(2024, 3, 31),
  )
  assert_eq(
    @tempo.Date::new(2024, 2, 28).add_months(1),
    @tempo.Date::new(2024, 3, 28),
  )
  assert_eq(
    @tempo.Date::new(2024, 1, 31).add_months(12),
    @tempo.Date::new(2025, 1, 31),
  )
}

///|
test "Date::add_months wraps years and handles negatives" {
  assert_eq(
    @tempo.Date::new(2024, 12, 10).add_months(1),
    @tempo.Date::new(2025, 1, 10),
  )
  assert_eq(
    @tempo.Date::new(2024, 3, 15).add_months(-1),
    @tempo.Date::new(2024, 2, 15),
  )
  assert_eq(
    @tempo.Date::new(2024, 3, 31).add_months(-1),
    @tempo.Date::new(2024, 2, 29),
  )
  assert_eq(
    @tempo.Date::new(2024, 1, 10).add_months(-1),
    @tempo.Date::new(2023, 12, 10),
  )
  assert_eq(
    @tempo.Date::new(2024, 1, 31).add_months(25),
    @tempo.Date::new(2026, 2, 28),
  )
}

///|
test "Date::add_years clamps leap day" {
  assert_eq(
    @tempo.Date::new(2024, 2, 29).add_years(1),
    @tempo.Date::new(2025, 2, 28),
  )
  assert_eq(
    @tempo.Date::new(2024, 2, 29).add_years(4),
    @tempo.Date::new(2028, 2, 29),
  )
}

///|
test "Date::add_years handles negative and normal dates" {
  assert_eq(
    @tempo.Date::new(2024, 2, 29).add_years(-1),
    @tempo.Date::new(2023, 2, 28),
  )
  assert_eq(
    @tempo.Date::new(2024, 3, 15).add_years(1),
    @tempo.Date::new(2025, 3, 15),
  )
}

///|
test "Date::add_years avoids Int month overflow" {
  assert_eq(
    @tempo.Date::new(2024, 1, 1).add_years(178_956_971),
    @tempo.Date::new(178958995, 1, 1),
  )
}

///|
test "Date::with field updaters" {
  let d = @tempo.Date::new(2024, 3, 15)
  assert_eq(d.with_day(1), @tempo.Date::new(2024, 3, 1))
  assert_eq(d.with_month(12), @tempo.Date::new(2024, 12, 15))
  assert_eq(d.with_year(2025), @tempo.Date::new(2025, 3, 15))
}

///|
test "Date::with field updaters reject invalid dates" {
  assert_true((try? @tempo.Date::new(2024, 2, 29).with_year(2023)) is Err(_))
  assert_true((try? @tempo.Date::new(2024, 1, 31).with_month(2)) is Err(_))
  assert_true((try? @tempo.Date::new(2024, 3, 15).with_day(32)) is Err(_))
}

///|
test "Date boundary adjusters for month ends" {
  assert_eq(
    @tempo.Date::new(2024, 2, 10).end_of_month(),
    @tempo.Date::new(2024, 2, 29),
  )
  assert_eq(
    @tempo.Date::new(2023, 2, 10).end_of_month(),
    @tempo.Date::new(2023, 2, 28),
  )
  assert_eq(
    @tempo.Date::new(2024, 4, 15).end_of_month(),
    @tempo.Date::new(2024, 4, 30),
  )
  assert_eq(
    @tempo.Date::new(2024, 7, 9).end_of_month(),
    @tempo.Date::new(2024, 7, 31),
  )
}

///|
test "Date boundary adjusters for month and year starts" {
  assert_eq(
    @tempo.Date::new(2024, 4, 15).start_of_month(),
    @tempo.Date::new(2024, 4, 1),
  )
  assert_eq(
    @tempo.Date::new(2024, 7, 9).start_of_year(),
    @tempo.Date::new(2024, 1, 1),
  )
  assert_eq(
    @tempo.Date::new(2024, 7, 9).end_of_year(),
    @tempo.Date::new(2024, 12, 31),
  )
}

///|
test "DateTime boundary adjusters preserve time of day" {
  let dt = @tempo.DateTime::parse("2024-03-15T14:30:00Z")
  assert_eq(dt.start_of_month().format(), "2024-03-01T14:30:00Z")
  assert_eq(dt.end_of_month().format(), "2024-03-31T14:30:00Z")
  assert_eq(dt.start_of_year().format(), "2024-01-01T14:30:00Z")
  assert_eq(dt.end_of_year().format(), "2024-12-31T14:30:00Z")
}

///|
test "DateTime day boundary adjusters set time of day" {
  let dt = @tempo.DateTime::parse("2024-03-15T14:31:43.125Z")
  assert_eq(dt.start_of_day().format(), "2024-03-15T00:00:00Z")
  assert_eq(dt.end_of_day().format(), "2024-03-15T23:59:59.999999999Z")
  assert_eq(dt.start_of_day().date, dt.date)
  assert_eq(dt.end_of_day().date, dt.date)
}

///|
test "DateTime truncate_to floors to unit boundary" {
  let dt = @tempo.DateTime::parse("2024-03-15T14:31:43.125Z")
  assert_eq(dt.truncate_to(@tempo.Second).format(), "2024-03-15T14:31:43Z")
  assert_eq(dt.truncate_to(@tempo.Minute).format(), "2024-03-15T14:31:00Z")
  assert_eq(dt.truncate_to(@tempo.Hour).format(), "2024-03-15T14:00:00Z")
  assert_eq(dt.truncate_to(@tempo.Day), dt.start_of_day())
  assert_eq(dt.truncate_to(@tempo.Hour).date, dt.date)
}

///|
test "DateTime truncate_to day is calendar anchored for far future dates" {
  let dt = @tempo.DateTime::parse("3000-01-01T14:31:43.125Z")
  assert_eq(dt.truncate_to(@tempo.Day).format(), "3000-01-01T00:00:00Z")
  assert_eq(dt.truncate_to(@tempo.Hour).format(), "3000-01-01T14:00:00Z")
}

///|
test "DateTime::round_to hour modes" {
  assert_eq(
    @tempo.DateTime::parse("2024-03-15T14:30:00Z")
    .round_to(@tempo.Hour, @tempo.HalfExpand)
    .format(),
    "2024-03-15T15:00:00Z",
  )
  assert_eq(
    @tempo.DateTime::parse("2024-03-15T14:29:59.999999999Z")
    .round_to(@tempo.Hour, @tempo.HalfExpand)
    .format(),
    "2024-03-15T14:00:00Z",
  )
  assert_eq(
    @tempo.DateTime::parse("2024-03-15T14:31:00Z")
    .round_to(@tempo.Hour, @tempo.HalfExpand)
    .format(),
    "2024-03-15T15:00:00Z",
  )
  assert_eq(
    @tempo.DateTime::parse("2024-03-15T14:59:00Z")
    .round_to(@tempo.Hour, @tempo.Floor)
    .format(),
    "2024-03-15T14:00:00Z",
  )
  assert_eq(
    @tempo.DateTime::parse("2024-03-15T14:00:00Z")
    .round_to(@tempo.Hour, @tempo.Ceil)
    .format(),
    "2024-03-15T14:00:00Z",
  )
  assert_eq(
    @tempo.DateTime::parse("2024-03-15T14:01:00Z")
    .round_to(@tempo.Hour, @tempo.Ceil)
    .format(),
    "2024-03-15T15:00:00Z",
  )
}

///|
test "DateTime::round_to minute half expand" {
  assert_eq(
    @tempo.DateTime::parse("2024-03-15T14:31:29Z")
    .round_to(@tempo.Minute, @tempo.HalfExpand)
    .format(),
    "2024-03-15T14:31:00Z",
  )
  assert_eq(
    @tempo.DateTime::parse("2024-03-15T14:31:30Z")
    .round_to(@tempo.Minute, @tempo.HalfExpand)
    .format(),
    "2024-03-15T14:32:00Z",
  )
}

///|
test "DateTime::round_to day half expand carries date" {
  assert_eq(
    @tempo.DateTime::parse("2024-03-15T11:59:59Z")
    .round_to(@tempo.Day, @tempo.HalfExpand)
    .format(),
    "2024-03-15T00:00:00Z",
  )
  assert_eq(
    @tempo.DateTime::parse("2024-03-15T12:00:00Z")
    .round_to(@tempo.Day, @tempo.HalfExpand)
    .format(),
    "2024-03-16T00:00:00Z",
  )
}

///|
test "DateTime::round_to ceil carries across day and month" {
  assert_eq(
    @tempo.DateTime::parse("2024-03-15T23:30:00Z")
    .round_to(@tempo.Hour, @tempo.Ceil)
    .format(),
    "2024-03-16T00:00:00Z",
  )
  assert_eq(
    @tempo.DateTime::parse("2024-02-29T23:30:00Z")
    .round_to(@tempo.Hour, @tempo.Ceil)
    .format(),
    "2024-03-01T00:00:00Z",
  )
}

///|
test "DateTime::round_to far future avoids epoch nanos overflow" {
  assert_eq(
    @tempo.DateTime::parse("3000-01-01T14:31:30Z")
    .round_to(@tempo.Minute, @tempo.HalfExpand)
    .format(),
    "3000-01-01T14:32:00Z",
  )
  assert_eq(
    @tempo.DateTime::parse("3000-01-01T23:30:00Z")
    .round_to(@tempo.Hour, @tempo.Ceil)
    .format(),
    "3000-01-02T00:00:00Z",
  )
}

///|
test "RoundMode Show output" {
  inspect(@tempo.HalfExpand, content="HalfExpand")
}

///|
test "DateTime accessors and component updaters" {
  let date = @tempo.Date::new(2024, 3, 15)
  let time = @tempo.Time::new(12, 34, 56, 789)
  let dt = @tempo.DateTime::new(date, time)
  assert_eq(dt.to_date(), date)
  assert_eq(dt.to_time(), time)
  assert_eq(
    dt.with_date(@tempo.Date::new(2025, 1, 2)),
    @tempo.DateTime::new(@tempo.Date::new(2025, 1, 2), time),
  )
  assert_eq(
    dt.with_time(@tempo.Time::new(1, 2, 3, 4)),
    @tempo.DateTime::new(date, @tempo.Time::new(1, 2, 3, 4)),
  )
}

///|
test "DateTime scalar updaters delegate to date and time" {
  let dt = @tempo.DateTime::parse("2024-03-15T12:34:56.000000789Z")
  assert_eq(dt.with_day(1).format(), "2024-03-01T12:34:56.000000789Z")
  assert_eq(dt.with_hour(1).format(), "2024-03-15T01:34:56.000000789Z")
  assert_eq(dt.with_month(12).date, @tempo.Date::new(2024, 12, 15))
  assert_eq(dt.with_minute(2).time, @tempo.Time::new(12, 2, 56, 789))
  assert_eq(dt.with_second(3).time, @tempo.Time::new(12, 34, 3, 789))
  assert_eq(dt.with_nanosecond(4).time, @tempo.Time::new(12, 34, 56, 4))
  assert_eq(dt.with_year(2025).date, @tempo.Date::new(2025, 3, 15))
}

///|
test "DateTime scalar updaters reject invalid delegated fields" {
  let dt = @tempo.DateTime::parse("2024-02-15T12:34:56Z")
  assert_true((try? dt.with_day(31)) is Err(_))
}

///|
test "Date::day_of_week ISO" {
  // 1970-01-01 Thursday; 2024-01-01 Monday; 2024-03-15 Friday
  assert_eq(@tempo.Date::new(1970, 1, 1).day_of_week(), 4)
  assert_eq(@tempo.Date::new(2024, 1, 1).day_of_week(), 1)
  assert_eq(@tempo.Date::new(2024, 3, 15).day_of_week(), 5)
  assert_eq(@tempo.Date::new(2024, 3, 17).day_of_week(), 7)
}

///|
test "Weekday conversion helpers" {
  assert_true(@tempo.Weekday::from_int(1) == Some(@tempo.Monday))
  assert_eq(@tempo.Monday.to_int(), 1)
  assert_true(@tempo.Weekday::from_int(2) == Some(@tempo.Tuesday))
  assert_eq(@tempo.Tuesday.to_int(), 2)
  assert_true(@tempo.Weekday::from_int(3) == Some(@tempo.Wednesday))
  assert_eq(@tempo.Wednesday.to_int(), 3)
  assert_true(@tempo.Weekday::from_int(4) == Some(@tempo.Thursday))
  assert_eq(@tempo.Thursday.to_int(), 4)
  assert_true(@tempo.Weekday::from_int(5) == Some(@tempo.Friday))
  assert_eq(@tempo.Friday.to_int(), 5)
  assert_true(@tempo.Weekday::from_int(6) == Some(@tempo.Saturday))
  assert_eq(@tempo.Saturday.to_int(), 6)
  assert_true(@tempo.Weekday::from_int(7) == Some(@tempo.Sunday))
  assert_eq(@tempo.Sunday.to_int(), 7)
  assert_eq(@tempo.Wednesday.number_from_monday(), 3)
  assert_eq(@tempo.Wednesday.number_from_sunday(), 4)
  assert_true(@tempo.Weekday::from_int(0) is None)
  assert_true(@tempo.Weekday::from_int(8) is None)
}

///|
test "Weekday cyclic navigation and ordering" {
  assert_true(@tempo.Monday.next() == @tempo.Tuesday)
  assert_true(@tempo.Tuesday.next() == @tempo.Wednesday)
  assert_true(@tempo.Wednesday.next() == @tempo.Thursday)
  assert_true(@tempo.Thursday.next() == @tempo.Friday)
  assert_true(@tempo.Friday.next() == @tempo.Saturday)
  assert_true(@tempo.Saturday.next() == @tempo.Sunday)
  assert_true(@tempo.Sunday.next() == @tempo.Monday)
  assert_true(@tempo.Monday.previous() == @tempo.Sunday)
  assert_true(@tempo.Tuesday.previous() == @tempo.Monday)
  assert_true(@tempo.Wednesday.previous() == @tempo.Tuesday)
  assert_true(@tempo.Thursday.previous() == @tempo.Wednesday)
  assert_true(@tempo.Friday.previous() == @tempo.Thursday)
  assert_true(@tempo.Saturday.previous() == @tempo.Friday)
  assert_true(@tempo.Sunday.previous() == @tempo.Saturday)
  assert_eq(@tempo.Monday < @tempo.Sunday, true)
}

///|
test "Weekday Show output" {
  inspect(@tempo.Wednesday, content="Wednesday")
}

///|
test "Month conversion helpers" {
  assert_true(@tempo.Month::from_int(1) == Some(@tempo.January))
  assert_eq(@tempo.January.to_int(), 1)
  assert_true(@tempo.Month::from_int(2) == Some(@tempo.February))
  assert_eq(@tempo.February.to_int(), 2)
  assert_true(@tempo.Month::from_int(3) == Some(@tempo.March))
  assert_eq(@tempo.March.to_int(), 3)
  assert_true(@tempo.Month::from_int(4) == Some(@tempo.April))
  assert_eq(@tempo.April.to_int(), 4)
  assert_true(@tempo.Month::from_int(5) == Some(@tempo.May))
  assert_eq(@tempo.May.to_int(), 5)
  assert_true(@tempo.Month::from_int(6) == Some(@tempo.June))
  assert_eq(@tempo.June.to_int(), 6)
  assert_true(@tempo.Month::from_int(7) == Some(@tempo.July))
  assert_eq(@tempo.July.to_int(), 7)
  assert_true(@tempo.Month::from_int(8) == Some(@tempo.August))
  assert_eq(@tempo.August.to_int(), 8)
  assert_true(@tempo.Month::from_int(9) == Some(@tempo.September))
  assert_eq(@tempo.September.to_int(), 9)
  assert_true(@tempo.Month::from_int(10) == Some(@tempo.October))
  assert_eq(@tempo.October.to_int(), 10)
  assert_true(@tempo.Month::from_int(11) == Some(@tempo.November))
  assert_eq(@tempo.November.to_int(), 11)
  assert_true(@tempo.Month::from_int(12) == Some(@tempo.December))
  assert_eq(@tempo.December.to_int(), 12)
  assert_true(@tempo.Month::from_int(0) is None)
  assert_true(@tempo.Month::from_int(13) is None)
}

///|
test "Month cyclic navigation ordering and days" {
  assert_true(@tempo.January.next() == @tempo.February)
  assert_true(@tempo.February.next() == @tempo.March)
  assert_true(@tempo.March.next() == @tempo.April)
  assert_true(@tempo.April.next() == @tempo.May)
  assert_true(@tempo.May.next() == @tempo.June)
  assert_true(@tempo.June.next() == @tempo.July)
  assert_true(@tempo.July.next() == @tempo.August)
  assert_true(@tempo.August.next() == @tempo.September)
  assert_true(@tempo.September.next() == @tempo.October)
  assert_true(@tempo.October.next() == @tempo.November)
  assert_true(@tempo.November.next() == @tempo.December)
  assert_true(@tempo.December.next() == @tempo.January)
  assert_true(@tempo.January.previous() == @tempo.December)
  assert_true(@tempo.February.previous() == @tempo.January)
  assert_true(@tempo.March.previous() == @tempo.February)
  assert_true(@tempo.April.previous() == @tempo.March)
  assert_true(@tempo.May.previous() == @tempo.April)
  assert_true(@tempo.June.previous() == @tempo.May)
  assert_true(@tempo.July.previous() == @tempo.June)
  assert_true(@tempo.August.previous() == @tempo.July)
  assert_true(@tempo.September.previous() == @tempo.August)
  assert_true(@tempo.October.previous() == @tempo.September)
  assert_true(@tempo.November.previous() == @tempo.October)
  assert_true(@tempo.December.previous() == @tempo.November)
  assert_eq(@tempo.January < @tempo.December, true)
  assert_eq(@tempo.February.days_in(2024), 29)
  assert_eq(@tempo.February.days_in(2023), 28)
}

///|
test "Month Show output" {
  inspect(@tempo.March, content="March")
}

///|
test "Date typed weekday and month accessors" {
  let d = @tempo.Date::new(2024, 3, 15)
  assert_eq(d.weekday().to_int(), d.day_of_week())
  assert_true(@tempo.Date::new(2024, 3, 11).weekday() == @tempo.Monday)
  assert_true(@tempo.Date::new(2024, 3, 12).weekday() == @tempo.Tuesday)
  assert_true(@tempo.Date::new(2024, 3, 13).weekday() == @tempo.Wednesday)
  assert_true(@tempo.Date::new(2024, 3, 14).weekday() == @tempo.Thursday)
  assert_true(@tempo.Date::new(2024, 3, 15).weekday() == @tempo.Friday)
  assert_true(@tempo.Date::new(2024, 3, 16).weekday() == @tempo.Saturday)
  assert_true(@tempo.Date::new(2024, 3, 17).weekday() == @tempo.Sunday)
  assert_true(d.month_enum() == @tempo.March)
}

///|
test "Date weekday navigation is strictly next and previous" {
  let d = @tempo.Date::new(2024, 3, 15)
  assert_eq(d.next(@tempo.Monday), @tempo.Date::new(2024, 3, 18))
  assert_eq(d.next(@tempo.Friday), @tempo.Date::new(2024, 3, 22))
  assert_eq(d.previous(@tempo.Monday), @tempo.Date::new(2024, 3, 11))
  assert_eq(d.previous(@tempo.Friday), @tempo.Date::new(2024, 3, 8))
}

///|
test "Date weekday navigation or_same variants allow identity" {
  let d = @tempo.Date::new(2024, 3, 15)
  assert_eq(d.next_or_same(@tempo.Friday), d)
  assert_eq(d.next_or_same(@tempo.Monday), @tempo.Date::new(2024, 3, 18))
  assert_eq(d.previous_or_same(@tempo.Friday), d)
  assert_eq(d.previous_or_same(@tempo.Monday), @tempo.Date::new(2024, 3, 11))
}

///|
test "Date weekday navigation crosses year boundary" {
  assert_eq(
    @tempo.Date::new(2024, 12, 30).next(@tempo.Monday),
    @tempo.Date::new(2025, 1, 6),
  )
}

///|
test "Date::nth_weekday_of_month finds weekdays from either end" {
  assert_eq(
    @tempo.Date::nth_weekday_of_month(2024, 3, @tempo.Tuesday, 3),
    @tempo.Date::new(2024, 3, 19),
  )
  assert_eq(
    @tempo.Date::nth_weekday_of_month(2024, 3, @tempo.Friday, -1),
    @tempo.Date::new(2024, 3, 29),
  )
}

///|
test "Date::nth_weekday_of_month rejects missing or zero occurrences" {
  assert_true(
    (try? @tempo.Date::nth_weekday_of_month(2024, 3, @tempo.Monday, 5))
    is Err(_),
  )
  assert_true(
    (try? @tempo.Date::nth_weekday_of_month(2024, 3, @tempo.Tuesday, 0))
    is Err(_),
  )
}

///|
test "Date::day_of_year" {
  assert_eq(@tempo.Date::new(2024, 1, 1).day_of_year(), 1)
  assert_eq(@tempo.Date::new(2024, 3, 15).day_of_year(), 75)
  assert_eq(@tempo.Date::new(2023, 12, 31).day_of_year(), 365)
  assert_eq(@tempo.Date::new(2024, 12, 31).day_of_year(), 366)
}

///|
test "Date::days_until" {
  let a = @tempo.Date::new(2024, 3, 1)
  let b = @tempo.Date::new(2024, 3, 15)
  assert_eq(a.days_until(b), 14)
  assert_eq(b.days_until(a), -14)
  assert_eq(a.days_until(a), 0)
}

///|
test "Date comparison helpers" {
  let jan = @tempo.Date::new(2024, 1, 1)
  let feb = @tempo.Date::new(2024, 2, 1)
  let mar = @tempo.Date::new(2024, 3, 1)
  assert_eq(jan.is_before(feb), true)
  assert_eq(feb.is_before(jan), false)
  assert_eq(feb.is_after(jan), true)
  assert_eq(jan.is_after(feb), false)
  assert_eq(mar.min(jan), jan)
  assert_eq(jan.max(mar), mar)
  assert_eq(jan.clamp(feb, mar), feb)
  assert_eq(feb.clamp(jan, mar), feb)
  assert_eq(mar.add_days(1).clamp(jan, mar), mar)
}

///|
test "Date::parse valid" {
  let d = @tempo.Date::parse("2024-03-15")
  assert_eq(d.year, 2024)
  assert_eq(d.month, 3)
  assert_eq(d.day, 15)
}

///|
test "Date::format" {
  let d = @tempo.Date::new(2024, 3, 5)
  assert_eq(d.format(), "2024-03-05")
}

///|
test "Date::parse roundtrip" {
  let s = "2000-02-29"
  let d = @tempo.Date::parse(s)
  assert_eq(d.format(), s)
}

///|
test "Date::parse invalid month" {
  assert_true((try? @tempo.Date::parse("2024-13-01")) is Err(_))
}

///|
test "Date::parse trailing junk" {
  assert_true((try? @tempo.Date::parse("2024-01-01Z")) is Err(_))
}

///|
test "Time::new valid" {
  let t = @tempo.Time::new(23, 59, 59, 999_999_999)
  assert_eq(t.hour, 23)
  assert_eq(t.minute, 59)
  assert_eq(t.second, 59)
  assert_eq(t.nanosecond, 999_999_999)
}

///|
test "Time::with field updaters" {
  let t = @tempo.Time::new(12, 34, 56, 789)
  assert_eq(t.with_hour(1), @tempo.Time::new(1, 34, 56, 789))
  assert_eq(t.with_minute(2), @tempo.Time::new(12, 2, 56, 789))
  assert_eq(t.with_second(3), @tempo.Time::new(12, 34, 3, 789))
  assert_eq(t.with_nanosecond(4), @tempo.Time::new(12, 34, 56, 4))
}

///|
test "Time::with field updaters reject invalid times" {
  assert_true((try? @tempo.Time::new(12, 34, 56, 789).with_hour(24)) is Err(_))
  assert_true(
    (try? @tempo.Time::new(12, 34, 56, 789).with_nanosecond(1_000_000_000))
    is Err(_),
  )
}

///|
test "Time comparison helpers" {
  let early = @tempo.Time::new(8, 0, 0, 0)
  let mid = @tempo.Time::new(12, 0, 0, 0)
  let late = @tempo.Time::new(17, 0, 0, 0)
  assert_eq(early.is_before(mid), true)
  assert_eq(mid.is_before(early), false)
  assert_eq(mid.is_after(early), true)
  assert_eq(early.is_after(mid), false)
  assert_eq(late.min(early), early)
  assert_eq(early.max(late), late)
  assert_eq(early.clamp(mid, late), mid)
  assert_eq(mid.clamp(early, late), mid)
  assert_eq(late.clamp(early, mid), mid)
}

///|
test "Time::new invalid hour" {
  assert_true((try? @tempo.Time::new(24, 0, 0, 0)) is Err(_))
}

///|
test "is_leap_year" {
  assert_eq(@tempo.is_leap_year(2000), true)
  assert_eq(@tempo.is_leap_year(1900), false)
  assert_eq(@tempo.is_leap_year(2024), true)
  assert_eq(@tempo.is_leap_year(2023), false)
}

///|
test "days_in_month" {
  assert_eq(@tempo.days_in_month(2024, 2), 29)
  assert_eq(@tempo.days_in_month(2023, 2), 28)
  assert_eq(@tempo.days_in_month(2024, 1), 31)
  assert_eq(@tempo.days_in_month(2024, 4), 30)
}

///|
test "DateTime::epoch" {
  let e = @tempo.DateTime::epoch()
  assert_eq(e.date.year, 1970)
  assert_eq(e.date.month, 1)
  assert_eq(e.date.day, 1)
  assert_eq(e.time.hour, 0)
  assert_eq(e.time.nanosecond, 0)
}

///|
test "from_unix_seconds epoch" {
  let dt = @tempo.DateTime::from_unix_seconds(0L)
  assert_eq(dt.date.year, 1970)
  assert_eq(dt.date.month, 1)
  assert_eq(dt.date.day, 1)
  assert_eq(dt.time.hour, 0)
  assert_eq(dt.time.minute, 0)
  assert_eq(dt.time.second, 0)
}

///|
test "from_unix_seconds known date" {
  // 2024-03-15T12:34:56Z
  // python: datetime(2024,3,15,12,34,56,tzinfo=timezone.utc).timestamp() = 1710506096
  let dt = @tempo.DateTime::from_unix_seconds(1710506096L)
  assert_eq(dt.date.year, 2024)
  assert_eq(dt.date.month, 3)
  assert_eq(dt.date.day, 15)
  assert_eq(dt.time.hour, 12)
  assert_eq(dt.time.minute, 34)
  assert_eq(dt.time.second, 56)
}

///|
test "to_unix_seconds epoch" {
  let dt = @tempo.DateTime::epoch()
  assert_eq(dt.to_unix_seconds(), 0L)
}

///|
test "to_unix_seconds roundtrip" {
  let ts = 1710506096L
  let dt = @tempo.DateTime::from_unix_seconds(ts)
  assert_eq(dt.to_unix_seconds(), ts)
}

///|
test "from_unix_seconds pre-epoch" {
  // 1969-12-31T23:59:59Z = -1
  let dt = @tempo.DateTime::from_unix_seconds(-1L)
  assert_eq(dt.date.year, 1969)
  assert_eq(dt.date.month, 12)
  assert_eq(dt.date.day, 31)
  assert_eq(dt.time.hour, 23)
  assert_eq(dt.time.minute, 59)
  assert_eq(dt.time.second, 59)
}

///|
test "from_unix_nanos with sub-second" {
  let ns = 1710506096_000_000_001L
  let dt = @tempo.DateTime::from_unix_nanos(ns)
  assert_eq(dt.date.year, 2024)
  assert_eq(dt.time.second, 56)
  assert_eq(dt.time.nanosecond, 1)
}

///|
test "to_unix_nanos roundtrip" {
  let ns = 1710506096_123_456_789L
  let dt = @tempo.DateTime::from_unix_nanos(ns)
  assert_eq(dt.to_unix_nanos(), ns)
}

///|
test "from_unix_millis epoch" {
  assert_eq(@tempo.DateTime::from_unix_millis(0L), @tempo.DateTime::epoch())
  assert_eq(@tempo.DateTime::epoch().to_unix_millis(), 0L)
}

///|
test "from_unix_millis fractional roundtrip" {
  let ms = 1500L
  assert_eq(@tempo.DateTime::from_unix_millis(ms).to_unix_millis(), ms)
}

///|
test "from_unix_millis negative roundtrip" {
  let ms = -500L
  assert_eq(@tempo.DateTime::from_unix_millis(ms).to_unix_millis(), ms)
}

///|
test "from_unix_micros epoch plus one second" {
  assert_eq(
    @tempo.DateTime::from_unix_micros(1_000_000L),
    @tempo.DateTime::from_unix_seconds(1L),
  )
}

///|
test "from_unix_micros fractional roundtrip" {
  let us = 2_500_000L
  assert_eq(@tempo.DateTime::from_unix_micros(us).to_unix_micros(), us)
}

///|
test "from_unix_micros negative roundtrip" {
  let us = -1_500_000L
  assert_eq(@tempo.DateTime::from_unix_micros(us).to_unix_micros(), us)
}

///|
test "to_unix_millis uses floor seconds plus subsecond millis" {
  let dt = @tempo.DateTime::from_unix_nanos(1710506096_123_456_789L)
  assert_eq(dt.to_unix_millis(), dt.to_unix_seconds() * 1000L + 123L)
}

///|
test "to_unix_millis and micros support wide range" {
  let dt = @tempo.DateTime::parse("3000-01-01T00:00:00Z")
  let ms = 32_503_680_000_000L
  let us = 32_503_680_000_000_000L
  assert_eq(dt.to_unix_millis(), ms)
  assert_eq(dt.to_unix_micros(), us)
  assert_eq(@tempo.DateTime::from_unix_millis(ms), dt)
  assert_eq(@tempo.DateTime::from_unix_micros(us), dt)
}

///|
test "DateTime::format no sub-second" {
  let dt = @tempo.DateTime::from_unix_seconds(0L)
  assert_eq(dt.format(), "1970-01-01T00:00:00Z")
}

///|
test "DateTime::format known date" {
  let dt = @tempo.DateTime::from_unix_seconds(1710506096L)
  assert_eq(dt.format(), "2024-03-15T12:34:56Z")
}

///|
test "DateTime::format with nanoseconds" {
  let dt = @tempo.DateTime::from_unix_nanos(1710506096_100_000_000L)
  assert_eq(dt.format(), "2024-03-15T12:34:56.1Z")
}

///|
test "DateTime::format nanosecond precision" {
  let dt = @tempo.DateTime::from_unix_nanos(1710506096_123_456_789L)
  assert_eq(dt.format(), "2024-03-15T12:34:56.123456789Z")
}

///|
test "DateTime::format negative year" {
  let d = @tempo.Date::new(-500, 6, 15)
  let t = @tempo.Time::new(12, 0, 0, 0)
  let dt = @tempo.DateTime::new(d, t)
  assert_eq(dt.format(), "-0500-06-15T12:00:00Z")
}

///|
test "DateTime::format negative year -0001" {
  let d = @tempo.Date::new(-1, 1, 1)
  let t = @tempo.Time::new(0, 0, 0, 0)
  let dt = @tempo.DateTime::new(d, t)
  assert_eq(dt.format(), "-0001-01-01T00:00:00Z")
}

///|
test "Time::format no sub-second" {
  let t = @tempo.Time::new(0, 0, 0, 0)
  assert_eq(t.format(), "00:00:00")
}

///|
test "Time::format with nanoseconds trimmed" {
  let t = @tempo.Time::new(12, 34, 56, 100_000_000)
  assert_eq(t.format(), "12:34:56.1")
}

///|
test "Time::format nanosecond precision" {
  let t = @tempo.Time::new(12, 34, 56, 123_456_789)
  assert_eq(t.format(), "12:34:56.123456789")
}

///|
test "Time::parse basic" {
  let t = @tempo.Time::parse("12:34:56")
  assert_eq(t.hour, 12)
  assert_eq(t.minute, 34)
  assert_eq(t.second, 56)
  assert_eq(t.nanosecond, 0)
}

///|
test "Time::parse midnight" {
  let t = @tempo.Time::parse("00:00:00")
  assert_eq(t.hour, 0)
  assert_eq(t.nanosecond, 0)
}

///|
test "Time::parse with fractional seconds" {
  let t = @tempo.Time::parse("12:34:56.123456789")
  assert_eq(t.nanosecond, 123_456_789)
}

///|
test "Time::parse fractional seconds trimmed" {
  let t = @tempo.Time::parse("12:34:56.1")
  assert_eq(t.nanosecond, 100_000_000)
}

///|
test "Time::parse fractional seconds >9 digits truncated" {
  let t = @tempo.Time::parse("12:34:56.123456789999")
  assert_eq(t.nanosecond, 123_456_789)
}

///|
test "Time::parse invalid hour" {
  assert_true((try? @tempo.Time::parse("24:00:00")) is Err(_))
}

///|
test "Time::parse invalid format" {
  assert_true((try? @tempo.Time::parse("not-a-time")) is Err(_))
}

///|
test "Time::parse unexpected trailing" {
  assert_true((try? @tempo.Time::parse("12:34:56Z")) is Err(_))
}

///|
test "Time::parse roundtrip" {
  let s = "12:34:56.123456789"
  let t = @tempo.Time::parse(s)
  assert_eq(t.format(), s)
}

///|
test "DateTime::parse basic" {
  let dt = @tempo.DateTime::parse("1970-01-01T00:00:00Z")
  assert_eq(dt.to_unix_seconds(), 0L)
}

///|
test "DateTime::parse known date" {
  let dt = @tempo.DateTime::parse("2024-03-15T12:34:56Z")
  assert_eq(dt.to_unix_seconds(), 1710506096L)
}

///|
test "DateTime::parse lowercase t" {
  let dt = @tempo.DateTime::parse("2024-03-15t12:34:56Z")
  assert_eq(dt.to_unix_seconds(), 1710506096L)
}

///|
test "DateTime::parse with fractional seconds" {
  let dt = @tempo.DateTime::parse("2024-03-15T12:34:56.123456789Z")
  assert_eq(dt.time.nanosecond, 123_456_789)
}

///|
test "DateTime::parse fractional seconds trimmed" {
  let dt = @tempo.DateTime::parse("2024-03-15T12:34:56.1Z")
  assert_eq(dt.time.nanosecond, 100_000_000)
}

///|
test "DateTime::parse fractional seconds >9 digits truncated" {
  // 12 digits: first 9 significant, rest discarded without overflow
  let dt = @tempo.DateTime::parse("2024-03-15T12:34:56.123456789999Z")
  assert_eq(dt.time.nanosecond, 123_456_789)
}

///|
test "DateTime::parse fractional seconds all nines overflow safe" {
  let dt = @tempo.DateTime::parse("2024-03-15T12:34:56.99999999999Z")
  assert_eq(dt.time.nanosecond, 999_999_999)
}

///|
test "DateTime::parse +00:00 offset" {
  let dt = @tempo.DateTime::parse("2024-03-15T12:34:56+00:00")
  assert_eq(dt.to_unix_seconds(), 1710506096L)
  assert_eq(dt.format(), "2024-03-15T12:34:56Z")
}

///|
test "DateTime::parse -00:00 offset" {
  let dt = @tempo.DateTime::parse("2024-03-15T12:34:56-00:00")
  assert_eq(dt.to_unix_seconds(), 1710506096L)
  assert_eq(dt.format(), "2024-03-15T12:34:56Z")
}

///|
test "DateTime::parse positive offset normalized to UTC" {
  let dt = @tempo.DateTime::parse("2024-07-21T17:11:00+09:00")
  assert_eq(dt.format(), "2024-07-21T08:11:00Z")
}

///|
test "DateTime::parse negative offset normalized to UTC" {
  let dt = @tempo.DateTime::parse("2024-07-21T17:11:00-04:00")
  assert_eq(dt.format(), "2024-07-21T21:11:00Z")
}

///|
test "DateTime::parse offset normalization crosses date forward" {
  let dt = @tempo.DateTime::parse("2024-07-21T23:30:00-04:00")
  assert_eq(dt.format(), "2024-07-22T03:30:00Z")
}

///|
test "DateTime::parse offset normalization crosses date backward" {
  let dt = @tempo.DateTime::parse("2024-07-21T02:30:00+09:00")
  assert_eq(dt.format(), "2024-07-20T17:30:00Z")
}

///|
test "DateTime::parse offset normalization preserves fractional seconds" {
  let dt = @tempo.DateTime::parse("2024-03-28T14:31:43.125-04:00")
  assert_eq(dt.format(), "2024-03-28T18:31:43.125Z")
}

///|
test "DateTime::parse offset normalization future year overflow safe" {
  let dt = @tempo.DateTime::parse("3000-01-01T00:30:00+01:00")
  assert_eq(dt.format(), "2999-12-31T23:30:00Z")
}

///|
test "DateTime::parse offset normalization past year overflow safe" {
  let dt = @tempo.DateTime::parse("1000-01-01T05:00:00-06:00")
  assert_eq(dt.format(), "1000-01-01T11:00:00Z")
}

///|
test "DateTime::parse offset normalization matches Z equivalent" {
  let offset = @tempo.DateTime::parse("3000-06-15T12:00:00+05:00")
  let utc = @tempo.DateTime::parse("3000-06-15T07:00:00Z")
  assert_eq(offset, utc)
}

///|
test "DateTime::parse rejects out-of-range offset" {
  assert_true(
    (try? @tempo.DateTime::parse("2024-03-15T12:34:56+24:00")) is Err(_),
  )
  assert_true(
    (try? @tempo.DateTime::parse("2024-03-15T12:34:56+05:60")) is Err(_),
  )
}

///|
test "DateTime::parse invalid format" {
  assert_true((try? @tempo.DateTime::parse("not-a-date")) is Err(_))
}

///|
test "DateTime::parse roundtrip" {
  let s = "2024-03-15T12:34:56.123456789Z"
  let dt = @tempo.DateTime::parse(s)
  assert_eq(dt.format(), s)
}

///|
test "Duration::days" {
  let d = @tempo.Duration::days(1L)
  assert_eq(d.as_seconds(), 86_400L)
  assert_eq(d.as_hours(), 24L)
}

///|
test "Duration::weeks" {
  let w = @tempo.Duration::weeks(2L)
  assert_eq(w.as_nanoseconds(), 2L * 7L * 86_400L * 1_000_000_000L)
  assert_eq(w.as_seconds(), 2L * 7L * 86_400L)
  assert_eq(w.as_weeks(), 2L)
}

///|
test "Duration::as_weeks" {
  assert_eq(@tempo.Duration::days(14L).as_weeks(), 2L)
  assert_eq(@tempo.Duration::days(13L).as_weeks(), 1L)
  assert_eq(@tempo.Duration::days(1L).as_weeks(), 0L)
}

///|
test "Duration::days arithmetic" {
  let dt = @tempo.DateTime::parse("2024-01-31T00:00:00Z")
  let dt2 = dt.add(@tempo.Duration::days(1L))
  assert_eq(dt2.date.month, 2)
  assert_eq(dt2.date.day, 1)
}

///|
test "DateTime::now is after epoch" {
  assert_eq(@tempo.DateTime::now() > @tempo.DateTime::epoch(), true)
}

///|
test "Duration::seconds" {
  let d = @tempo.Duration::seconds(90L)
  assert_eq(d.as_seconds(), 90L)
  assert_eq(d.as_minutes(), 1L)
  assert_eq(d.as_nanoseconds(), 90_000_000_000L)
}

///|
test "Duration::minutes" {
  let d = @tempo.Duration::minutes(2L)
  assert_eq(d.as_seconds(), 120L)
}

///|
test "Duration::hours" {
  let d = @tempo.Duration::hours(1L)
  assert_eq(d.as_minutes(), 60L)
}

///|
test "Duration op_add" {
  let a = @tempo.Duration::seconds(30L)
  let b = @tempo.Duration::seconds(30L)
  let c = a + b
  assert_eq(c.as_seconds(), 60L)
}

///|
test "Duration op_sub" {
  let a = @tempo.Duration::seconds(60L)
  let b = @tempo.Duration::seconds(10L)
  let c = a - b
  assert_eq(c.as_seconds(), 50L)
}

///|
test "Duration op_neg" {
  let d = @tempo.Duration::seconds(5L)
  let neg = -d
  assert_eq(neg.as_nanoseconds(), -5_000_000_000L)
}

///|
test "Duration::abs" {
  assert_eq(@tempo.Duration::seconds(-5L).abs(), @tempo.Duration::seconds(5L))
  assert_eq(@tempo.Duration::seconds(5L).abs(), @tempo.Duration::seconds(5L))
  assert_eq(@tempo.Duration::seconds(0L).abs(), @tempo.Duration::seconds(0L))
  assert_eq(
    @tempo.Duration::nanoseconds(-9_223_372_036_854_775_808L).abs(),
    @tempo.Duration::nanoseconds(9_223_372_036_854_775_807L),
  )
}

///|
test "Duration::is_positive" {
  assert_eq(@tempo.Duration::seconds(1L).is_positive(), true)
  assert_eq(@tempo.Duration::seconds(0L).is_positive(), false)
  assert_eq(@tempo.Duration::seconds(-1L).is_positive(), false)
}

///|
test "Duration::signum" {
  assert_eq(@tempo.Duration::seconds(-1L).signum(), -1)
  assert_eq(@tempo.Duration::seconds(0L).signum(), 0)
  assert_eq(@tempo.Duration::seconds(1L).signum(), 1)
}

///|
test "Duration::multiply" {
  assert_eq(
    @tempo.Duration::seconds(2L).multiply(3L),
    @tempo.Duration::seconds(6L),
  )
  assert_eq(
    @tempo.Duration::seconds(2L).multiply(-1L),
    @tempo.Duration::seconds(-2L),
  )
  assert_eq(
    @tempo.Duration::seconds(2L).multiply(0L),
    @tempo.Duration::seconds(0L),
  )
  assert_eq(
    @tempo.Duration::nanoseconds(9_223_372_036_854_775_807L).multiply(2L),
    @tempo.Duration::nanoseconds(-2L),
  )
}

///|
test "Duration::checked_multiply" {
  assert_true(
    @tempo.Duration::seconds(2L).checked_multiply(3L) ==
    Some(@tempo.Duration::seconds(6L)),
  )
  assert_true(
    @tempo.Duration::nanoseconds(9_223_372_036_854_775_807L).checked_multiply(
      2L,
    )
    is None,
  )
  assert_true(
    @tempo.Duration::nanoseconds(-9_223_372_036_854_775_808L).checked_multiply(
      -1L,
    )
    is None,
  )
  assert_true(
    @tempo.Duration::nanoseconds(9_223_372_036_854_775_807L).checked_multiply(
      0L,
    ) ==
    Some(@tempo.Duration::nanoseconds(0L)),
  )
}

///|
test "Duration::divide" {
  assert_eq(
    @tempo.Duration::seconds(6L).divide(2L),
    @tempo.Duration::seconds(3L),
  )
  assert_eq(
    @tempo.Duration::nanoseconds(7L).divide(2L),
    @tempo.Duration::nanoseconds(3L),
  )
  assert_eq(
    @tempo.Duration::nanoseconds(-7L).divide(2L),
    @tempo.Duration::nanoseconds(-3L),
  )
  assert_eq(
    @tempo.Duration::nanoseconds(7L).divide(-2L),
    @tempo.Duration::nanoseconds(-3L),
  )
  assert_eq(
    @tempo.Duration::nanoseconds(-7L).divide(-2L),
    @tempo.Duration::nanoseconds(3L),
  )
  assert_true((try? @tempo.Duration::seconds(1L).divide(0L)) is Err(_))
  assert_true(
    (try? @tempo.Duration::nanoseconds(-9_223_372_036_854_775_808L).divide(-1L))
    is Err(_),
  )
}

///|
test "Duration compare" {
  let a = @tempo.Duration::seconds(1L)
  let b = @tempo.Duration::seconds(2L)
  assert_eq(a < b, true)
  assert_eq(b > a, true)
  assert_eq(a == a, true)
}

///|
test "DateTime::add" {
  let dt = @tempo.DateTime::from_unix_seconds(0L)
  let dt2 = dt.add(@tempo.Duration::hours(1L))
  assert_eq(dt2.time.hour, 1)
  assert_eq(dt2.to_unix_seconds(), 3600L)
}

///|
test "DateTime::sub" {
  let dt = @tempo.DateTime::from_unix_seconds(3600L)
  let dt2 = dt.sub(@tempo.Duration::hours(1L))
  assert_eq(dt2.to_unix_seconds(), 0L)
}

///|
test "DateTime::diff" {
  let a = @tempo.DateTime::from_unix_seconds(0L)
  let b = @tempo.DateTime::from_unix_seconds(3600L)
  let d = b.diff(a)
  assert_eq(d.as_hours(), 1L)
}

///|
test "DateTime::diff negative" {
  let a = @tempo.DateTime::from_unix_seconds(3600L)
  let b = @tempo.DateTime::from_unix_seconds(0L)
  let d = b.diff(a)
  assert_eq(d.as_nanoseconds(), -3_600_000_000_000L)
}

///|
test "DateTime::add crosses day boundary" {
  let dt = @tempo.DateTime::parse("2024-03-15T23:00:00Z")
  let dt2 = dt.add(@tempo.Duration::hours(2L))
  assert_eq(dt2.date.day, 16)
  assert_eq(dt2.time.hour, 1)
}

///|
test "DateTime::add crosses month boundary" {
  let dt = @tempo.DateTime::parse("2024-01-31T12:00:00Z")
  let dt2 = dt.add(@tempo.Duration::hours(24L))
  assert_eq(dt2.date.month, 2)
  assert_eq(dt2.date.day, 1)
}

///|
test "DateTime compare" {
  let a = @tempo.DateTime::from_unix_seconds(0L)
  let b = @tempo.DateTime::from_unix_seconds(1L)
  assert_eq(a < b, true)
  assert_eq(b > a, true)
  assert_eq(a == a, true)
}

///|
test "DateTime comparison helpers and elapsed wrappers" {
  let dt = @tempo.DateTime::parse("2024-03-15T12:00:00Z")
  let dt2 = dt.add(@tempo.Duration::hours(2L))
  let dt3 = dt.add(@tempo.Duration::hours(3L))
  assert_eq(dt.is_before(dt2), true)
  assert_eq(dt2.is_before(dt), false)
  assert_eq(dt2.is_after(dt), true)
  assert_eq(dt.is_after(dt2), false)
  assert_eq(dt3.min(dt), dt)
  assert_eq(dt.max(dt3), dt3)
  assert_eq(dt.clamp(dt2, dt3), dt2)
  assert_eq(dt2.clamp(dt, dt3), dt2)
  assert_eq(dt3.clamp(dt, dt2), dt2)
  assert_eq(dt2.since(dt).as_hours(), 2L)
  assert_eq(dt.until(dt2).as_hours(), 2L)
  assert_eq(dt.since(dt2).as_hours(), -2L)
}

///|
test "Show Date" {
  let d = @tempo.Date::new(2024, 3, 5)
  inspect(d, content="2024-03-05")
}

///|
test "Show Date negative year" {
  let d = @tempo.Date::new(-500, 6, 15)
  inspect(d, content="-0500-06-15")
}

///|
test "Show Date negative year -0001" {
  let d = @tempo.Date::new(-1, 1, 1)
  inspect(d, content="-0001-01-01")
}

///|
test "Show Time" {
  let t = @tempo.Time::new(9, 5, 3, 0)
  inspect(t, content="09:05:03")
}

///|
test "Show DateTime" {
  let dt = @tempo.DateTime::from_unix_seconds(1710506096L)
  inspect(dt, content="2024-03-15T12:34:56Z")
}

///|
test "Show DateTime negative year" {
  let d = @tempo.Date::new(-500, 6, 15)
  let t = @tempo.Time::new(12, 0, 0, 0)
  let dt = @tempo.DateTime::new(d, t)
  inspect(dt, content="-0500-06-15T12:00:00Z")
}

///|
test "Show Duration zero" {
  let d = @tempo.Duration::seconds(0L)
  inspect(d, content="0s")
}

///|
test "Show Duration seconds" {
  let d = @tempo.Duration::seconds(5L)
  inspect(d, content="5s")
}

///|
test "Show Duration hours minutes seconds" {
  let d = @tempo.Duration::seconds(3661L)
  inspect(d, content="1h1m1s")
}

///|
test "Show Duration negative" {
  let d = -@tempo.Duration::seconds(5L)
  inspect(d, content="-5s")
}

// ─── Duration constructors/accessors (audit 3.1) ─────────────────────────────

///|
test "Duration::nanoseconds" {
  let d = @tempo.Duration::nanoseconds(42L)
  assert_eq(d.as_nanoseconds(), 42L)
}

///|
test "Duration::microseconds" {
  let d = @tempo.Duration::microseconds(100L)
  assert_eq(d.as_nanoseconds(), 100_000L)
  assert_eq(d.as_microseconds(), 100L)
}

///|
test "Duration::milliseconds" {
  let d = @tempo.Duration::milliseconds(5L)
  assert_eq(d.as_nanoseconds(), 5_000_000L)
  assert_eq(d.as_milliseconds(), 5L)
}

// ─── Time::new validation (audit 3.2) ────────────────────────────────────────

///|
test "Time::new invalid minute" {
  assert_true((try? @tempo.Time::new(0, 60, 0, 0)) is Err(_))
}

///|
test "Time::new invalid second" {
  assert_true((try? @tempo.Time::new(0, 0, 60, 0)) is Err(_))
}

///|
test "Time::new invalid nanosecond negative" {
  assert_true((try? @tempo.Time::new(0, 0, 0, -1)) is Err(_))
}

///|
test "Time::new invalid nanosecond upper" {
  assert_true((try? @tempo.Time::new(0, 0, 0, 1_000_000_000)) is Err(_))
}

// ─── Duration Show branches (audit 3.3) ──────────────────────────────────────

///|
test "Show Duration milliseconds" {
  inspect(@tempo.Duration::milliseconds(500L), content="0s500ms")
}

///|
test "Show Duration microseconds" {
  inspect(@tempo.Duration::microseconds(1L), content="0s1µs")
}

///|
test "Show Duration nanoseconds" {
  inspect(@tempo.Duration::nanoseconds(1L), content="0s1ns")
}

///|
test "Show Duration complex" {
  let d = @tempo.Duration::hours(1L) + @tempo.Duration::milliseconds(500L)
  inspect(d, content="1h500ms")
}

///|
test "Show Duration negative complex" {
  let d = -(@tempo.Duration::hours(1L) + @tempo.Duration::milliseconds(500L))
  inspect(d, content="-1h500ms")
}

///|
test "Show Duration Int64::min_value" {
  // Regression: -ns overflowed back to min_value before divide-first fix.
  let d = @tempo.Duration::nanoseconds(-9_223_372_036_854_775_808L)
  inspect(d, content="-2562047h47m16s854ms775µs808ns")
}

///|
test "Show Duration Int64::max_value" {
  let d = @tempo.Duration::nanoseconds(9_223_372_036_854_775_807L)
  inspect(d, content="2562047h47m16s854ms775µs807ns")
}

// ─── Parsing error paths (audit 3.4) ─────────────────────────────────────────

///|
test "DateTime::parse unexpected EOF in digits" {
  assert_true((try? @tempo.DateTime::parse("2024-03-1")) is Err(_))
}

///|
test "DateTime::parse bad separator" {
  assert_true((try? @tempo.DateTime::parse("2024-03-15X12:00:00Z")) is Err(_))
}

///|
test "DateTime::parse dot without fraction" {
  assert_true((try? @tempo.DateTime::parse("2024-03-15T12:00:00.Z")) is Err(_))
}

///|
test "DateTime::parse bad timezone char" {
  assert_true((try? @tempo.DateTime::parse("2024-03-15T12:00:00Q")) is Err(_))
}

///|
test "DateTime::parse trailing after Z" {
  assert_true(
    (try? @tempo.DateTime::parse("2024-03-15T12:00:00Zextra")) is Err(_),
  )
}

// ─── Edge cases (audit 3.5) ──────────────────────────────────────────────────

///|
test "Date::add_days zero is identity" {
  let d = @tempo.Date::new(2024, 6, 15)
  let d2 = d.add_days(0)
  assert_eq(d, d2)
}

///|
test "Date::add_days across year boundary" {
  let d = @tempo.Date::new(2024, 12, 31)
  let d2 = d.add_days(1)
  assert_eq(d2.year, 2025)
  assert_eq(d2.month, 1)
  assert_eq(d2.day, 1)
}

///|
test "days_in_month invalid month" {
  assert_eq(@tempo.days_in_month(2024, 0), 0)
  assert_eq(@tempo.days_in_month(2024, 13), 0)
}

///|
test "DateTime::from_unix_nanos negative" {
  let dt = @tempo.DateTime::from_unix_nanos(-1L)
  assert_eq(dt.date.year, 1969)
  assert_eq(dt.date.month, 12)
  assert_eq(dt.date.day, 31)
  assert_eq(dt.time.hour, 23)
  assert_eq(dt.time.minute, 59)
  assert_eq(dt.time.second, 59)
  assert_eq(dt.time.nanosecond, 999_999_999)
}

///|
test "Show TempoError" {
  let err = @tempo.TempoError("test message")
  inspect(err, content="TempoError: test message")
}

// ─── Coverage: pad9 branches (nanosecond widths 1–8 digits) ──────────────────

///|
test "DateTime::format nanosecond 1 ns" {
  let base = 1710506096L * 1_000_000_000L
  let dt = @tempo.DateTime::from_unix_nanos(base + 1L)
  assert_eq(dt.format(), "2024-03-15T12:34:56.000000001Z")
}

///|
test "DateTime::format nanosecond 12 ns" {
  let base = 1710506096L * 1_000_000_000L
  let dt = @tempo.DateTime::from_unix_nanos(base + 12L)
  assert_eq(dt.format(), "2024-03-15T12:34:56.000000012Z")
}

///|
test "DateTime::format nanosecond 123 ns" {
  let base = 1710506096L * 1_000_000_000L
  let dt = @tempo.DateTime::from_unix_nanos(base + 123L)
  assert_eq(dt.format(), "2024-03-15T12:34:56.000000123Z")
}

///|
test "DateTime::format nanosecond 1234 ns" {
  let base = 1710506096L * 1_000_000_000L
  let dt = @tempo.DateTime::from_unix_nanos(base + 1234L)
  assert_eq(dt.format(), "2024-03-15T12:34:56.000001234Z")
}

///|
test "DateTime::format nanosecond 12345 ns" {
  let base = 1710506096L * 1_000_000_000L
  let dt = @tempo.DateTime::from_unix_nanos(base + 12_345L)
  assert_eq(dt.format(), "2024-03-15T12:34:56.000012345Z")
}

///|
test "DateTime::format nanosecond 123456 ns" {
  let base = 1710506096L * 1_000_000_000L
  let dt = @tempo.DateTime::from_unix_nanos(base + 123_456L)
  assert_eq(dt.format(), "2024-03-15T12:34:56.000123456Z")
}

///|
test "DateTime::format nanosecond 1234567 ns" {
  let base = 1710506096L * 1_000_000_000L
  let dt = @tempo.DateTime::from_unix_nanos(base + 1_234_567L)
  assert_eq(dt.format(), "2024-03-15T12:34:56.001234567Z")
}

///|
test "DateTime::format nanosecond 12345678 ns" {
  let base = 1710506096L * 1_000_000_000L
  let dt = @tempo.DateTime::from_unix_nanos(base + 12_345_678L)
  assert_eq(dt.format(), "2024-03-15T12:34:56.012345678Z")
}

// ─── Coverage: pad4 2–3 digit year ───────────────────────────────────────────

///|
test "Date::format 3-digit year" {
  let d = @tempo.Date::new(500, 6, 15)
  assert_eq(d.format(), "0500-06-15")
}

///|
test "Date::format 2-digit year" {
  let d = @tempo.Date::new(50, 1, 1)
  assert_eq(d.format(), "0050-01-01")
}

// ─── Coverage: consume wrong-char branch ─────────────────────────────────────

///|
test "DateTime::parse wrong separator in date" {
  // '/' instead of '-' triggers consume's wrong-char branch
  assert_true((try? @tempo.DateTime::parse("2024/03-15T12:00:00Z")) is Err(_))
}

// ─── Coverage: EOF-in-parse branches ─────────────────────────────────────────

///|
test "DateTime::parse EOF before T" {
  assert_true((try? @tempo.DateTime::parse("2024-03-15")) is Err(_))
}

///|
test "DateTime::parse EOF before timezone" {
  assert_true((try? @tempo.DateTime::parse("2024-03-15T12:00:00")) is Err(_))
}

// ─── New API: Duration::as_days, is_zero, is_negative ────────────────────────

///|
test "Duration::as_days" {
  assert_eq(@tempo.Duration::days(3L).as_days(), 3L)
  assert_eq(@tempo.Duration::hours(48L).as_days(), 2L)
  assert_eq(@tempo.Duration::hours(25L).as_days(), 1L)
}

///|
test "Duration::is_zero" {
  assert_eq(@tempo.Duration::seconds(0L).is_zero(), true)
  assert_eq(@tempo.Duration::seconds(1L).is_zero(), false)
  assert_eq((-@tempo.Duration::seconds(1L)).is_zero(), false)
}

///|
test "Duration::is_negative" {
  assert_eq(@tempo.Duration::seconds(-1L).is_negative(), true)
  assert_eq((-@tempo.Duration::seconds(5L)).is_negative(), true)
  assert_eq(@tempo.Duration::seconds(1L).is_negative(), false)
  assert_eq(@tempo.Duration::seconds(0L).is_negative(), false)
}

// ─── Coverage: consume EOF branch ────────────────────────────────────────────

///|
test "DateTime::parse truncated mid-date separator" {
  // Only year-month, no day separator — consume('-', ...) hits EOF
  assert_true((try? @tempo.DateTime::parse("2024-03")) is Err(_))
}

// ─── Edge-case tests ─────────────────────────────────────────────────────────

///|
test "DateTime::parse lowercase z" {
  let dt = @tempo.DateTime::parse("2024-03-15T12:34:56z")
  assert_eq(dt.to_unix_seconds(), 1710506096L)
}

///|
test "Date::day_of_week BCE" {
  // -0001-12-31 — verify the algorithm handles negative years correctly
  let d = @tempo.Date::new(-1, 12, 31)
  let dow = d.day_of_week()
  // Day of week should be 1..7
  assert_true(dow >= 1 && dow <= 7)
}

///|
test "Date::day_of_year leap Feb 29" {
  assert_eq(@tempo.Date::new(2024, 2, 29).day_of_year(), 60)
}

///|
test "Date::add_days large positive" {
  let d = @tempo.Date::new(2024, 1, 1)
  let d2 = d.add_days(10_000)
  // 10000 days from 2024-01-01 ≈ 2051-05-19
  assert_eq(d2.year, 2051)
  assert_eq(d2.month, 5)
  assert_eq(d2.day, 19)
}

///|
test "Date::add_days large negative" {
  let d = @tempo.Date::new(2024, 1, 1)
  let d2 = d.add_days(-10_000)
  assert_eq(d2.year, 1996)
  assert_eq(d2.month, 8)
  assert_eq(d2.day, 15)
}

///|
test "Duration::as_days round-trip" {
  let d = @tempo.Duration::days(365L)
  assert_eq(d.as_days(), 365L)
}

///|
test "Date::parse roundtrip 2-digit year" {
  let d = @tempo.Date::new(50, 3, 5)
  assert_eq(d.format(), "0050-03-05")
}

///|
fn date_interval(start : @tempo.Date, end : @tempo.Date) -> @tempo.DateInterval {
  { start, end }
}

///|
fn interval(start : @tempo.DateTime, end : @tempo.DateTime) -> @tempo.Interval {
  { start, end }
}

///|
test "DateInterval::contains includes both date boundaries" {
  let start = @tempo.Date::new(2024, 1, 1)
  let end = @tempo.Date::new(2024, 1, 10)
  let range = date_interval(start, end)
  assert_eq(range.contains(start), true)
  assert_eq(range.contains(@tempo.Date::new(2024, 1, 5)), true)
  assert_eq(range.contains(end), true)
  assert_eq(range.contains(@tempo.Date::new(2023, 12, 31)), false)
  assert_eq(range.contains(@tempo.Date::new(2024, 1, 11)), false)
}

///|
test "DateInterval::overlaps includes touching inclusive ends" {
  let range = date_interval(
    @tempo.Date::new(2024, 1, 1),
    @tempo.Date::new(2024, 1, 10),
  )
  let touching = date_interval(
    @tempo.Date::new(2024, 1, 10),
    @tempo.Date::new(2024, 1, 12),
  )
  let inside = date_interval(
    @tempo.Date::new(2024, 1, 3),
    @tempo.Date::new(2024, 1, 4),
  )
  let disjoint = date_interval(
    @tempo.Date::new(2024, 1, 11),
    @tempo.Date::new(2024, 1, 12),
  )
  assert_eq(range.overlaps(touching), true)
  assert_eq(touching.overlaps(range), true)
  assert_eq(range.overlaps(inside), true)
  assert_eq(range.overlaps(disjoint), false)
}

///|
test "DateInterval::intersection uses inclusive bounds" {
  let range = date_interval(
    @tempo.Date::new(2024, 1, 1),
    @tempo.Date::new(2024, 1, 10),
  )
  let overlapping = date_interval(
    @tempo.Date::new(2024, 1, 5),
    @tempo.Date::new(2024, 1, 12),
  )
  let touching = date_interval(
    @tempo.Date::new(2024, 1, 10),
    @tempo.Date::new(2024, 1, 12),
  )
  let disjoint = date_interval(
    @tempo.Date::new(2024, 1, 11),
    @tempo.Date::new(2024, 1, 12),
  )
  let gap_a = date_interval(
    @tempo.Date::new(2024, 1, 1),
    @tempo.Date::new(2024, 1, 5),
  )
  let gap_b = date_interval(
    @tempo.Date::new(2024, 1, 10),
    @tempo.Date::new(2024, 1, 15),
  )
  assert_true(
    range.intersection(overlapping) ==
    Some(
      date_interval(@tempo.Date::new(2024, 1, 5), @tempo.Date::new(2024, 1, 10)),
    ),
  )
  assert_true(
    range.intersection(touching) ==
    Some(
      date_interval(
        @tempo.Date::new(2024, 1, 10),
        @tempo.Date::new(2024, 1, 10),
      ),
    ),
  )
  assert_true(range.intersection(disjoint) is None)
  assert_true(gap_a.intersection(gap_b) is None)
}

///|
test "DateInterval::length_in_days is inclusive" {
  let ten_days = date_interval(
    @tempo.Date::new(2024, 1, 1),
    @tempo.Date::new(2024, 1, 10),
  )
  let one_day = date_interval(
    @tempo.Date::new(2024, 1, 10),
    @tempo.Date::new(2024, 1, 10),
  )
  assert_eq(ten_days.length_in_days(), 10)
  assert_eq(one_day.length_in_days(), 1)
}

///|
test "Interval::contains includes start and excludes end" {
  let start = @tempo.DateTime::parse("2024-01-01T00:00:00Z")
  let end = start.add(@tempo.Duration::hours(2L))
  let end_minus_one_ns = end.sub(@tempo.Duration::nanoseconds(1L))
  let range = interval(start, end)
  assert_eq(range.contains(start), true)
  assert_eq(range.contains(start.add(@tempo.Duration::hours(1L))), true)
  assert_eq(range.contains(end_minus_one_ns), true)
  assert_eq(range.contains(end), false)
  assert_eq(range.contains(start.sub(@tempo.Duration::nanoseconds(1L))), false)
}

///|
test "Interval::overlaps treats touching half-open bounds as disjoint" {
  let start = @tempo.DateTime::parse("2024-01-01T00:00:00Z")
  let end = start.add(@tempo.Duration::hours(2L))
  let range = interval(start, end)
  let overlapping = interval(
    start.add(@tempo.Duration::hours(1L)),
    start.add(@tempo.Duration::hours(3L)),
  )
  let touching_after = interval(end, end.add(@tempo.Duration::hours(1L)))
  let touching_before = interval(start.sub(@tempo.Duration::hours(1L)), start)
  assert_eq(range.overlaps(overlapping), true)
  assert_eq(range.overlaps(touching_after), false)
  assert_eq(touching_after.overlaps(range), false)
  assert_eq(range.overlaps(touching_before), false)
}

///|
test "Interval::intersection uses half-open bounds" {
  let start = @tempo.DateTime::parse("2024-01-01T00:00:00Z")
  let end = start.add(@tempo.Duration::hours(2L))
  let range = interval(start, end)
  let overlapping = interval(
    start.add(@tempo.Duration::hours(1L)),
    start.add(@tempo.Duration::hours(3L)),
  )
  let touching = interval(end, end.add(@tempo.Duration::hours(1L)))
  let gap = interval(
    end.add(@tempo.Duration::hours(1L)),
    end.add(@tempo.Duration::hours(2L)),
  )
  assert_true(
    range.intersection(overlapping) ==
    Some(interval(start.add(@tempo.Duration::hours(1L)), end)),
  )
  assert_true(range.intersection(touching) is None)
  assert_true(range.intersection(gap) is None)
}

///|
test "Interval::to_duration returns end minus start" {
  let start = @tempo.DateTime::parse("2024-01-01T00:00:00Z")
  let range = interval(start, start.add(@tempo.Duration::hours(2L)))
  assert_eq(range.to_duration(), @tempo.Duration::hours(2L))
}
