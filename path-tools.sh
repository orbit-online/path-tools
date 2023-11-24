#!/usr/bin/env bash

path_append() {
  [[ -n $1 && $# -eq 1 ]] || { printf "Usage: path_append ELM\n" >&2; return 1; }
  local new_path; new_path=$(path_remove "$1")
  printf "%s\n" "$new_path:$1"
}

path_prepend() {
  [[ -n $1 && $# -eq 1 ]] || { printf "Usage: path_prepend ELM\n" >&2; return 1; }
  local new_path; new_path=$(path_remove "$1")
  printf "%s\n" "$1:$new_path"
}

path_insert_after() {
  [[ -n $1 && -n $2 && $# -eq 2 ]] || { printf "Usage: path_insert_after ELM GLOB\n" >&2; return 1; }
  local new_path new_path_inner path rev_path matched=false
  new_path=$(path_remove "$1")
  while IFS= read -r -d ':' rev_path; do
    path=$(rev <<<"$rev_path")
    # shellcheck disable=2053
    if [[ ${path%/} != $2 ]] || $matched; then
      new_path_inner=$new_path_inner:$rev_path
    else
      new_path_inner=$new_path_inner:$(rev <<<"$1"):$rev_path
      matched=true
    fi
  done < <(rev <<<":$new_path")
  new_path_inner=$(rev <<<"$new_path_inner")
  new_path=${new_path_inner%:}
  $matched || new_path=$new_path:$1
  printf "%s\n" "$new_path"
}

path_insert_before() {
  [[ -n $1 && -n $2 && $# -eq 2 ]] || { printf "Usage: path_insert_before ELM GLOB\n" >&2; return 1; }
  local new_path new_path_inner path matched=false
  new_path=$(path_remove "$1")
  while IFS= read -r -d ':' path; do
    # shellcheck disable=2053
    if [[ ${path%/} != $2 ]] || $matched; then
      new_path_inner=$new_path_inner:$path
    else
      new_path_inner=$new_path_inner:$1:$path
      matched=true
    fi
  done <<<"$new_path:"
  new_path=${new_path_inner#:}
  $matched || new_path=$new_path:$1
  printf "%s\n" "$new_path"
}

path_remove() {
  [[ -n $1 && $2 =~ ^|true|false$ && $# -le 2 ]] || { printf "Usage: path_remove ELM [ENABLE_GLOB]\n" >&2; return 1; }
  local path new_path
  while IFS= read -r -d ':' path; do
    # shellcheck disable=2053
    if [[ $2 = true && ${path%/} != $1 ]] || [[ $2 != true && ${path%/} != "${1%/}" ]]; then
      new_path=$new_path:$path
    fi
  done <<<"$PATH:"
  printf "%s\n" "${new_path#:}"
}

path_contains() {
  [[ -n $1 || ! $2 =~ ^|true|false$ && $# -le 2 ]] || { printf "Usage: path_contains ELM [ENABLE_GLOB]\n" >&2; return 1; }
  local path
  while IFS= read -r -d ':' path; do
    # shellcheck disable=2053
    if [[ $2 = true && ${path%/} = $1 ]] || [[ $2 != true && ${path%/} = "${1%/}" ]]; then
      return 0
    fi
  done <<<"$PATH:"
  return 1
}

# shellcheck disable=2120
path_validate() {
  [[ $# -eq 0 ]] || { printf "Usage: path_validate\n" >&2; return 1; }
  local ret=0
  if [[ $PATH = *'\0'* ]]; then
    printf "path-tools.sh: \$PATH contains nul bytes\n" >&2
    ret=1
  fi
  if [[ $PATH =~ ^:|:$|:: ]]; then
    printf "path-tools.sh: \$PATH contains empty strings\n" >&2
    ret=1
  fi
  local duplicates=(); IFS=$'\n' readarray -t duplicates < <(tr ':' $'\n' <<<"$PATH" | sed 's%\(.\)/$%\1%' | sort | uniq -D | uniq)
  if [[ ${#duplicates[@]} -ne 0 ]]; then
    printf "path-tools.sh: \$PATH contains duplicate paths:\n" >&2
    printf "  %s\n" "${duplicates[@]}" >&2
    ret=1
  fi
  return $ret
}
