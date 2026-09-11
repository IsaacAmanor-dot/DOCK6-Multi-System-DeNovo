#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/000.config.sh"

if [[ ! -s "${SYSTEM_LIST}" || ! -s "${ANCHOR_LIST}" ]]; then
    echo "System or anchor list is missing."
    exit 1
fi

printf "task_id\tsystem\tanchor\tanchor_file\tcalculation_directory\n" > "${TASK_LIST}"

TASK_ID=0

while read -r SYSTEM; do

    while read -r ANCHOR_FILE; do

        TASK_ID=$((TASK_ID + 1))

        ANCHOR_NAME="${ANCHOR_FILE%.mol2}"
        ANCHOR_PATH="${ANCHOR_ROOT}/${ANCHOR_FILE}"
        CALC_DIR="${RUN_DIR}/${SYSTEM}/${ANCHOR_NAME}"

        if [[ ! -s "${CALC_DIR}/DN.in" ]]; then
            echo "Missing DN.in for ${SYSTEM} ${ANCHOR_FILE}"
            exit 1
        fi

        printf "%d\t%s\t%s\t%s\t%s\n" \
            "${TASK_ID}" \
            "${SYSTEM}" \
            "${ANCHOR_NAME}" \
            "${ANCHOR_PATH}" \
            "${CALC_DIR}" \
            >> "${TASK_LIST}"

    done < "${ANCHOR_LIST}"

done < "${SYSTEM_LIST}"

echo "Created ${TASK_LIST}"
echo "Total tasks: ${TASK_ID}"

