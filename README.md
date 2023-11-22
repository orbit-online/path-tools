# path-tools

Bash tools to modify `$PATH`.

## Contents

- [Installation](#installation)
- [Behavior](#behavior)
- [Usage](#usage)

## Installation

With [μpkg](https://github.com/orbit-online/upkg)

```
upkg install -g orbit-online/path-tools@<VERSION>
```

## Behavior

`path-tools` behaves idempotently. This means that running a command the first
time _might_ change something, but _will not_ change something if you run it a
second time immediately after that.

Results are output to `stdout`, `$PATH` is never modified.

`$PATH` is an implicit parameter, you cannot use `path-tools` to modify any
other variable (you can work around this prefixing a command with `PATH=...`).

Trailing slashes on paths and literal comparators are removed before comparing.

Commands that are passed a non-well-formed `$PATH` will throw an error.

## Usage

The functions below are available both as commands and functions (by sourcing `path-tools.sh`).

#### `path_append ELM`

Append `ELM` or move it to the end if present.

#### `path_prepend ELM`

Append `ELM` or move it to the beginning if present.

#### `path_insert_after ELM GLOB`

Insert/move `ELM` immediately after the last occurrence of `GLOB`.  
Append `ELM` if no `GLOB` matches were found.  
`GLOB` is compared using `[[ ${path%/} = $GLOB ]]`, meaning globs
like `/usr/**/bin?(/)` work.

#### `path_insert_before ELM GLOB`

Insert/move `ELM` immediately before the first occurrence of `GLOB`.  
**Append** `ELM` if no `GLOB` matches were found.  
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
_Note_: `path_validate` is called when invoking any of the other functions, so
you do not need to call it unless you want to explicitly validate `$PATH`.
