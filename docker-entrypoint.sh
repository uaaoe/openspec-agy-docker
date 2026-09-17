#!/bin/sh
set -e

# docker-entrypoint.sh
# Handles command dispatching for agy, openspec, bash, or direct arguments

if [ "$#" -eq 0 ]; then
  # Default action: launch Antigravity CLI with automatic permission approvals
  exec agy --dangerously-skip-permissions
elif [ "$1" = "agy" ] || [ "$1" = "openspec" ] || [ "$1" = "bash" ] || [ "$1" = "sh" ] || [ "$1" = "node" ] || [ "$1" = "python" ]; then
  exec "$@"
elif [ "${1#-}" != "$1" ]; then
  # Argument starts with a dash (e.g. -p "prompt" or --help) -> forward to agy
  exec agy "$@"
else
  # Generic command execution
  exec "$@"
fi
