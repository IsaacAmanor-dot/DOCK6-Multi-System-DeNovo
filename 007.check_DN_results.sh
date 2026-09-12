#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/000.config.sh"

if [[ ! -s "${TASK_LIST}" ]]; then
    echo "Missing ${TASK_LIST}"
    exit 1
fi

mkdir -p "${STATE_DIR}"

printf "task_id\tsystem\tanchor\tstatus\tmolecules\toutput\n" \
    > "${STATUS_FILE}"

while IFS=$'\t' read -r TASK_ID SYSTEM ANCHOR ANCHOR_FILE CALC_DIR; do

    MOL2="${CALC_DIR}/System_DN.denovo_build.mol2"
    DN_OUT="${CALC_DIR}/DN.out"

    if [[ -s "${MOL2}" ]] \
        && grep -q '^@<TRIPOS>MOLECULE' "${MOL2}"; then

        STATUS="SUCCESS"
        N_MOLS=$(grep -c '^@<TRIPOS>MOLECULE' "${MOL2}")

    elif [[ -f "${CALC_DIR}/.failed" ]]; then

        STATUS="FAILED"
        N_MOLS=0

    elif [[ -s "${DN_OUT}" ]]; then

        STATUS="INCOMPLETE"
        N_MOLS=0

    else

        STATUS="MISSING"
        N_MOLS=0

    fi

    printf "%s\t%s\t%s\t%s\t%s\t%s\n" \
        "${TASK_ID}" \
        "${SYSTEM}" \
        "${ANCHOR}" \
        "${STATUS}" \
        "${N_MOLS}" \
        "${MOL2}" \
        >> "${STATUS_FILE}"

done < <(tail -n +2 "${TASK_LIST}")

TOTAL=$(awk 'NR > 1 {n++} END {print n+0}' "${STATUS_FILE}")

SUCCESS=$(awk -F '\t' \
    '$4=="SUCCESS" {n++} END {print n+0}' \
    "${STATUS_FILE}")

FAILED=$(awk -F '\t' \
    '$4=="FAILED" {n++} END {print n+0}' \
    "${STATUS_FILE}")

INCOMPLETE=$(awk -F '\t' \
    '$4=="INCOMPLETE" {n++} END {print n+0}' \
    "${STATUS_FILE}")

MISSING=$(awk -F '\t' \
    '$4=="MISSING" {n++} END {print n+0}' \
    "${STATUS_FILE}")

TOTAL_MOLECULES=$(awk -F '\t' \
    'NR > 1 {sum += $5} END {print sum+0}' \
    "${STATUS_FILE}")

echo
echo "DN calculation status"
echo
echo "Total tasks:         ${TOTAL}"
echo "Successful:          ${SUCCESS}"
echo "Failed:              ${FAILED}"
echo "Incomplete/running:  ${INCOMPLETE}"
echo "Missing/not run:     ${MISSING}"
echo "Generated molecules: ${TOTAL_MOLECULES}"
echo
echo "Per-system summary:"
echo

printf "%-8s %8s %8s %8s %11s %8s %12s\n" \
    "System" \
    "Total" \
    "Success" \
    "Failed" \
    "Incomplete" \
    "Missing" \
    "Molecules"

awk -F '\t' '
NR > 1 {
    total[$2]++

    if ($4 == "SUCCESS")
        success[$2]++

    if ($4 == "FAILED")
        failed[$2]++

    if ($4 == "INCOMPLETE")
        incomplete[$2]++

    if ($4 == "MISSING")
        missing[$2]++

    molecules[$2] += $5
}

END {
    for (sys in total) {
        printf "%-8s %8d %8d %8d %11d %8d %12d\n",
            sys,
            total[sys],
            success[sys]+0,
            failed[sys]+0,
            incomplete[sys]+0,
            missing[sys]+0,
            molecules[sys]+0
    }
}
' "${STATUS_FILE}" | sort -V

echo
echo "Full status table:"
echo "${STATUS_FILE}"
