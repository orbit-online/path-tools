#!/usr/bin/env bash

path_append() {
  local elm=${1%/} move=${2:-false} after_glob=${3%/} add_elm=false new_path=$PATH
  if [[ -z $elm || ! $move =~ ^true|false$ ]]; then
    printf "Usage: path_prepend ELM [MOVE] [AFTER_GLOB]\n" >&2
    return 1
  fi
  path_contains "$elm" || add_elm=true
  if [[ -n $after_glob ]] && path_contains "$after_glob" true; then
    if $move; then
      $add_elm || new_path=$(path_remove "$elm")
      add_elm=true
    fi
    if $add_elm; then
      local new_path_inner path rev_path matched=false
      while IFS= read -r -d ':' rev_path; do
        path=$(rev <<<"$rev_path")
        # The unescaped rhs in the comparison is on purpose to allow for glob matching
        # shellcheck disable=2053
        if [[ ${path%/} != $after_glob ]] || $matched; then
          new_path_inner=$new_path_inner:$rev_path
        else
          new_path_inner=$new_path_inner:$(rev <<<"$elm"):$rev_path
          matched=true
        fi
      done < <(rev <<<":$new_path")
      new_path_inner=$(rev <<<"$new_path_inner")
      new_path=${new_path_inner%:}
    fi
  elif $add_elm; then
    new_path=$new_path:$elm
  elif $move; then
    new_path=$(path_remove "$elm")
    new_path=$new_path:$elm
  fi
  printf "%s\n" "$new_path"
}

path_prepend() {
  local elm=${1%/} move=${2:-false} before_glob=${3%/} add_elm=false new_path=$PATH
  if [[ -z $elm || ! $move =~ ^true|false$ ]]; then
    printf "Usage: path_prepend ELM [MOVE] [BEFORE_GLOB]\n" >&2
    return 1
  fi
  path_contains "$elm" || add_elm=true
  if [[ -n $before_glob ]] && path_contains "$before_glob" true; then
    if $move; then
      $add_elm || new_path=$(path_remove "$elm")
      add_elm=true
    fi
    if $add_elm; then
      local new_path_inner path matched=false
      while IFS= read -r -d ':' path; do
        # The unescaped rhs in the comparison is on purpose to allow for glob matching
        # shellcheck disable=2053
        if [[ ${path%/} != $before_glob ]] || $matched; then
          new_path_inner=$new_path_inner:$path
        else
          new_path_inner=$new_path_inner:$elm:$path
          matched=true
        fi
      done <<<"$new_path:"
      new_path=${new_path_inner#:}
    fi
  elif $add_elm; then
    new_path=$elm:$new_path
  elif $move; then
    new_path=$(path_remove "$elm")
    new_path=$elm:$new_path
  fi
  printf "%s\n" "$new_path"
}

path_contains() {
  local elm=${1%/} glob=${2:-false} path
  if [[ -z $elm || ! $glob =~ ^true|false$ ]]; then
    printf "Usage: path_contains ELM [GLOB]\n" >&2
    return 1
  fi
  while IFS= read -r -d ':' path; do
    # The unescaped rhs in the comparison is on purpose to allow for glob matching
    # shellcheck disable=2053
    if $glob && [[ ${path%/} = $elm ]]; then
      return 0
    fi
    if ! $glob && [[ ${path%/} = "$elm" ]]; then
      return 0
    fi
  done <<<"$PATH:"
  return 1
}

path_remove() {
  local elm=${1%/} matched=false new_path
  if [[ -z $elm ]]; then
    printf "Usage: path_contains ELM\n" >&2
    return 1
  fi
  while IFS= read -r -d ':' path; do
    if [[ ${path%/} != "$elm" ]] || $matched; then
      new_path=$new_path:$path
    else
      matched=true
    fi
  done <<<"$PATH:"
  printf "%s\n" "${new_path#:}"
}
