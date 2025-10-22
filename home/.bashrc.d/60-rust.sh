#!/bin/bash
bin_path="${HOME}/.cargo/bin"
[ -d ${bin_path} ] && export PATH="${bin_path}:${PATH}"
cargo_env="${HOME}/.cargo/env"
[ -f ${cargo_env} ] && source ${cargo_env}
