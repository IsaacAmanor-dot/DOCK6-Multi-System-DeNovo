#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${SCRIPT_DIR}/000.config.sh"


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
    echo "This workflow requires a SLURM environment for production submission."
    exit 1
fi


mkdir -p "${LOG_DIR}"


N_SYSTEMS=$(wc -l < "${SYSTEM_LIST}")
N_TASKS=$(awk 'END {print NR-1}' "${TASK_LIST}")


SBATCH_ARGS=(
    --array="1-${N_SYSTEMS}%${MAX_SYSTEM_JOBS}"
    --nodes=1
    --ntasks="${TASKS_PER_NODE}"
    --cpus-per-task=1
    --time="${WALLTIME}"
    --output="${LOG_DIR}/DN_%A_%a.out"
    --export="ALL,WORKFLOW_DIR=${WORK_ROOT}"
)


if [[ -n "${PARTITION}" ]]; then
    SBATCH_ARGS+=(--partition="${PARTITION}")
fi


echo "Systems: ${N_SYSTEMS}"
echo "DN calculations: ${N_TASKS}"

sbatch \
    "${SBATCH_ARGS[@]}" \
    "${WORK_ROOT}/005.run_DN_systems.slurm"
