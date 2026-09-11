#!/bin/bash

# Central configuration for the multi-system DOCK6.13 De Novo workflow.

WORK_ROOT="/gpfs/projects/rizzo/iamanor/Collaborations/Pak/001_voxbirch/001_DN_Data"

SYSTEM_ROOT="/gpfs/projects/rizzo/iamanor/Systems_and_Library_Files/001_Systems_Files/002_DRef_Systems"

ANCHOR_ROOT="/gpfs/projects/rizzo/iamanor/DOCK6_Development/Dynamics_Referencing/for_isaac/Dynamic_Reference_for_Isaac/anchors"

DN_LIBRARY_ROOT="/gpfs/projects/rizzo/iamanor/Systems_and_Library_Files/003_Libraries/DOCK_DN_Generic_Library/DOCK6.13_Library"

DOCK_ROOT="/gpfs/projects/AMS536/zzz.programs/dock6.13"
DOCK_BIN="${DOCK_ROOT}/bin/dock6"
DOCK_PARAMS="${DOCK_ROOT}/parameters"

SCAFFOLD_LIBRARY="${DN_LIBRARY_ROOT}/fraglib_scaffold.mol2"
LINKER_LIBRARY="${DN_LIBRARY_ROOT}/fraglib_linker.mol2"
SIDECHAIN_LIBRARY="${DN_LIBRARY_ROOT}/fraglib_sidechain.mol2"
TORENV_TABLE="${DN_LIBRARY_ROOT}/fraglib_torenv.dat"

VDW_DEFN_FILE="${DOCK_PARAMS}/vdw_de_novo.defn"
FLEX_DEFN_FILE="${DOCK_PARAMS}/flex.defn"
FLEX_DRIVE_FILE="${DOCK_PARAMS}/flex_drive.tbl"

STATE_DIR="${WORK_ROOT}/state"
RUN_DIR="${WORK_ROOT}/runs"
LOG_DIR="${WORK_ROOT}/logs"
COMBINED_DIR="${WORK_ROOT}/combined"

SYSTEM_LIST="${STATE_DIR}/systems.txt"
ANCHOR_LIST="${STATE_DIR}/anchors.txt"
TASK_LIST="${STATE_DIR}/tasks.tsv"
STATUS_FILE="${STATE_DIR}/status.tsv"

# One system occupies one 28-core node.
# Up to this many systems can run simultaneously.
PARTITION="long-28core"
TASKS_PER_NODE=28
MAX_SYSTEM_JOBS=4
WALLTIME="48:00:00"

