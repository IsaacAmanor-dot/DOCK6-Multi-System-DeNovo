#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/000.config.sh"

if [[ ! -s "${SYSTEM_LIST}" ]]; then
    echo "Missing ${SYSTEM_LIST}"
    echo "Run ./001.discover_inputs.sh first."
    exit 1
fi

if [[ ! -s "${ANCHOR_LIST}" ]]; then
    echo "Missing ${ANCHOR_LIST}"
    echo "Run ./001.discover_inputs.sh first."
    exit 1
fi

mkdir -p "${RUN_DIR}"

N_SYSTEMS=$(wc -l < "${SYSTEM_LIST}")
N_ANCHORS=$(wc -l < "${ANCHOR_LIST}")

echo "Preparing ${N_SYSTEMS} systems and ${N_ANCHORS} anchors."
echo "Total DN inputs: $((N_SYSTEMS * N_ANCHORS))"
echo

while read -r SYSTEM; do

    echo "Setting up ${SYSTEM}"

    SYSTEM_SOURCE="${SYSTEM_ROOT}/${SYSTEM}"
    SPHERE_FILE="${SYSTEM_SOURCE}/${SYSTEM}.rec.clust.close.sph"
    GRID_PREFIX="${SYSTEM_SOURCE}/${SYSTEM}.rec"

    SYSTEM_RUN_DIR="${RUN_DIR}/${SYSTEM}"
    mkdir -p "${SYSTEM_RUN_DIR}"

    while read -r ANCHOR_FILE; do

        ANCHOR_NAME="${ANCHOR_FILE%.mol2}"
        ANCHOR_PATH="${ANCHOR_ROOT}/${ANCHOR_FILE}"

        CALC_DIR="${SYSTEM_RUN_DIR}/${ANCHOR_NAME}"
        mkdir -p "${CALC_DIR}"

        cat > "${CALC_DIR}/DN.in" << EOF_INPUT
conformer_search_type                                      denovo

dn_fraglib_scaffold_file                                  ${SCAFFOLD_LIBRARY}

dn_fraglib_linker_file                                    ${LINKER_LIBRARY}

dn_fraglib_sidechain_file                                 ${SIDECHAIN_LIBRARY}

dn_user_specified_anchor                                  yes

dn_fraglib_anchor_file                                    ${ANCHOR_PATH}

dn_torenv_table                                           ${TORENV_TABLE}

dn_bias_torsions                                          no

dn_name_identifier                                        denovo

dn_sampling_method                                        graph

dn_graph_max_picks                                        30

dn_graph_breadth                                          3

dn_graph_depth                                            2

dn_graph_temperature                                      100.0

dn_bias_with_fragments                                    no

dn_pruning_conformer_score_cutoff                         100.0

dn_pruning_conformer_score_scaling_factor                 2.0

dn_pruning_clustering_cutoff                              100.0

dn_remove_duplicates                                      yes

dn_max_duplicates_per_mol                                 0

dn_write_pruned_duplicates                                no

dn_advanced_pruning                                       yes

dn_prune_initial_sample                                   yes

dn_sample_torsions                                        yes

dn_prune_individual_torsions                              yes

dn_prune_combined_torsions                                yes

dn_random_root_selection                                  no

dn_mol_wt_cutoff_type                                     soft

dn_upper_constraint_mol_wt                                1000

dn_lower_constraint_mol_wt                                0.0

dn_mol_wt_std_dev                                         35.0

dn_constraint_rot_bon                                     15

dn_constraint_formal_charge                               2.0

dn_heur_unmatched_num                                     1

dn_heur_matched_rmsd                                      2.0

dn_unique_anchors                                         1

dn_max_grow_layers                                        9

dn_max_root_size                                          25

dn_max_layer_size                                         25

dn_max_current_aps                                        5

dn_max_scaffolds_per_layer                                1

dn_max_successful_att_per_root                            50000

dn_write_checkpoints                                      no

dn_write_prune_dump                                       no

dn_write_orients                                          no

dn_write_growth_trees                                     no

dn_output_prefix                                          DOCK_DN

use_internal_energy                                       yes

internal_energy_rep_exp                                   12

internal_energy_cutoff                                    100.0

use_database_filter                                       no

orient_ligand                                             yes

automated_matching                                        yes

receptor_site_file                                        ${SPHERE_FILE}

max_orientations                                          1000

critical_points                                           no

chemical_matching                                         no

use_ligand_spheres                                        no

bump_filter                                               no

score_molecules                                           yes

contact_score_primary                                     no

grid_score_primary                                        no

gist_score_primary                                        no

multigrid_score_primary                                   no

dock3.5_score_primary                                     no

continuous_score_primary                                  no

footprint_similarity_score_primary                        no

pharmacophore_score_primary                               no

hbond_score_primary                                       no

internal_energy_score_primary                             no

descriptor_score_primary                                  yes

descriptor_use_grid_score                                 yes

descriptor_use_grid_lig_efficiency                        no

descriptor_use_pharmacophore_score                        no

descriptor_use_tanimoto                                   no

descriptor_use_hungarian                                  no

descriptor_use_volume_overlap                             no

descriptor_use_gist                                       no

descriptor_use_dock3.5                                    no

descriptor_grid_score_rep_rad_scale                       1

descriptor_grid_score_vdw_scale                           1

descriptor_grid_score_es_scale                            1

descriptor_grid_score_grid_prefix                         ${GRID_PREFIX}

descriptor_weight_grid_score                              1

minimize_ligand                                           yes

minimize_anchor                                           yes

minimize_flexible_growth                                  yes

use_advanced_simplex_parameters                           no

simplex_max_cycles                                        1

simplex_score_converge                                    0.1

simplex_cycle_converge                                    1.0

simplex_trans_step                                        1.0

simplex_rot_step                                          0.1

simplex_tors_step                                         10.0

simplex_anchor_max_iterations                             500

simplex_grow_max_iterations                               500

simplex_grow_tors_premin_iterations                       0

simplex_final_min                                         no

simplex_random_seed                                       0

simplex_restraint_min                                     no

atom_model                                                all

vdw_defn_file                                             ${VDW_DEFN_FILE}

flex_defn_file                                            ${FLEX_DEFN_FILE}

flex_drive_file                                           ${FLEX_DRIVE_FILE}
EOF_INPUT

    done < "${ANCHOR_LIST}"

done < "${SYSTEM_LIST}"

echo
echo "DN input generation complete."

