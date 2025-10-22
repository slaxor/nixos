#!/bin/bash
export GOPATH=${HOME}/programming/go
export GO111MODULE=on
export MYGODIR="${GOPATH}/src/codeberg.org/slaxor"
export PATH="${PATH}:${GOPATH}/bin"

godrop() {
  go clean "${1}"
  rm -rf "${GOPATH}/src/${1}"
}

mkgoprj() {
  local prjname="${1}"
  local srcname="${2:-${prjname}}"
  local prjpath="${GOPATH}/src/codeberg.org/slaxor/${prjname}"
  mkdir -p "${prjpath}"
  cd "${prjpath}"
  cat > "Makefile" << __EOL__
.DEFAULT_GOAL := test

.PHONY: debug
debug:
	dlv test -v ./...

.PHONY: test
test:
	go test -v ./...

__EOL__

cat > "${srcname}.go" << __EOL__
package ${prjname}

func $srcname() error {
  return nil
}
__EOL__

  cat > "${srcname}_test.go" <<  __EOL__
package ${prjname}

import (
	"testing"
	"github.com/stretchr/testify/assert"
)

func Test_$srcname(t *testing.T) {
  err := $srcname()
  assert.NoError(t, err)
}
__EOL__


  go mod init "codeberg.org/slaxor/${prjname}"
  go mod tidy
  git init
  git add .
  git commit -m "Initial commit"
  git remote add origin "git@codeberg.org/slaxor/${prjname}.git"
  # git push -u origin master
}



cdgo() { cd ${MYGODIR}/${1}; }

# gosandbox() {
  # set -x
  # local PACKAGE=${1:-main}
  # local SBDIR=${SBDIR:-${MYGODIR}/sandbox}
  # local WDIR=${SBDIR}/${PACKAGE}
  # if [ -d ${WDIR} ]
  # then
    # echo "${WDIR} exists do you want to [e]dit it, [c]reate a new one or [c]ancel? (e/n/c)"
    # case $(read) in
        # e)
          # cd ${WDIR}
          # gvim $(find . -type f -name "*.go")
        # ;;
    # esac
  # local WDIR=$(mktemp --directory --tmpdir=${SBDIR} -t ${PACKAGE}-XXX)
  # cd ${WDIR}

  # set +x
# }
