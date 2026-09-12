#!/bin/bash

# Central configuration for the multi-system DOCK6.13 De Novo workflow.

CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Workflow directory

WORK_ROOT="${CONFIG_DIR}"

# Receptor systems

# Directory containing one directory per receptor system.
# Example:
# SYSTEM_ROOT="/path/to/receptor/systems"

SYSTEM_ROOT=""

# Anchor library

# Directory containing anchor_*.mol2 files.
# Example:
# ANCHOR_ROOT="/path/to/anchor/library"

ANCHOR_ROOT=""

# DOCK6.13 installation

# Top-level DOCK6.13 directory containing bin/ and parameters/.
# Example:
# DOCK_ROOT="/path/to/dock6.13"

DOCK_ROOT=""

DOCK_BIN="${DOCK_ROOT}/bin/dock6"
DOCK_PARAMS="${DOCK_ROOT}/parameters"

VDW_DEFN_FILE="${DOCK_PARAMS}/vdw_de_novo.defn"
FLEX_DEFN_FILE="${DOCK_PARAMS}/flex.defn"
FLEX_DRIVE_FILE="${DOCK_PARAMS}/flex_drive.tbl"

# DOCK6.13 De Novo fragment library

# Directory containing:
# fraglib_scaffold.mol2
# fraglib_linker.mol2
# fraglib_sidechain.mol2
# fraglib_torenv.dat
#
# Example:
# DN_LIBRARY_ROOT="/path/to/DOCK6.13_Library"

DN_LIBRARY_ROOT=""

SCAFFOLD_LIBRARY="${DN_LIBRARY_ROOT}/fraglib_scaffold.mol2"
LINKER_LIBRARY="${DN_LIBRARY_ROOT}/fraglib_linker.mol2"
SIDECHAIN_LIBRARY="${DN_LIBRARY_ROOT}/fraglib_sidechain.mol2"
TORENV_TABLE="${DN_LIBRARY_ROOT}/fraglib_torenv.dat"

# Generated workflow files

STATE_DIR="${WORK_ROOT}/state"
RUN_DIR="${WORK_ROOT}/runs"
LOG_DIR="${WORK_ROOT}/logs"
COMBINED_DIR="${WORK_ROOT}/combined"

SYSTEM_LIST="${STATE_DIR}/systems.txt"
ANCHOR_LIST="${STATE_DIR}/anchors.txt"
TASK_LIST="${STATE_DIR}/tasks.tsv"
STATUS_FILE="${STATE_DIR}/status.tsv"
