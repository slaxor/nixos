#!/usr/bin/env bats

setup() {
  tmpdir="$(mktemp -d)"
  peers_dir="${tmpdir}/peers"
  users_db="${tmpdir}/users"
  networks_db="${tmpdir}/networks"
  mkdir -p "${peers_dir}"

  # shellcheck source=wg-peers.sh
  source "$(dirname ${0}%/wg-peers.sh"

  # override globals after sourcing
  peers_dir="${tmpdir}/peers"
  users_db="${tmpdir}/users"
  networks_db="${tmpdir}/networks"

  cat > "${users_db}" << 'EOF'
slash    10.13.0.16/28
eggert   10.13.0.32/28
ming     10.13.0.48/28
EOF

  mkdir -p "${peers_dir}/slash"
  cat > "${peers_dir}/slash/kea.conf" << 'EOF'
[Peer]
# device=kea
PublicKey = Ah8uUMZI5pbrHmn2D2l74G2IW3hcjtEWXtRFXebMLDg=
PresharedKey = abc123==
AllowedIPs = 10.13.0.17/32
EOF

  cat > "${peers_dir}/slash/fritzbox.conf" << 'EOF'
[Peer]
# device=fritzbox
PublicKey = KoRnZG8F5Ev/KmGaXqQNvECXaNAsH7TD5QtdaYKOJiE=
PresharedKey = def456==
AllowedIPs = 10.13.0.19/32, 192.168.178.0/24
EOF
}

teardown() {
  rm -rf "${tmpdir}"
}

# --- ip_to_int / int_to_ip ---

@test "ip_to_int: known value" {
  run ip_to_int "10.13.0.1"
  [ "${status}" -eq 0 ]
  [ "${output}" = "168624129" ]
}

@test "ip_to_int / int_to_ip: roundtrip" {
  local ips=("10.13.0.1" "192.168.178.1" "0.0.0.0" "255.255.255.255")
  for ip in "${ips[@]}"; do
    result=$(int_to_ip "$(ip_to_int "${ip}")")
    [ "${result}" = "${ip}" ]
  done
}

# --- subnet_range ---

@test "subnet_range: /28 start and end" {
  run subnet_range "10.13.0.16/28"
  [ "${status}" -eq 0 ]
  local start end
  read -r start end <<< "${output}"
  [ "${start}" = "$(ip_to_int "10.13.0.16")" ]
  [ "${end}"   = "$(ip_to_int "10.13.0.31")" ]
}

@test "subnet_range: /24 start and end" {
  run subnet_range "192.168.1.0/24"
  local start end
  read -r start end <<< "${output}"
  [ "${start}" = "$(ip_to_int "192.168.1.0")" ]
  [ "${end}"   = "$(ip_to_int "192.168.1.255")" ]
}

# --- subnets_overlap ---

@test "subnets_overlap: identical subnets" {
  run subnets_overlap "10.13.0.16/28" "10.13.0.16/28"
  [ "${status}" -eq 0 ]
}

@test "subnets_overlap: subnet contains the other" {
  run subnets_overlap "192.168.0.0/16" "192.168.1.0/24"
  [ "${status}" -eq 0 ]
}

@test "subnets_overlap: partial overlap" {
  run subnets_overlap "192.168.1.0/24" "192.168.1.128/25"
  [ "${status}" -eq 0 ]
}

@test "subnets_overlap: adjacent, no overlap" {
  run subnets_overlap "10.13.0.16/28" "10.13.0.32/28"
  [ "${status}" -eq 1 ]
}

@test "subnets_overlap: clearly disjoint" {
  run subnets_overlap "192.168.1.0/24" "10.0.0.0/8"
  [ "${status}" -eq 1 ]
}

# --- next_ip ---

@test "next_ip: first host when none taken" {
  run next_ip "10.13.0.16/28"
  [ "${status}" -eq 0 ]
  [ "${output}" = "10.13.0.17" ]
}

@test "next_ip: skips single taken ip" {
  run next_ip "10.13.0.16/28" "10.13.0.17"
  [ "${output}" = "10.13.0.18" ]
}

