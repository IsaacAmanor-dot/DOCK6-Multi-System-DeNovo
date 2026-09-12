#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/000.config.sh"

ERRORS=0

check_config()
{
    local NAME="$1"
    local VALUE="$2"

    if [[ -z "${VALUE}" ]]; then
        echo "CONFIGURATION REQUIRED: ${NAME}"
        ERRORS=$((ERRORS + 1))
    fi
}

echo "Checking workflow configuration..."
echo

check_config "SYSTEM_ROOT" "${SYSTEM_ROOT}"
check_config "ANCHOR_ROOT" "${ANCHOR_ROOT}"
check_config "DOCK_ROOT" "${DOCK_ROOT}"
check_config "DN_LIBRARY_ROOT" "${DN_LIBRARY_ROOT}"

if [[ "${ERRORS}" -ne 0 ]]; then
    echo
    echo "Configuration is incomplete."
    echo "Edit 000.config.sh before continuing."
    exit 1
fi

if [[ ! -d "${SYSTEM_ROOT}" ]]; then
    echo "ERROR: SYSTEM_ROOT does not exist:"
    echo "${SYSTEM_ROOT}"
    exit 1
fi

if [[ ! -d "${ANCHOR_ROOT}" ]]; then
    echo "ERROR: ANCHOR_ROOT does not exist:"
    echo "${ANCHOR_ROOT}"
    exit 1
fi

if [[ ! -d "${DOCK_ROOT}" ]]; then
    echo "ERROR: DOCK_ROOT does not exist:"
    echo "${DOCK_ROOT}"
    exit 1
fi

if [[ ! -d "${DN_LIBRARY_ROOT}" ]]; then
    echo "ERROR: DN_LIBRARY_ROOT does not exist:"
    echo "${DN_LIBRARY_ROOT}"
    exit 1
fi

mkdir -p \
    "${STATE_DIR}" \
    "${RUN_DIR}" \
    "${LOG_DIR}" \
    "${COMBINED_DIR}"

echo "Discovering receptor systems..."

find "${SYSTEM_ROOT}" \
    -mindepth 1 \
    -maxdepth 1 \
    -type d \
    -printf '%f\n' \
    | sort -V \
    > "${SYSTEM_LIST}"

echo "Discovering anchor fragments..."

find "${ANCHOR_ROOT}" \
    -maxdepth 1 \
    -type f \
    -name 'anchor_*.mol2' \
    -printf '%f\n' \
    | sort -V \
    > "${ANCHOR_LIST}"

N_SYSTEMS=$(wc -l < "${SYSTEM_LIST}")
N_ANCHORS=$(wc -l < "${ANCHOR_LIST}")

if [[ "${N_SYSTEMS}" -eq 0 ]]; then
    echo "ERROR: No receptor-system directories were discovered."
    exit 1
fi

if [[ "${N_ANCHORS}" -eq 0 ]]; then
    echo "ERROR: No anchor_*.mol2 files were discovered."
    exit 1
fi

echo
echo "Systems found: ${N_SYSTEMS}"
echo "Anchors found: ${N_ANCHORS}"
echo "Expected DN calculations: $((N_SYSTEMS * N_ANCHORS))"
echo

ERRORS=0

echo "Checking receptor-system files..."

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
echo "Checking anchor fragments..."

while read -r ANCHOR_FILE; do

    ANCHOR_PATH="${ANCHOR_ROOT}/${ANCHOR_FILE}"

    if [[ ! -s "${ANCHOR_PATH}" ]]; then
        echo "MISSING: ${ANCHOR_PATH}"
        ERRORS=$((ERRORS + 1))
    fi

done < "${ANCHOR_LIST}"

echo
echo "Checking DOCK6.13 files..."

COMMON_FILES=(
    "${DOCK_BIN}"
    "${VDW_DEFN_FILE}"
    "${FLEX_DEFN_FILE}"
    "${FLEX_DRIVE_FILE}"
    "${SCAFFOLD_LIBRARY}"
    "${LINKER_LIBRARY}"
    "${SIDECHAIN_LIBRARY}"
    "${TORENV_TABLE}"
)

for FILE in "${COMMON_FILES[@]}"; do

    if [[ ! -s "${FILE}" ]]; then
        echo "MISSING: ${FILE}"
        ERRORS=$((ERRORS + 1))
    fi

done

if [[ -s "${DOCK_BIN}" ]] && [[ ! -x "${DOCK_BIN}" ]]; then
    echo "NOT EXECUTABLE: ${DOCK_BIN}"
    ERRORS=$((ERRORS + 1))
fi

echo

if [[ "${ERRORS}" -ne 0 ]]; then
    echo "Preflight validation failed with ${ERRORS} problem(s)."
    exit 1
fi

echo "Preflight validation passed."
echo
echo "Systems found: ${N_SYSTEMS}"
echo "Anchors found: ${N_ANCHORS}"
echo "DN calculations: $((N_SYSTEMS * N_ANCHORS))"
