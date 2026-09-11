#!/bin/bash

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/000.config.sh"

TASK_ID="${1:-}"

if [[ -z "${TASK_ID}" ]]; then
    echo "Usage: $0 TASK_ID"
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

cd "${CALC_DIR}" || exit 1

if [[ -s "${MOL2_FILE}" ]] && grep -q '^@<TRIPOS>MOLECULE' "${MOL2_FILE}"; then

    echo "Task ${TASK_ID}: ${SYSTEM} ${ANCHOR} already completed."

    touch .success
    rm -f .failed

    exit 0
fi

rm -f .success .failed

echo "Running task ${TASK_ID}"
echo "System: ${SYSTEM}"
echo "Anchor: ${ANCHOR}"
echo "Directory: ${CALC_DIR}"

"${DOCK_BIN}" -i "${INPUT_FILE}" -o "${OUTPUT_FILE}"

EXIT_CODE=$?

if [[ "${EXIT_CODE}" -eq 0 ]] \
    && [[ -s "${MOL2_FILE}" ]] \
    && grep -q '^@<TRIPOS>MOLECULE' "${MOL2_FILE}"; then

    touch .success
    rm -f .failed

    N_MOLS=$(grep -c '^@<TRIPOS>MOLECULE' "${MOL2_FILE}")

    echo "Task ${TASK_ID} completed successfully."
    echo "Generated molecules: ${N_MOLS}"

    exit 0
fi

touch .failed
rm -f .success

echo "Task ${TASK_ID} failed."
echo "DOCK exit code: ${EXIT_CODE}"

exit 1

