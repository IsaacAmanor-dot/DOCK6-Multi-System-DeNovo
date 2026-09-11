#!/bin/bash

#SBATCH --partition=long-28core
#SBATCH --time=48:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=28
#SBATCH --cpus-per-task=1
#SBATCH --job-name=DN_data

set -uo pipefail

WORKFLOW_DIR="${WORKFLOW_DIR:-${SLURM_SUBMIT_DIR}}"

source "${WORKFLOW_DIR}/000.config.sh"

ARRAY_ID="${SLURM_ARRAY_TASK_ID}"

SYSTEM=$(sed -n "${ARRAY_ID}p" "${SYSTEM_LIST}")

if [[ -z "${SYSTEM}" ]]; then
    echo "Could not determine system for array task ${ARRAY_ID}"
    exit 1
fi

echo "Starting system ${SYSTEM}"
echo "Node: $(hostname)"
echo "Available tasks: ${SLURM_NTASKS}"
echo

mapfile -t TASK_IDS < <(
    awk -F '\t' -v SYS="${SYSTEM}" '
        NR > 1 && $2 == SYS {
            print $1
        }
    ' "${TASK_LIST}"
)

N_TASKS=${#TASK_IDS[@]}

echo "DN calculations for ${SYSTEM}: ${N_TASKS}"
echo

MAX_PARALLEL="${SLURM_NTASKS:-28}"
RUNNING=0
FAILURES=0

for TASK_ID in "${TASK_IDS[@]}"; do

    srun \
        --exclusive \
        -N1 \
        -n1 \
        bash "${WORKFLOW_DIR}/004.run_one_task.sh" "${TASK_ID}" &

    RUNNING=$((RUNNING + 1))

    if [[ "${RUNNING}" -ge "${MAX_PARALLEL}" ]]; then

        if ! wait -n; then
            FAILURES=$((FAILURES + 1))
        fi

        RUNNING=$((RUNNING - 1))
    fi

done

while [[ "${RUNNING}" -gt 0 ]]; do

    if ! wait -n; then
        FAILURES=$((FAILURES + 1))
    fi

    RUNNING=$((RUNNING - 1))

done

echo
echo "Finished system ${SYSTEM}"
echo "Observed failed worker exits: ${FAILURES}"

