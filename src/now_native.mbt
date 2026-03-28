// Native backend: uses POSIX time(2) — whole-second precision.
// For sub-second precision on native, a clock_gettime C stub would be needed.

///|
extern "c" fn c_time(ptr : Int) -> Int64 = "time"

///|
/// Returns the current UTC time.
/// Precision: whole seconds on native, milliseconds on js/wasm-gc.
pub fn DateTime::now() -> DateTime {
  DateTime::from_unix_seconds(c_time(0))
}
