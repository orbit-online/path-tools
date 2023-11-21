# path-tools

Bash tools to modify `$PATH`.

## Contents

- [Installation](#installation)
- [Invariants](#invariants)
- [Usage](#usage)
  - [Functions](#functions)
    - [`path_append`](#path_append-elm-move-after_glob)
    - [`path_prepend`](#path_prepend-elm-move-before_glob)
    - [`path_contains`](#path_contains-elm-glob)
    - [`path_remove`](#path_remove-elm)
  - [Examples](#examples)

## Installation

With [μpkg](https://github.com/orbit-online/upkg)

```
upkg install -g orbit-online/path-tools@<VERSION>
```

## Invariants

The following invariants are upheld:

- `$PATH` is printed to `stdout` instead of modifying it directly.
- Path comparisons ignore trailing slashes
- Any operation on `ELM` affects only its first occurrence
- `$PATH` is assumed to be well-formed, this means:
  - A leading or trailing `:` results in undefined behavior
  - Zero-bytes in paths results in undefined behavior

Trailing slashes may or may not be preserved, do not rely on any specific
behavior regarding this.

## Usage

The functions below are available both as commands and functions (by sourcing `path-tools.sh`).

### Functions

#### `path_append ELM [MOVE] [AFTER_GLOB]`

Append `ELM` or, if set, insert right after last occurrence of `AFTER_GLOB`.  
When `MOVE = false` (the default) leave `ELM` in current position if already present.  
When `MOVE = true` and `ELM` is present move it to the last position, or if set,
right after last occurrence of `AFTER_GLOB`.  
`AFTER_GLOB` is compared using `[[ ${path%/} = $AFTER_GLOB ]]`, meaning globs
(like `/usr/**/bin`) work.

#### `path_prepend ELM [MOVE] [BEFORE_GLOB]`

Append `ELM` or, if set, insert right before first occurrence of `BEFORE_GLOB`.  
When `MOVE = false` (the default) leave `ELM` in current position if already present.  
When `MOVE = true` and `ELM` is present move it to the last position, or if set,
right before first occurrence of `BEFORE_GLOB`.
`BEFORE_GLOB` is compared using `[[ ${path%/} = $BEFORE_GLOB ]]`, meaning globs
(like `/usr/**/bin`) work.

#### `path_contains ELM [GLOB]`

Returns `$? = 0` if `ELM` is present, `$? = 1` if not.  
When `GLOB = true` (`false` is the default) `ELM` is compared using
`[[ ${path%/} = ELM ]]`, meaning globs (like `/usr/**/bin`) work.

#### `path_remove ELM`

Remove first occurrence of `ELM`.  
Do nothing if `ELM` is not present.

### Examples

#### Append `DIR`

```
$ PATH=/usr/sbin:/usr/local/bin:DIR:/usr/bin:/usr/sbin
$ PATH=$(path_append DIR); echo $PATH
/usr/sbin:/usr/local/bin:/usr/bin:/usr/sbin:DIR
$ ^ exists, moved to end... v doesn't exist, appended (same result)
$ PATH=/usr/sbin:/usr/local/bin:DIR:/usr/bin:/usr/sbin
$ PATH=$(path_append DIR); echo $PATH
/usr/sbin:/usr/local/bin:/usr/bin:/usr/sbin:DIR
```

#### Append/move `DIR` to end

```
$ PATH=/usr/sbin:/usr/local/bin:DIR:/usr/bin:/usr/sbin
$ PATH=$(path_append DIR true); echo $PATH
/usr/sbin:/usr/local/bin:/usr/bin:/usr/sbin:DIR
$ ^ exists, moved to end... v doesn't exist, appended (same result)
$ PATH=/usr/sbin:/usr/local/bin:/usr/bin:/usr/sbin
$ PATH=$(path_append DIR true); echo $PATH
/usr/sbin:/usr/local/bin:/usr/bin:/usr/sbin:DIR
```

#### Prepend/move `DIR` to beginning

```
$ PATH=/usr/sbin:/usr/local/bin:DIR:/usr/bin:/usr/sbin
$ PATH=$(path_prepend DIR true); echo $PATH
DIR:/usr/sbin:/usr/local/bin:/usr/bin:/usr/sbin
$ ^ exists, moved to beginning... v doesn't exist, prepended (same result)
$ PATH=/usr/sbin:/usr/local/bin:/usr/bin:/usr/sbin
$ PATH=$(path_prepend DIR true); echo $PATH
DIR:/usr/sbin:/usr/local/bin:/usr/bin:/usr/sbin
```

#### Move `DIR` after any path ending in `/bin`

```
$ PATH=/usr/sbin:/usr/local/bin:DIR:/usr/bin:/usr/sbin
$ PATH=$(path_append DIR true '*/bin'); echo $PATH
/usr/sbin:/usr/local/bin:/usr/bin:DIR:/usr/sbin
```

#### Move `/usr/bin` before `DIR` if it exists

```
PATH=/usr/sbin:/usr/local/bin:DIR:/usr/bin:/usr/sbin
$ PATH=$(if path_contains /usr/bin; then path_prepend /usr/bin true DIR; else echo $PATH; fi); echo $PATH
/usr/sbin:/usr/local/bin:/usr/bin:DIR:/usr/sbin
$ # ^ exists, moved... v doesn't exist, not added
$ PATH=/usr/sbin:/usr/local/bin:DIR:/usr/sbin
$ PATH=$(if path_contains /usr/bin; then path_prepend /usr/bin true DIR; else echo $PATH; fi); echo $PATH
/usr/sbin:/usr/local/bin:DIR:/usr/sbin
```
