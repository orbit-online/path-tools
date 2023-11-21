# path-tools

Bash tools to modify `$PATH`.

## Installation

With [μpkg](https://github.com/orbit-online/upkg)

```
upkg install -g orbit-online/path-tools@<VERSION>
```

## Usage

The functions below are available both as commands and functions (by sourcing `path-tools.sh`).

### Invariants

The following invariants are upheld:

- `$PATH` is printed to `stdout` instead of modifying it directly.
- Path comparisons ignore trailing slashes
- Any operation on `ELM` affects only its first occurrence
- `$PATH` is assumed to be well-formed, this means:
  - A leading or trailing `:` results in undefined behavior
  - Zero-bytes in paths results in undefined behavior

Trailing slashes may or may not be preserved, do not rely on any specific
behavior regarding this.

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
`[[ ${path%/} = ELM ]]`, meaning globs (like /usr/\*\*/bin) work.

#### `path_remove ELM`

Remove first occurrence of `ELM`.  
Do nothing if `ELM` is not present.

### Examples

#### Modify `DIR` in `$PATH`

Append, not present:

```
$ PATH=/usr/sbin:/usr/local/bin:/usr/bin:/usr/sbin
$ PATH=$(path_append DIR); echo $PATH
/usr/sbin:/usr/local/bin:/usr/bin:/usr/sbin:DIR
```

Append, present (same result):

```
$ PATH=/usr/sbin:/usr/local/bin:DIR:/usr/bin:/usr/sbin
$ PATH=$(path_append DIR); echo $PATH
/usr/sbin:/usr/local/bin:/usr/bin:/usr/sbin:DIR
```

Insert/move to end (same result):

```
$ PATH=/usr/sbin:/usr/local/bin:DIR:/usr/bin:/usr/sbin
$ PATH=$(path_append DIR true); echo $PATH
/usr/sbin:/usr/local/bin:/usr/bin:/usr/sbin:DIR
$ ^ exists, moved to end... v doesn't exist, appended
$ PATH=/usr/sbin:/usr/local/bin:/usr/bin:/usr/sbin
$ PATH=$(path_append DIR true); echo $PATH
/usr/sbin:/usr/local/bin:/usr/bin:/usr/sbin:DIR
```

Insert/move to beginning:

```
$ PATH=/usr/sbin:/usr/local/bin:DIR:/usr/bin:/usr/sbin
$ PATH=$(path_prepend DIR true); echo $PATH
DIR:/usr/sbin:/usr/local/bin:/usr/bin:/usr/sbin
```

Move after any path ending in `/bin`:

```
$ PATH=/usr/sbin:/usr/local/bin:DIR:/usr/bin:/usr/sbin
$ PATH=$(path_append DIR true '*/bin'); echo $PATH
/usr/sbin:/usr/local/bin:/usr/bin:DIR:/usr/sbin
```

Move `/usr/bin` before `DIR` if it exists:

```
PATH=/usr/sbin:/usr/local/bin:DIR:/usr/bin:/usr/sbin
$ PATH=$(if path_contains /usr/bin; then path_prepend /usr/bin true DIR; else echo $PATH; fi); echo $PATH
/usr/sbin:/usr/local/bin:/usr/bin:DIR:/usr/sbin
$ # ^ exists, moved... v doesn't exist, not added
$ PATH=/usr/sbin:/usr/local/bin:DIR:/usr/sbin
$ PATH=$(if path_contains /usr/bin; then path_prepend /usr/bin true DIR; else echo $PATH; fi); echo $PATH
/usr/sbin:/usr/local/bin:DIR:/usr/sbin
```
