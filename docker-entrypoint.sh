#!/bin/sh
set -e

# docker-entrypoint.sh
# Handles command dispatching for agy, openspec, bash, or direct arguments

# Synchronize OpenSpec workflow files from the image template into the mounted workspace
# This ensures workflows stay 100% aligned with upstream OpenSpec without hardcoding them in Git
if [ -d "/opt/openspec-template" ]; then
  # If .agents/workflows or .agents/skills exist in /opt/openspec-template, copy them into workspace
  if [ -d "/opt/openspec-template/.agents/workflows" ]; then
    mkdir -p /workspace/.agents/workflows
    cp -rn /opt/openspec-template/.agents/workflows/* /workspace/.agents/workflows/ 2>/dev/null || true
  fi
  if [ -d "/opt/openspec-template/.agents/skills" ]; then
    mkdir -p /workspace/.agents/skills
    cp -rn /opt/openspec-template/.agents/skills/* /workspace/.agents/skills/ 2>/dev/null || true
  fi
  if [ -d "/opt/openspec-template/.agent/workflows" ]; then
    mkdir -p /workspace/.agents/workflows
    cp -rn /opt/openspec-template/.agent/workflows/* /workspace/.agents/workflows/ 2>/dev/null || true
  fi
fi

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
