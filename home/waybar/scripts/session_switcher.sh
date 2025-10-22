#!/bin/bash
other_sessions=$(loginctl list-sessions --no-legend|awk '/online/{print $1}')
if [ "${other_sessions// /}" != "${other_sessions}" ]
then
  # more than on extra session
  other_sessions="$(yad \
    --name=session-picker \
    --list \
    --hide-header \
    --title="Switch session" \
    --text="Please pick a session" \
    --column=SESSION \
    --column=USER \
    --separator="" \
    --print-column=1 \
    "$(loginctl list-sessions --no-legend|awk '/online/{print $1,$3}')" \
  )"
fi

if [ -n "${other_sessions}" ]
then
  loginctl activate "${other_sessions}"
fi
