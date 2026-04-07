#!/usr/bin/env bash
set -euo pipefail

ENV_FILE="${1:-environment.yml}"
ENV_NAME="$(sed -n 's/^name:[[:space:]]*//p' "${ENV_FILE}" | head -n 1)"

if [[ -z "${ENV_NAME}" ]]; then
  echo "Could not determine the environment name from ${ENV_FILE}." >&2
  exit 1
fi

if conda env list | awk '{print $1}' | grep -Fxq "${ENV_NAME}"; then
  conda env update -f "${ENV_FILE}" --prune
else
  conda env create -f "${ENV_FILE}"
fi

echo
echo "Environment ${ENV_NAME} is ready."
echo "Activate it with: conda activate ${ENV_NAME}"
