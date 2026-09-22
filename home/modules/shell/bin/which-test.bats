#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

setup() {
  tmp=$(mktemp -d)
  cmd="${tmp}/testcmd"
  l1="${tmp}/l1"
  l2="${tmp}/l2"
  touch "${cmd}"
  chmod +x "${cmd}"
  ln -s "${cmd}" "${l1}"
  ln -s "${l1}" "${l2}"
  export PATH="${tmp}:${PATH}"
  ln -s "${l2}" "${tmp}/target"
}

teardown() {
  rm -rf "${tmp}"
}

@test "resolves through multi-hop symlink chain to real path" {
  run which target
  [ "${status}" -eq 0 ]
  [ "${output}" = "${cmd}" ]
}

@test "exits 1 and prints nothing to stdout when target not found" {
  run --separate-stderr which nonexistentcmd
  [ "${status}" -eq 1 ]
  [ -z "${stdout}" ]
}

@test "stdout stays clean even with link chain (capture case)" {
  result=$(which target)
  [ "${result}" = "${cmd}" ]
}
