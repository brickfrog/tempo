// JS backend: uses Date.now() — millisecond precision.

///|
extern "js" fn js_now_nanos() -> Int64 =
  #| function() {
  #|   return BigInt(Date.now()) * 1000000n;
  #| }

///|
/// Returns the current UTC time.
/// Precision: whole seconds on native, milliseconds on js/wasm-gc.
pub fn DateTime::now() -> DateTime {
  DateTime::from_unix_nanos(js_now_nanos())
}
