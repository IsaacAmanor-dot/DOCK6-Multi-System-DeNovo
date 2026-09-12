#!/bin/bash
#SBATCH --partition=rn-long-40core
#SBATCH --time=120:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=5
#SBATCH --job-name=DN_data

set -uo pipefail

WORKFLOW_DIR="${WORKFLOW_DIR:-${SLURM_SUBMIT_DIR:-$(pwd)}}"
source "${WORKFLOW_DIR}/000.config.sh"

ARRAY_ID="${SLURM_ARRAY_TASK_ID:-}"

if [[ -z "${ARRAY_ID}" ]]; then
    echo "ERROR: No SLURM array task ID was detected."
    echo "Submit this script as a SLURM array job."
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

: > "${SYSTEM_OUT}"

exec > >(tee -a "${SYSTEM_OUT}") 2>&1

echo "Starting system: ${SYSTEM}"
echo "Array task: ${ARRAY_ID}"
echo "SLURM job: ${SLURM_JOB_ID:-unknown}"
echo "Node: $(hostname)"
echo "CPUs allocated: ${SLURM_CPUS_PER_TASK:-1}"
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

echo "Anchor calculations for ${SYSTEM}: ${N_TASKS}"
echo

PIDS=()
ACTIVE_TASKS=()

for TASK_ID in "${TASK_IDS[@]}"; do
    echo "Launching task ${TASK_ID}"

    bash "${WORKFLOW_DIR}/004.run_one_task.slurm" "${TASK_ID}" &

    PIDS+=("$!")
    ACTIVE_TASKS+=("${TASK_ID}")
done

echo
echo "All ${N_TASKS} anchor calculations launched concurrently."
echo

FAILURES=0

for I in "${!PIDS[@]}"; do
    PID="${PIDS[$I]}"
    TASK_ID="${ACTIVE_TASKS[$I]}"

    if wait "${PID}"; then
        echo "Task ${TASK_ID} completed successfully."
    else
        echo "Task ${TASK_ID} failed."
        FAILURES=$((FAILURES + 1))
    fi
done

echo
echo "Finished system: ${SYSTEM}"
echo "Anchor calculations: ${N_TASKS}"
echo "Failed calculations: ${FAILURES}"

if [[ "${FAILURES}" -gt 0 ]]; then
    exit 1
fi

exit 0