@test "next_ip: skips multiple taken ips" {
  run next_ip "10.13.0.16/28" "10.13.0.17" "10.13.0.18" "10.13.0.19"
  [ "${output}" = "10.13.0.20" ]
}

@test "next_ip: skips non-contiguous taken ips" {
  run next_ip "10.13.0.16/28" "10.13.0.17" "10.13.0.19"
  [ "${output}" = "10.13.0.18" ]
}

@test "next_ip: exhausted subnet" {
  run next_ip "10.13.0.16/28" \
    10.13.0.17 10.13.0.18 10.13.0.19 10.13.0.20 \
    10.13.0.21 10.13.0.22 10.13.0.23 10.13.0.24 \
    10.13.0.25 10.13.0.26 10.13.0.27 10.13.0.28 \
    10.13.0.29 10.13.0.30
  [ "${status}" -eq 1 ]
}

# --- peer_wg_ip ---

@test "peer_wg_ip: extracts /32 from simple conf" {
  run peer_wg_ip "${peers_dir}/slash/kea.conf"
  [ "${output}" = "10.13.0.17" ]
}

@test "peer_wg_ip: extracts /32 when extra subnets present" {
  run peer_wg_ip "${peers_dir}/slash/fritzbox.conf"
  [ "${output}" = "10.13.0.19" ]
}

# --- peer_extra_subnets ---

@test "peer_extra_subnets: empty when only /32" {
  run peer_extra_subnets "${peers_dir}/slash/kea.conf"
  [ "${output}" = "" ]
}

@test "peer_extra_subnets: returns LAN subnets" {
  run peer_extra_subnets "${peers_dir}/slash/fritzbox.conf"
  [ "${output}" = "192.168.178.0/24" ]
}

# --- taken_ips ---

@test "taken_ips: empty dir returns nothing" {
  mkdir -p "${peers_dir}/ming"
  run taken_ips "ming"
  [ "${output}" = "" ]
}

@test "taken_ips: returns all /32 ips for user" {
  run taken_ips "slash"
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"10.13.0.17"* ]]
  [[ "${output}" == *"10.13.0.19"* ]]
}

@test "taken_ips: does not return LAN subnets" {
  run taken_ips "slash"
  [[ "${output}" != *"192.168"* ]]
}

# --- client_allowed_ips ---

@test "client_allowed_ips: base only when no networks file" {
  rm -f "${networks_db}"
  run client_allowed_ips
  [ "${output}" = "10.13.0.0/24" ]
}

@test "client_allowed_ips: includes all networks" {
  printf "192.168.117.0/24 hermit-crab\n192.168.178.0/24 fritzbox\n" > "${networks_db}"
  run client_allowed_ips
  [[ "${output}" == *"10.13.0.0/24"* ]]
  [[ "${output}" == *"192.168.117.0/24"* ]]
  [[ "${output}" == *"192.168.178.0/24"* ]]
}

@test "client_allowed_ips: skips comment lines" {
  printf "# comment\n192.168.117.0/24 hermit-crab\n" > "${networks_db}"
  run client_allowed_ips
  [[ "${output}" != *"# comment"* ]]
  [[ "${output}" == *"192.168.117.0/24"* ]]
}

# --- check_network_collisions ---

@test "check_network_collisions: no collision" {
  printf "192.168.117.0/24 hermit-crab\n" > "${networks_db}"
  run check_network_collisions "192.168.178.0/24"
  [ "${status}" -eq 0 ]
}

@test "check_network_collisions: collision with networks file" {
  printf "192.168.117.0/24 hermit-crab\n" > "${networks_db}"
  run check_network_collisions "192.168.117.0/24"
  [ "${status}" -eq 1 ]
}

@test "check_network_collisions: collision with user peer subnet" {
  run check_network_collisions "10.13.0.32/28"
  [ "${status}" -eq 1 ]
}

@test "check_network_collisions: subnet contained in user peer subnet" {
  run check_network_collisions "10.13.0.20/32"
  [ "${status}" -eq 1 ]
}
