#!/bin/bash
t="${HOME}/programming/android/tools"
pt="${HOME}/programming/android/platform-tools"
[ -d ${t} ] && PATH="${PATH}:${t}"
[ -d ${pt} ] && PATH="${PATH}:${pt}"
unset t pt
export PATH
