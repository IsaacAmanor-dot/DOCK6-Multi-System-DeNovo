#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/000.config.sh"

MAX_SYSTEMS="${1:-}"

if [[ ! -s "${SYSTEM_LIST}" ]]; then
    echo "Missing ${SYSTEM_LIST}"
    echo "Run 001.discover_inputs.sh first."
    exit 1
fi

if [[ ! -s "${TASK_LIST}" ]]; then
    echo "Missing ${TASK_LIST}"
    echo "Run 003.make_task_list.sh first."
    exit 1
fi

if ! command -v sbatch >/dev/null 2>&1; then
    echo "ERROR: sbatch was not found."
    exit 1
fi

if [[ ! -s "${WORK_ROOT}/005.run_DN_systems.slurm" ]]; then
    echo "Missing 005.run_DN_systems.slurm"
    exit 1
fi

if [[ -n "${MAX_SYSTEMS}" ]] \
    && ! [[ "${MAX_SYSTEMS}" =~ ^[1-9][0-9]*$ ]]; then
    echo "ERROR: Maximum concurrent systems must be a positive integer."
    exit 1
fi

mkdir -p "${LOG_DIR}"

N_SYSTEMS=$(grep -cve '^[[:space:]]*$' "${SYSTEM_LIST}")
N_TASKS=$(awk 'END {print NR - 1}' "${TASK_LIST}")

if [[ "${N_SYSTEMS}" -lt 1 ]]; then
    echo "ERROR: No receptor systems were found."
    exit 1
fi

ARRAY_SPEC="1-${N_SYSTEMS}"

if [[ -n "${MAX_SYSTEMS}" ]]; then
    ARRAY_SPEC="${ARRAY_SPEC}%${MAX_SYSTEMS}"
fi

echo "Systems: ${N_SYSTEMS}"
echo "DN calculations: ${N_TASKS}"
echo "SLURM array: ${ARRAY_SPEC}"
echo

sbatch \
    --array="${ARRAY_SPEC}" \
    --output="${LOG_DIR}/DN_%A_%a.out" \
    --export="ALL,WORKFLOW_DIR=${WORK_ROOT}" \
    "${WORK_ROOT}/005.run_DN_systems.slurm"
