#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/000.config.sh"

mkdir -p "${STATE_DIR}" "${RUN_DIR}" "${LOG_DIR}" "${COMBINED_DIR}"

echo "Discovering systems..."

find "${SYSTEM_ROOT}" \
    -mindepth 1 \
    -maxdepth 1 \
    -type d \
    -printf '%f\n' \
    | sort -V > "${SYSTEM_LIST}"

echo "Discovering anchors..."

find "${ANCHOR_ROOT}" \
    -maxdepth 1 \
    -type f \
    -name 'anchor_*.mol2' \
    -printf '%f\n' \
    | sort -V > "${ANCHOR_LIST}"

N_SYSTEMS=$(wc -l < "${SYSTEM_LIST}")
N_ANCHORS=$(wc -l < "${ANCHOR_LIST}")

echo
echo "Systems found: ${N_SYSTEMS}"
echo "Anchors found: ${N_ANCHORS}"
echo "Expected DN calculations: $((N_SYSTEMS * N_ANCHORS))"
echo

ERRORS=0

echo "Checking system files..."

while read -r SYSTEM; do

    SYSTEM_DIR="${SYSTEM_ROOT}/${SYSTEM}"

    REQUIRED_FILES=(
        "${SYSTEM_DIR}/${SYSTEM}.rec.clust.close.sph"
        "${SYSTEM_DIR}/${SYSTEM}.rec.bmp"
        "${SYSTEM_DIR}/${SYSTEM}.rec.nrg"
        "${SYSTEM_DIR}/${SYSTEM}.lig.am1bcc.mol2"
    )

    for FILE in "${REQUIRED_FILES[@]}"; do
        if [[ ! -s "${FILE}" ]]; then
            echo "MISSING: ${FILE}"
            ERRORS=$((ERRORS + 1))
        fi
    done

done < "${SYSTEM_LIST}"

echo
echo "Checking anchors..."

while read -r ANCHOR; do

    FILE="${ANCHOR_ROOT}/${ANCHOR}"

    if [[ ! -s "${FILE}" ]]; then
        echo "MISSING: ${FILE}"
        ERRORS=$((ERRORS + 1))
    fi

done < "${ANCHOR_LIST}"

echo
echo "Checking common DOCK6.13 files..."

COMMON_FILES=(
    "${DOCK_BIN}"
    "${SCAFFOLD_LIBRARY}"
    "${LINKER_LIBRARY}"
    "${SIDECHAIN_LIBRARY}"
    "${TORENV_TABLE}"
    "${VDW_DEFN_FILE}"
    "${FLEX_DEFN_FILE}"
    "${FLEX_DRIVE_FILE}"
)

for FILE in "${COMMON_FILES[@]}"; do
    if [[ ! -s "${FILE}" ]]; then
        echo "MISSING: ${FILE}"
        ERRORS=$((ERRORS + 1))
    fi
done

echo

if [[ "${ERRORS}" -ne 0 ]]; then
    echo "Preflight validation failed with ${ERRORS} missing files."
    echo "Fix the paths or files before creating the DN calculations."
    exit 1
fi

echo "Preflight validation passed."
echo
echo "System list:"
cat "${SYSTEM_LIST}"
echo
echo "Anchor range:"
head -n 3 "${ANCHOR_LIST}"
echo "..."
tail -n 3 "${ANCHOR_LIST}"

