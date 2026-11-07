// Preserve the existing trait methods as explicit public methods.
// Keep callers working as implicit trait promotion is phased out.

///|
pub extend Date with @debug.Debug::{to_repr}

///|
pub extend Date with @json.FromJson::{from_json}

///|
pub extend Date with @json.ToJson::{to_json}

///|
pub extend Date with Compare::{op_lt, op_le, op_ge, compare, op_gt}

///|
pub extend Date with Eq::{not_equal, equal}

///|
pub extend Date with Hash::{hash, hash_combine}

///|
pub extend Date with Show::{to_string, output}

///|
pub extend DateInterval with @debug.Debug::{to_repr}

///|
pub extend DateInterval with Eq::{not_equal, equal}

///|
pub extend DateTime with @debug.Debug::{to_repr}

///|
pub extend DateTime with @json.FromJson::{from_json}

///|
pub extend DateTime with @json.ToJson::{to_json}

///|
pub extend DateTime with Compare::{op_lt, op_le, op_ge, compare, op_gt}

///|
pub extend DateTime with Eq::{not_equal, equal}

///|
pub extend DateTime with Hash::{hash, hash_combine}

///|
pub extend DateTime with Show::{to_string, output}

///|
pub extend Duration with @debug.Debug::{to_repr}

///|
pub extend Duration with @json.FromJson::{from_json}

///|
pub extend Duration with @json.ToJson::{to_json}

///|
pub extend Duration with Add::{add}

///|
pub extend Duration with Compare::{op_lt, op_le, op_ge, compare, op_gt}

///|
pub extend Duration with Eq::{not_equal, equal}

///|
pub extend Duration with Hash::{hash, hash_combine}

///|
pub extend Duration with Neg::{neg}

///|
pub extend Duration with Show::{to_string, output}

///|
pub extend Duration with Sub::{sub}

///|
pub extend FixedOffsetDateTime with @debug.Debug::{to_repr}

///|
pub extend FixedOffsetDateTime with Compare::{
  op_lt,
  op_le,
  op_ge,
  compare,
  op_gt,
}

///|
pub extend FixedOffsetDateTime with Eq::{not_equal, equal}

///|
pub extend FixedOffsetDateTime with Hash::{hash, hash_combine}

///|
pub extend FixedOffsetDateTime with Show::{to_string, output}

///|
pub extend Interval with @debug.Debug::{to_repr}

///|
pub extend Interval with Eq::{not_equal, equal}

///|
pub extend Month with @debug.Debug::{to_repr}

///|
pub extend Month with Compare::{op_lt, op_le, op_ge, compare, op_gt}

///|
pub extend Month with Eq::{not_equal, equal}

///|
pub extend Month with Hash::{hash, hash_combine}

///|
pub extend Month with Show::{to_string, output}

///|
pub extend Period with @debug.Debug::{to_repr}

///|
pub extend Period with Eq::{not_equal, equal}

///|
pub extend Period with Hash::{hash, hash_combine}

///|
pub extend Period with Show::{to_string, output}

///|
pub extend RoundMode with @debug.Debug::{to_repr}

///|
pub extend RoundMode with Compare::{op_lt, op_le, op_ge, compare, op_gt}

///|
pub extend RoundMode with Eq::{not_equal, equal}

///|
pub extend RoundMode with Hash::{hash, hash_combine}

///|
pub extend RoundMode with Show::{to_string, output}

///|
pub extend TempoError with Show::{to_string, output}

///|
pub extend Time with @debug.Debug::{to_repr}

///|
pub extend Time with @json.FromJson::{from_json}

///|
pub extend Time with @json.ToJson::{to_json}

///|
pub extend Time with Compare::{op_lt, op_le, op_ge, compare, op_gt}

///|
pub extend Time with Eq::{not_equal, equal}

///|
pub extend Time with Hash::{hash, hash_combine}

///|
pub extend Time with Show::{to_string, output}

///|
pub extend TimeUnit with @debug.Debug::{to_repr}

///|
pub extend TimeUnit with Compare::{op_lt, op_le, op_ge, compare, op_gt}

///|
pub extend TimeUnit with Eq::{not_equal, equal}

///|
pub extend TimeUnit with Hash::{hash, hash_combine}

///|
pub extend TimeUnit with Show::{to_string, output}

///|
pub extend Weekday with @debug.Debug::{to_repr}

///|
pub extend Weekday with Compare::{op_lt, op_le, op_ge, compare, op_gt}

///|
pub extend Weekday with Eq::{not_equal, equal}

///|
pub extend Weekday with Hash::{hash, hash_combine}

///|
pub extend Weekday with Show::{to_string, output}

///|
pub extend YearMonth with @debug.Debug::{to_repr}

///|
pub extend YearMonth with Compare::{op_lt, op_le, op_ge, compare, op_gt}

///|
pub extend YearMonth with Eq::{not_equal, equal}

///|
pub extend YearMonth with Hash::{hash, hash_combine}

///|
pub extend YearMonth with Show::{to_string, output}
