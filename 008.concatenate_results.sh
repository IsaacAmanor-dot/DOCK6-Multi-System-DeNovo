#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/000.config.sh"

if [[ ! -s "${TASK_LIST}" ]]; then
    echo "Missing ${TASK_LIST}"
    exit 1
fi

mkdir -p "${COMBINED_DIR}"

COMBINED_MOL2="${COMBINED_DIR}/All_DN_Generated.mol2"
MANIFEST="${COMBINED_DIR}/All_DN_Generated_manifest.tsv"

: > "${COMBINED_MOL2}"

printf "system\tanchor\tmolecules\tfirst_index\tlast_index\tsource_file\n" > "${MANIFEST}"

CURRENT_INDEX=0
SUCCESSFUL_FILES=0
TOTAL_MOLECULES=0

while IFS=$'\t' read -r TASK_ID SYSTEM ANCHOR ANCHOR_FILE CALC_DIR; do

    MOL2="${CALC_DIR}/DOCK_DN.denovo_build.mol2"

    if [[ ! -s "${MOL2}" ]]; then
        continue
    fi

    if ! grep -q '^@<TRIPOS>MOLECULE' "${MOL2}"; then
        continue
    fi

    N_MOLS=$(grep -c '^@<TRIPOS>MOLECULE' "${MOL2}")

    FIRST_INDEX=$((CURRENT_INDEX + 1))
    LAST_INDEX=$((CURRENT_INDEX + N_MOLS))

    cat "${MOL2}" >> "${COMBINED_MOL2}"

    printf "%s\t%s\t%d\t%d\t%d\t%s\n" \
        "${SYSTEM}" \
        "${ANCHOR}" \
        "${N_MOLS}" \
        "${FIRST_INDEX}" \
        "${LAST_INDEX}" \
        "${MOL2}" \
        >> "${MANIFEST}"

    CURRENT_INDEX="${LAST_INDEX}"
    SUCCESSFUL_FILES=$((SUCCESSFUL_FILES + 1))
    TOTAL_MOLECULES=$((TOTAL_MOLECULES + N_MOLS))

done < <(tail -n +2 "${TASK_LIST}")

echo
echo "Concatenation complete."
echo
echo "Successful DN outputs: ${SUCCESSFUL_FILES}"
echo "Total molecules:       ${TOTAL_MOLECULES}"
echo
echo "Combined MOL2:"
echo "${COMBINED_MOL2}"
echo
echo "Provenance manifest:"
echo "${MANIFEST}"

