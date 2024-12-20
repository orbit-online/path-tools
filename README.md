# path-tools

Bash tools to modify `$PATH`.

## Contents

- [Installation](#installation)
- [Behavior](#behavior)
- [Usage](#usage)

## Installation

See [the latest release](https://github.com/orbit-online/path-tools/releases/latest) for instructions.

## Behavior

`path-tools` behaves idempotently. This means that running a command the first
time _might_ change something, but _will not_ change something if you run it a
second time immediately after that.

Results are output to `stdout`, `$PATH` is never modified.

`$PATH` is an implicit parameter, you cannot use `path-tools` to modify any
other variable (you can work around this prefixing a command with `PATH=...`).

Trailing slashes on paths and literal comparators are removed before comparing.

## Usage

The functions below are available both as commands and functions (by sourcing `path-tools.sh`).

#### `path_append ELM`

Append `ELM` or move it to the end if present.

#### `path_prepend ELM`

Append `ELM` or move it to the beginning if present.

#### `path_insert_after [-p] ELM [GLOB]`

Insert/move `ELM` immediately after the last occurrence of `GLOB`.  
Append `ELM` if no `GLOB` matches were found, prepend if `-p` is set.  
`GLOB` is compared using `[[ ${path%/} = $GLOB ]]`, meaning globs
like `/usr/**/bin?(/)` work.

#### `path_insert_before [-p] ELM [GLOB]`

Insert/move `ELM` immediately before the first occurrence of `GLOB`.  
**Append** `ELM` if no `GLOB` matches were found, prepend if `-p` is set.  
`GLOB` is compared using `[[ ${path%/} = $GLOB ]]`, meaning globs
like `/usr/**/bin?(/)` work.

#### `path_remove ELM [ENABLE_GLOB]`

Remove all matches for `ELM`.  
Do nothing if `ELM` is not present.  
When `ENABLE_GLOB = true` (`false` is the default) `ELM` is compared using
`[[ ${path%/} = ELM ]]`, meaning globs like `/usr/**/bin?(/)` work.

#### `path_contains ELM [ENABLE_GLOB]`

Returns `$? = 0` if `ELM` is present, `$? = 1` if not.  
When `ENABLE_GLOB = true` (`false` is the default) `ELM` is compared using
`[[ ${path%/} = ELM ]]`, meaning globs like `/usr/**/bin?(/)` work.

#### `path_validate`

Returns `$? = 0` if `$PATH` is well-formed, `$? = 1` if not.  
When `$PATH` is not well-formed an explanation will written to `stderr`.

The following `$PATH` invariants are checked:

- Does not contain nul bytes
- Does not contain empty strings (i.e. does not start or end with `:`, and does contain a `::`)
- Has no duplicate paths
