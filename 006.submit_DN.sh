#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/000.config.sh"

if [[ ! -s "${TASK_LIST}" ]]; then
    echo "Missing ${TASK_LIST}"
    echo "Run ./003.make_task_list.sh first."
    exit 1
fi

mkdir -p "${LOG_DIR}"

N_SYSTEMS=$(wc -l < "${SYSTEM_LIST}")
N_TASKS=$(awk 'END {print NR-1}' "${TASK_LIST}")

echo "Systems: ${N_SYSTEMS}"
echo "DN calculations: ${N_TASKS}"
echo "Cores per system job: ${TASKS_PER_NODE}"
echo "Maximum simultaneous systems: ${MAX_SYSTEM_JOBS}"
echo

sbatch \
    --array="1-${N_SYSTEMS}%${MAX_SYSTEM_JOBS}" \
    --partition="${PARTITION}" \
    --time="${WALLTIME}" \
    --ntasks="${TASKS_PER_NODE}" \
    --output="${LOG_DIR}/DN_%A_%a.out" \
    --export="ALL,WORKFLOW_DIR=${WORK_ROOT}" \
    "${WORK_ROOT}/005.run_DN_systems.slurm"

