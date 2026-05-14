#!/usr/bin/env bats
# load 'lib.sh'

# reset_output() {
# echo "" >"$1"
# }

# setup() {
# tmpdir=$(mktemp -d --suffix="$(basename "$0")")
# }
# @tag repo_to_dir
@test "repo_to_dir simple substitution (Happy Path)" {
  repos=(
    "https://github.com/user/project.git"
    "git@github.com:user/project.git"
    "https://dev.azure.com/orga/project/_git/repo"
    "git@ssh.dev.azure.com:v3/orga/project/repo"
  )
  exp=(
    "/github.com/user/project"
    "/github.com/user/project"
    "/dev.azure.com/orga/project/repo"
    "/dev.azure.com/orga/project/repo"
  )
  for i in {0..2}; do
    output=$(repo_to_dir "${repos[$i]}")
    printf "\n\$output: %q\n\${exp[$i]}: %q\n" "$output" "${exp[$i]}"
    [[ "$output" = "${exp[$i]}" ]]
  done
}

