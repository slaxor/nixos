#! bats
load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'
# shellcheck source=./60-fns.sh
source "${0//.bats/.sh}"

setup() {
	TMPDIR="$(mktemp -d)"
	cd "${TMPDIR}" || exit 1
}

teardown() {
	rm -rf "${TMPDIR}"
}

@test "replace()" {
	# expect=''
	testdir=$(mktemp -d /tmp/test_replace_XXXX)
	cd "${testdir}"
	mkdir -p olda/Old daold old/new
	for f in filea old/filea old/old; do
		echo "The old fox jumps over the new dold Old" >"${f}"
	done
	replace old new
	# result="$(fd .) $(fd -t f -x cat {})"
	echo rm -rf "${testdir}"
}

@test "create folders and files from tree stdin" {
	run bash -c '
    cat <<EOF | tree2project
myproj/
├── flake.nix
├── lib/
│   ├── a.nix
│   └── b.nix
└── scripts/
    └── install.sh
EOF
  '

	# Root
	assert [ -d myproj ]

	# Verzeichnisse
	assert [ -d myproj/lib ]
	assert [ -d myproj/scripts ]

	# Dateien
	assert [ -f myproj/flake.nix ]
	assert [ -f myproj/lib/a.nix ]
	assert [ -f myproj/lib/b.nix ]
	assert [ -f myproj/scripts/install.sh ]
}

@test "cd to project root" {
	run bash -c '
    cat <<EOF | tree2project
proj/
└── file.txt
EOF
    pwd
  '

	assert_output --partial "/proj"
}

@test "open all files with \$EDITOR" {
	run bash -c '
    cat <<EOF | tree2project
proj/
├── a.txt
└── b.txt
EOF
  '

	assert [ -f proj/vim.log ]
	run cat proj/vim.log
	assert_output --partial "a.txt"
	assert_output --partial "b.txt"
}

# @test "can do something" {
#   [ "${result}" -eq ... ]
# }
