#!/usr/bin/env bash
set -euo pipefail

dump_dir=${DUMP_DIR:-/data/dump/dvds}
mkdir -p "${dump_dir}"
device=${DVD_DEVICE:-/dev/sr0}

rip_disc() {
  local dest=$1 titles title_num
  titles=$(HandBrakeCLI --input "${device}" --title 0 --scan 2>&1 |
    awk '/^\s+\+ title [0-9]+:/ { print $3 }' | tr -d ':')

  for title_num in ${titles}; do
    local duration
    duration=$(HandBrakeCLI --input "${device}" --title "${title_num}" --scan 2>&1 |
      awk '/duration:/ { print $2 }')
    # skip anything under 10 minutes
    local mins
    mins=$(echo "${duration}" | awk -F: '{ print $1 * 60 + $2 }')
    [[ ${mins} -lt 10 ]] && continue

    HandBrakeCLI \
      --input "${device}" \
      --title "${title_num}" \
      --output "${dest}/title_$(printf '%02d' "${title_num}").mkv" \
      --encoder x264 \
      --quality 20 \
      --audio 1 \
      --aencoder av_aac \
      --subtitle scan \
      --subtitle-forced \
      --format av_mkv \
      >&2
  done
}

disc_label() {
  lsdvd "${device}" | sed -n 's/^Disc Title: //p' | tr '_' ' '
}

disc_runtime() {
  lsdvd "${device}" | awk '
    /^Title:/ { gsub(/,/, "", $2); split($4, t, ":"); m[$2] = t[1] * 60 + t[2] }
    /^Longest track:/ { printf "%d\n", m[$3] }
  '
}

rip_main_feature() {
  local dest=$1
  HandBrakeCLI \
    --input "${device}" \
    --output "${dest}" \
    --encoder x264 \
    --quality 20 \
    --audio 1 \
    --aencoder av_aac \
    --subtitle scan \
    --subtitle-forced \
    --format av_mkv \
    --main-feature \
    >&2
}

ripdvd() {
  local label title dest
  label=$(disc_label)
  echo "disc: '${label}'" >&2

  if [[ $# -ge 1 ]]; then
    title=$1
  else
    read -rp "title [${label}]: " title
    title=${title:-${label}}
  fi

  title=${title//\//-}
  dest="${dump_dir}/${title}"
  mkdir -p "${dest}"
  rip_disc "${dest}"
  echo "${dest}"
}

ripdvd "$@"
