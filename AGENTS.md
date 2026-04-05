# Project Agents.md Guide

This is a [MoonBit](https://docs.moonbitlang.com) project.

You can browse and install extra skills here:
<https://github.com/moonbitlang/skills>

## Project Structure

- MoonBit packages are organized per directory; each directory contains a
  `moon.pkg` file listing its dependencies. Each package has its files and
  blackbox test files (ending in `_test.mbt`) and whitebox test files (ending in
  `_wbtest.mbt`).

- In the toplevel directory, there is a `moon.mod.json` file listing module
  metadata.

## Coding convention

- MoonBit code is organized in block style, each block is separated by `///|`,
  the order of each block is irrelevant. In some refactorings, you can process
  block by block independently.

- Try to keep deprecated blocks in file called `deprecated.mbt` in each
  directory.

## Tooling

- `moon fmt` is used to format your code properly.

- `moon ide` provides project navigation helpers like `peek-def`, `outline`, and
  `find-references`. See $moonbit-agent-guide for details.

- `moon info` is used to update the generated interface of the package, each
  package has a generated interface file `.mbti`, it is a brief formal
  description of the package. If nothing in `.mbti` changes, this means your
  change does not bring the visible changes to the external package users, it is
  typically a safe refactoring.

- In the last step, run `moon info && moon fmt` to update the interface and
  format the code. Check the diffs of `.mbti` file to see if the changes are
  expected.

- Run `moon test` to check tests pass. MoonBit supports snapshot testing; when
  changes affect outputs, run `moon test --update` to refresh snapshots.

- Prefer `assert_eq` or `assert_true(pattern is Pattern(...))` for results that
  are stable or very unlikely to change. Use snapshot tests to record current
  behavior. For solid, well-defined results (e.g. scientific computations),
  prefer assertion tests. You can use `moon coverage analyze > uncovered.log` to
  see which parts of your code are not covered by tests.

## Design decisions (do not re-flag in audits)

- **pad2/pad4/pad9 unrolled branches:** Deliberate. Each branch produces one
  string interpolation with zero intermediate allocation. Not worth a generic
  `pad(n, width)` unless profiling shows formatting is a bottleneck.

- **pad4_year abort on Int::min_value:** Intentional programmer-error trap.
  `Int::min_value` cannot be negated to a positive `Int`. This year is not
  constructable via `Date::new` — only via raw struct literal (caller bug).
  Future option: handle via `Int64` arithmetic to eliminate the abort.

- **floor_div64 / floor_mod64:** Required. MoonBit stdlib does not provide floor
  division for `Int64`. MoonBit's `/` truncates toward zero; these round toward
  negative infinity, which the Hinnant calendar algorithms depend on.

- **Format/parse negative year asymmetry:** By design. `format()` handles
  negative years (ISO 8601 expanded). `parse()` accepts only 4-digit positive
  years (RFC 3339). Expanded-year parsing is deferred.

- **Error test pattern:** Tests check error occurrence via
  `assert_true((try? expr) is Err(_))`, not message content, to avoid brittle
  string assertions.

- **Duration::to_string_repr sequential decomposition:** Readable at ~35 lines.
  A loop over `(value, suffix)` pairs would obscure the special-case logic where
  seconds are always shown when hours and minutes are both zero.

- **fmt_frac while loop:** Intentional. `StringView` lacks `trim_end(Char)`.
