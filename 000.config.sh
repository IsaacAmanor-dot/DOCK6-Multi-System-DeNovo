#!/bin/bash

# Central configuration for the multi-system DOCK6.13 De Novo workflow.
# Configure the required paths before running the workflow.

CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Working directory
# Generated workflow files are written relative to this repository.
WORK_ROOT="${CONFIG_DIR}"

# Receptor systems
# Directory containing the receptor-system directories.
# Example: SYSTEM_ROOT="/path/to/receptor/systems"
SYSTEM_ROOT=""

# Anchor fragments
# Directory containing anchor_*.mol2 files.
# Example: ANCHOR_ROOT="/path/to/anchor/library"
ANCHOR_ROOT=""

# DOCK6.13 executable
# Example: DOCK_BIN="/path/to/dock6.13/bin/dock6"
DOCK_BIN=""

# DOCK6.13 De Novo fragment libraries
# Provide the full path to each required library.

# Example: SCAFFOLD_LIBRARY="/path/to/fraglib_scaffold.mol2"
SCAFFOLD_LIBRARY=""

# Example: LINKER_LIBRARY="/path/to/fraglib_linker.mol2"
LINKER_LIBRARY=""

# Example: SIDECHAIN_LIBRARY="/path/to/fraglib_sidechain.mol2"
SIDECHAIN_LIBRARY=""

# Example: TORENV_TABLE="/path/to/fraglib_torenv.dat"
TORENV_TABLE=""

# DOCK6.13 parameter files
# Provide the full path to each required parameter file.

# Example: VDW_DEFN_FILE="/path/to/vdw_de_novo.defn"
VDW_DEFN_FILE=""

# Example: FLEX_DEFN_FILE="/path/to/flex.defn"
FLEX_DEFN_FILE=""

# Example: FLEX_DRIVE_FILE="/path/to/flex_drive.tbl"
FLEX_DRIVE_FILE=""

# Generated workflow files
STATE_DIR="${WORK_ROOT}/state"
RUN_DIR="${WORK_ROOT}/runs"
LOG_DIR="${WORK_ROOT}/logs"
COMBINED_DIR="${WORK_ROOT}/combined"

SYSTEM_LIST="${STATE_DIR}/systems.txt"
ANCHOR_LIST="${STATE_DIR}/anchors.txt"
TASK_LIST="${STATE_DIR}/tasks.tsv"
STATUS_FILE="${STATE_DIR}/status.tsv"

# SLURM settings

# SLURM partition.
# Leave blank if an explicit partition is not required.
# Example: PARTITION="your_partition"
PARTITION=""

# Number of independent serial DOCK calculations per system job.
TASKS_PER_NODE=28

# Maximum number of receptor-system jobs running simultaneously.
MAX_SYSTEM_JOBS=4

# Requested walltime.
WALLTIME="48:00:00"
