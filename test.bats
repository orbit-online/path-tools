#!/usr/bin/env bats
# shellcheck disable=2030,2031

setup_file() {
  bats_require_minimum_version 1.5.0
  export PATH=$BATS_TEST_DIRNAME:$HOME/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
}

@test 'path_append appends' {
  run path_append.sh TEST
  [ "$output" = "$PATH:TEST" ]
}

@test 'path_prepend prepends' {
  run path_prepend.sh TEST
  [ "$output" = "TEST:$PATH" ]
}

@test 'path_insert_after with match inserts after match' {
  run path_insert_after.sh TEST /usr/bin
  [ "$output" = "$BATS_TEST_DIRNAME:$HOME/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:TEST:/sbin:/bin" ]
}

@test 'path_insert_after without match appends' {
  run path_insert_after.sh TEST UNMATCHED
  [ "$output" = "$BATS_TEST_DIRNAME:$HOME/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:TEST" ]
}

@test 'path_insert_after with glob match inserts after last match' {
  run path_insert_after.sh TEST '*/?(.)local/*'
  [ "$output" = "$BATS_TEST_DIRNAME:$HOME/.local/bin:/usr/local/sbin:/usr/local/bin:TEST:/usr/sbin:/usr/bin:/sbin:/bin" ]
}

@test 'path_insert_after works with invalid \$PATH' {
  PATH=$BATS_TEST_DIRNAME:$HOME/.local/bin:/usr/sbin::/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:
  run path_insert_after.sh TEST '*/?(.)local/*'
  [ "$output" = "$BATS_TEST_DIRNAME:$HOME/.local/bin:/usr/sbin::/usr/local/sb"$'\0'"in:/usr/local/bin:TEST:/usr/sbin:/usr/bin:/sbin:/bin:" ]
}

@test 'path_insert_before with match inserts before match' {
  run path_insert_before.sh TEST /usr/local/bin
  [ "$output" = "$BATS_TEST_DIRNAME:$HOME/.local/bin:/usr/local/sbin:TEST:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" ]
}

@test 'path_insert_before without match appends' {
  run path_insert_before.sh TEST UNMATCHED
  [ "$output" = "$BATS_TEST_DIRNAME:$HOME/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:TEST" ]
}

@test 'path_remove removes literal match' {
  run path_remove.sh /usr/local/bin
  [ "$output" = "$BATS_TEST_DIRNAME:$HOME/.local/bin:/usr/local/sbin:/usr/sbin:/usr/bin:/sbin:/bin" ]
}

@test 'path_remove ignores trailing slash on comparator' {
  run path_remove.sh /usr/local/bin/
  [ "$output" = "$BATS_TEST_DIRNAME:$HOME/.local/bin:/usr/local/sbin:/usr/sbin:/usr/bin:/sbin:/bin" ]
}

@test 'path_remove does not ignore trailing slash on glob' {
  run path_remove.sh /usr/local/bin/ true
  [ "$output" = "$BATS_TEST_DIRNAME:$HOME/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" ]
}

@test 'path_contains finds literal match' {
  run path_contains.sh /usr/local/bin
}

@test 'path_contains ignores trailing slash on comparator' {
  run path_contains.sh /usr/local/bin/
}

@test 'path_contains does not ignore trailing slash on glob' {
  run -1 path_contains.sh /usr/local/bin/ true
}

@test 'path_validate passes well-formed $PATH' {
  run path_validate.sh
}

@test 'path_validate fails $PATH with nul byte' {
  PATH=$PATH:$'\0'
  run -1 path_validate.sh
}

@test 'path_validate fails $PATH with empty string' {
  PATH=$PATH:
  run -1 path_validate.sh
}

@test 'path_validate fails $PATH with duplicates' {
  PATH=$PATH:/usr/local/bin
  run -1 path_validate.sh
}
