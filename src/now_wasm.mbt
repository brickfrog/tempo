// wasm-gc backend: host import from __moonbit_time_unstable "now".
// Returns milliseconds as a 64-bit integer (same host function as stdlib env).

///|
fn wasm_now_ms() -> Int64 = "__moonbit_time_unstable" "now"

///|
/// Returns the current UTC time.
/// Precision: whole seconds on native, milliseconds on js/wasm-gc.
pub fn DateTime::now() -> DateTime {
  DateTime::from_unix_nanos(wasm_now_ms() * 1_000_000L)
}
