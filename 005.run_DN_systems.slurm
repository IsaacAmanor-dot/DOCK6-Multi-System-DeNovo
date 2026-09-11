#!/bin/bash

#SBATCH --partition=
#SBATCH --time=60:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=40
#SBATCH --cpus-per-task=1
#SBATCH --job-name=DN_data

set -uo pipefail

WORKFLOW_DIR="${WORKFLOW_DIR:-${SLURM_SUBMIT_DIR}}"

source "${WORKFLOW_DIR}/000.config.sh"

ARRAY_ID="${SLURM_ARRAY_TASK_ID:-}"

if [[ -z "${ARRAY_ID}" ]]; then
    echo "ERROR: No SLURM array task ID was detected."
    echo "Submit this script using a SLURM array."
    exit 1
fi

if [[ ! -s "${SYSTEM_LIST}" ]]; then
    echo "ERROR: System list not found:"
    echo "${SYSTEM_LIST}"
    exit 1
fi

if [[ ! -s "${TASK_LIST}" ]]; then
    echo "ERROR: Task list not found:"
    echo "${TASK_LIST}"
    exit 1
fi

SYSTEM=$(sed -n "${ARRAY_ID}p" "${SYSTEM_LIST}")

if [[ -z "${SYSTEM}" ]]; then
    echo "ERROR: Could not determine system for array task ${ARRAY_ID}"
    exit 1
fi

SYSTEM_RUN_DIR="${RUN_DIR}/${SYSTEM}"
SYSTEM_OUT="${SYSTEM_RUN_DIR}/system.out"

mkdir -p "${SYSTEM_RUN_DIR}"

exec > >(tee -a "${SYSTEM_OUT}") 2>&1

echo "Starting system: ${SYSTEM}"
echo "Array task: ${ARRAY_ID}"
echo "SLURM job: ${SLURM_JOB_ID}"
echo "Node: $(hostname)"
echo "Allocated tasks: ${SLURM_NTASKS:-1}"
echo

mapfile -t TASK_IDS < <(
    awk -F '\t' -v SYS="${SYSTEM}" '
        NR > 1 && $2 == SYS {
            print $1
        }
    ' "${TASK_LIST}"
)

N_TASKS=${#TASK_IDS[@]}

if [[ "${N_TASKS}" -eq 0 ]]; then
    echo "ERROR: No DN calculations found for ${SYSTEM}"
    exit 1
fi

echo "DN calculations for ${SYSTEM}: ${N_TASKS}"
echo

MAX_PARALLEL="${SLURM_NTASKS:-1}"

RUNNING=0
FAILURES=0

for TASK_ID in "${TASK_IDS[@]}"; do

    echo "Launching task ${TASK_ID}"

    srun \
        --exclusive \
        -N1 \
        -n1 \
        bash "${WORKFLOW_DIR}/004.run_one_task.slurm" "${TASK_ID}" &

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
echo "Finished system: ${SYSTEM}"
echo "DN calculations: ${N_TASKS}"
echo "Failed worker exits: ${FAILURES}"
