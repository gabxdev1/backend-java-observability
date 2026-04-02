#!/usr/bin/env bash

# Duplica stdout/stderr da shell interativa para o stdout/stderr do PID 1.
# Isso permite que o logging driver do container encaminhe logs de comandos
# rodados via terminal do devcontainer (docker exec), sem usar arquivo.
if [[ "${DD_LOG_BRIDGE_ENABLED:-1}" != "1" ]]; then
  return 0 2>/dev/null || exit 0
fi

if [[ ! -t 1 ]]; then
  return 0 2>/dev/null || exit 0
fi

if [[ "${DD_LOG_BRIDGE_ACTIVE:-0}" == "1" ]]; then
  return 0 2>/dev/null || exit 0
fi

if [[ ! -w /proc/1/fd/1 ]] || [[ ! -w /proc/1/fd/2 ]]; then
  return 0 2>/dev/null || exit 0
fi

if ! command -v tee >/dev/null 2>&1; then
  return 0 2>/dev/null || exit 0
fi

export DD_LOG_BRIDGE_ACTIVE=1
exec > >(tee /proc/1/fd/1) 2> >(tee /proc/1/fd/2 >&2)
