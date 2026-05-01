#!/usr/bin/env bash
# Creates the SSH control socket directory required for connection multiplexing.
# Matches the ControlPath in dot_ssh/config.tmpl.
set -o errexit -o nounset -o pipefail

mkdir -p "$HOME/.ssh/sockets"
chmod 700 "$HOME/.ssh/sockets"
