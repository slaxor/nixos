#!/usr/bin/env bats
# source /home/slash/.bashrc.d/60_aliases.sh
source "${BATS_TEST_FILENAME//.bats/.sh}"
# set
#replace() { fd -t f -x sed -i -e "s/${1}/${2}/g {}" ;  fd -x mv "*{${1},${2}}*" ; }

# setup () {
# }

# teardown () {
# }

@test "replace()"  {
  expect=''
  testdir=$(mktemp -d /tmp/test_replace_XXXX)
  cd "${testdir}"
  mkdir -p olda/Old daold old/new
  for f in filea old/filea old/old
  do
    echo "The old fox jumps over the new dold Old" > "${f}"
  done
  replace old new
  result="$(fd .) $(fd -t f -x cat {})"
  echo rm -rf "${testdir}"
}


# @test "can do something" {
#   [ "$result" -eq ... ]
# }
