#!/usr/bin/env bash
loginctl | egrep -v "root|SESSION|listed" | awk '{print $1}' | xargs loginctl terminate-session
