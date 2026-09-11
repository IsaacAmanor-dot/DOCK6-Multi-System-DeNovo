#!/bin/bash

#SBATCH --partition=
#SBATCH --time=60:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --job-name=DN_one

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${SCRIPT_DIR}/000.config.sh"

TASK_ID="${1:-}"

if [[ -z "${TASK_ID}" ]]; then
    echo "Usage: sbatch 004.run_one_task.slurm TASK_ID"
    exit 1
fi

TASK_LINE=$(awk -F '\t' -v ID="${TASK_ID}" '
    NR > 1 && $1 == ID {
        print
        exit
    }
' "${TASK_LIST}")

if [[ -z "${TASK_LINE}" ]]; then
    echo "Could not find task ${TASK_ID}"
    exit 1
fi

IFS=$'\t' read -r TASK_ID SYSTEM ANCHOR ANCHOR_FILE CALC_DIR <<< "${TASK_LINE}"

INPUT_FILE="${CALC_DIR}/DN.in"
OUTPUT_FILE="${CALC_DIR}/DN.out"
MOL2_FILE="${CALC_DIR}/DOCK_DN.denovo_build.mol2"

if [[ ! -d "${CALC_DIR}" ]]; then
    echo "Calculation directory does not exist:"
    echo "${CALC_DIR}"
    exit 1
fi

if [[ ! -s "${INPUT_FILE}" ]]; then
    echo "Missing input file:"
    echo "${INPUT_FILE}"
    exit 1
fi

cd "${CALC_DIR}" || exit 1

if [[ -s "${MOL2_FILE}" ]] && grep -q '^@<TRIPOS>MOLECULE' "${MOL2_FILE}"; then
    echo "Task ${TASK_ID}: ${SYSTEM} ${ANCHOR} already completed."
    touch .success
    rm -f .failed
    exit 0
fi

rm -f .success .failed

echo "Task: ${TASK_ID}"
echo "System: ${SYSTEM}"
echo "Anchor: ${ANCHOR}"
echo "Node: $(hostname)"
echo "Input: ${INPUT_FILE}"
echo "Output: ${OUTPUT_FILE}"
echo

"${DOCK_BIN}" \
    -i "${INPUT_FILE}" \
    -o "${OUTPUT_FILE}"

EXIT_CODE=$?

if [[ "${EXIT_CODE}" -eq 0 ]] \
    && [[ -s "${MOL2_FILE}" ]] \
    && grep -q '^@<TRIPOS>MOLECULE' "${MOL2_FILE}"; then

    touch .success
    rm -f .failed

    N_MOLS=$(grep -c '^@<TRIPOS>MOLECULE' "${MOL2_FILE}")

    echo
    echo "Task ${TASK_ID} completed successfully."
    echo "Generated molecules: ${N_MOLS}"

    exit 0
fi

touch .failed
rm -f .success

echo
echo "Task ${TASK_ID} failed."
echo "DOCK exit code: ${EXIT_CODE}"

exit 1
