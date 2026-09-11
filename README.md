# Multi-System DOCK6.13 De Novo Data Generation

This repository contains a workflow for large-scale DOCK6.13 De Novo molecular generation across multiple receptor systems and anchor fragments.

The workflow automatically discovers receptor systems and anchor fragments, validates the required input files, generates system-specific DOCK6.13 input files, creates a complete calculation task table, distributes the calculations across the HPC cluster, checks calculation completion, and concatenates successful De Novo molecules into a final multi-MOL2 dataset.

The generated molecular dataset is intended for downstream molecular similarity and clustering analyses, including Similarity Island analysis.

## Experimental Design

Each independent De Novo calculation corresponds to one receptor system and one anchor fragment.

For example:

1EQH + anchor_1  
1EQH + anchor_2  
1EQH + anchor_3  
...  
1EQH + anchor_380  

1EVE + anchor_1  
1EVE + anchor_2  
...  
1EVE + anchor_380  

The current dataset contains:

21 receptor systems

380 anchor fragments

Therefore, the complete calculation matrix contains:

21 x 380 = 7,980 independent De Novo calculations

Each calculation uses the same DOCK6.13 De Novo protocol. The parameters that change automatically between calculations are:

dn_fraglib_anchor_file

receptor_site_file

descriptor_grid_score_grid_prefix

The anchor file changes for every anchor calculation, while the receptor spheres and grid prefix change for every receptor system.

## Workflow Scripts

The workflow consists of the following scripts:

000.config.sh

001.discover_inputs.sh

002.setup_DN_runs.sh

003.make_task_list.sh

004.run_one_task.sh

005.run_DN_systems.slurm

006.submit_DN.sh

007.check_DN_results.sh

008.concatenate_results.sh

009.make_executable.sh

README.md

The scripts should normally be executed in numerical order.

The general workflow is:

Input receptor systems and anchors

-> 001.discover_inputs.sh

-> state/systems.txt and state/anchors.txt

-> 002.setup_DN_runs.sh

-> runs/SYSTEM/anchor_N/DN.in

-> 003.make_task_list.sh

-> state/tasks.tsv

-> 006.submit_DN.sh

-> 005.run_DN_systems.slurm

-> 004.run_one_task.sh

-> DN calculations

-> 007.check_DN_results.sh

-> state/status.tsv

-> 008.concatenate_results.sh

-> combined/All_DN_Generated.mol2

-> combined/All_DN_Generated_manifest.tsv

## Working Directory

The workflow is currently configured to run from:

/gpfs/projects/rizzo/iamanor/Collaborations/Pak/001_voxbirch/001_DN_Data

Before running the workflow, move into this directory:

cd /gpfs/projects/rizzo/iamanor/Collaborations/Pak/001_voxbirch/001_DN_Data

## Expected Directory Structure

After the workflow has been initialized, the working directory will have the following general structure:

001_DN_Data/

    000.config.sh

    001.discover_inputs.sh

    002.setup_DN_runs.sh

    003.make_task_list.sh

    004.run_one_task.sh

    005.run_DN_systems.slurm

    006.submit_DN.sh

    007.check_DN_results.sh

    008.concatenate_results.sh

    009.make_executable.sh

    README.md

    state/

        systems.txt

        anchors.txt

        tasks.tsv

        status.tsv

    logs/

        DN_JOBID_1.out

        DN_JOBID_2.out

        ...

    runs/

        1EQH/

            anchor_1/

                DN.in

                DN.out

                DOCK_DN.denovo_build.mol2

            anchor_2/

            ...

            anchor_380/

        1EVE/

            anchor_1/

            anchor_2/

            ...

        ...

    combined/

        All_DN_Generated.mol2

        All_DN_Generated_manifest.tsv

## Central Configuration

All important paths and general workflow settings are stored in:

000.config.sh

This is the main configuration file for the workflow.

Important paths defined there include:

WORK_ROOT

SYSTEM_ROOT

ANCHOR_ROOT

DN_LIBRARY_ROOT

DOCK_ROOT

DOCK_BIN

DOCK_PARAMS

RUN_DIR

LOG_DIR

STATE_DIR

COMBINED_DIR

The SLURM settings are also controlled from this file, including:

PARTITION

TASKS_PER_NODE

MAX_SYSTEM_JOBS

WALLTIME

If the workflow is moved to another directory, DOCK installation, system library, or HPC environment, the paths should be changed in 000.config.sh rather than modifying every individual workflow script.

## Receptor Systems

The receptor systems are automatically discovered from:

/gpfs/projects/rizzo/iamanor/Systems_and_Library_Files/001_Systems_Files/002_DRef_Systems

The current receptor systems are:

1EQH

1EVE

1HWI

1HXB

1M17

1O86

1S19

1T3R

1X70

1XMU

2GQG

2P16

2Y04

3IK3

4P6W

4WMZ

4XE0

5ZV2

6HLO

6ME2

7CMU

Each receptor system has its own directory.

For example:

/gpfs/projects/rizzo/iamanor/Systems_and_Library_Files/001_Systems_Files/002_DRef_Systems/1EQH

The workflow requires the following files for each system:

SYSTEM.lig.am1bcc.mol2

SYSTEM.rec.clust.close.sph

SYSTEM.rec.bmp

SYSTEM.rec.nrg

For example, 1EQH requires:

1EQH.lig.am1bcc.mol2

1EQH.rec.clust.close.sph

1EQH.rec.bmp

1EQH.rec.nrg

The receptor sphere file used by the 1EQH calculation is:

/gpfs/projects/rizzo/iamanor/Systems_and_Library_Files/001_Systems_Files/002_DRef_Systems/1EQH/1EQH.rec.clust.close.sph

The grid prefix is:

/gpfs/projects/rizzo/iamanor/Systems_and_Library_Files/001_Systems_Files/002_DRef_Systems/1EQH/1EQH.rec

The grid prefix corresponds to:

1EQH.rec.bmp

1EQH.rec.nrg

The same naming convention is used automatically for every receptor system.

## Anchor Fragment Library

The anchor fragments are stored in:

/gpfs/projects/rizzo/iamanor/DOCK6_Development/Dynamics_Referencing/for_isaac/Dynamic_Reference_for_Isaac/anchors

The current anchor library contains 380 MOL2 files:

anchor_1.mol2

anchor_2.mol2

anchor_3.mol2

...

anchor_100.mol2

...

anchor_380.mol2

The workflow automatically discovers all files matching:

anchor_*.mol2

The anchors are sorted numerically using version sorting.

This is important because normal alphabetical sorting could produce an ordering such as:

anchor_1.mol2

anchor_10.mol2

anchor_100.mol2

anchor_101.mol2

...

anchor_2.mol2

The workflow instead maintains the intended numerical order:

anchor_1.mol2

anchor_2.mol2

anchor_3.mol2

...

anchor_379.mol2

anchor_380.mol2

The number of anchors is therefore discovered automatically and does not need to be hard-coded into the workflow.

## DOCK6.13 De Novo Libraries

The generic DOCK6.13 De Novo fragment libraries are stored in:

/gpfs/projects/rizzo/iamanor/Systems_and_Library_Files/003_Libraries/DOCK_DN_Generic_Library/DOCK6.13_Library

The workflow uses:

fraglib_scaffold.mol2

fraglib_linker.mol2

fraglib_sidechain.mol2

fraglib_torenv.dat

These files are common to every calculation.

The user-specified anchor is the component that changes between anchor calculations.

## DOCK6.13 Parameters

The workflow currently uses the DOCK6.13 installation under:

/gpfs/projects/AMS536/zzz.programs/dock6.13

The DOCK executable is expected at:

/gpfs/projects/AMS536/zzz.programs/dock6.13/bin/dock6

The workflow also uses the DOCK6.13 parameter files:

vdw_de_novo.defn

flex.defn

flex_drive.tbl

The exact paths are defined centrally in:

000.config.sh

## Initial Setup

After cloning or copying the workflow, first move into the working directory:

cd /gpfs/projects/rizzo/iamanor/Collaborations/Pak/001_voxbirch/001_DN_Data

Check that the workflow scripts are present:

ls -lh

The directory should contain:

000.config.sh

001.discover_inputs.sh

002.setup_DN_runs.sh

003.make_task_list.sh

004.run_one_task.sh

005.run_DN_systems.slurm

006.submit_DN.sh

007.check_DN_results.sh

008.concatenate_results.sh

009.make_executable.sh

README.md

## Step 1: Make the Scripts Executable

Run:

bash 009.make_executable.sh

This gives the workflow scripts executable permissions and makes the relevant files group writable.

Afterward, the scripts can be executed directly using commands such as:

./001.discover_inputs.sh

## Step 2: Discover and Validate Inputs

Run:

./001.discover_inputs.sh

This should always be the first scientific workflow step.

The script automatically discovers all receptor system directories under SYSTEM_ROOT and all anchor MOL2 files under ANCHOR_ROOT.

It creates:

state/systems.txt

and:

state/anchors.txt

For the current dataset, the expected output should report approximately:

Systems found: 21

Anchors found: 380

Expected DN calculations: 7980

The script also checks the required files before any calculations are prepared.

For each receptor system, it verifies:

SYSTEM.rec.clust.close.sph

SYSTEM.rec.bmp

SYSTEM.rec.nrg

SYSTEM.lig.am1bcc.mol2

It also checks the common DOCK6.13 fragment libraries, parameter files, and DOCK executable.

If required files are missing, the script stops and reports the missing files.

Do not continue to the setup stage until this validation passes.

After successful discovery, inspect the system list:

cat state/systems.txt

Check the number of systems:

wc -l state/systems.txt

Inspect the anchor list:

head state/anchors.txt

tail state/anchors.txt

Check the number of anchors:

wc -l state/anchors.txt

The expected counts for the current experiment are:

21 systems

380 anchors

## Step 3: Generate All DOCK6.13 Input Files

Once the preflight validation passes, run:

./002.setup_DN_runs.sh

This creates the calculation directory structure under:

runs/

For every receptor system, the script creates one directory for every anchor.

For example:

runs/1EQH/anchor_1/

runs/1EQH/anchor_2/

runs/1EQH/anchor_3/

...

runs/1EQH/anchor_380/

and:

runs/1EVE/anchor_1/

runs/1EVE/anchor_2/

...

Each calculation directory receives its own:

DN.in

For example:

runs/1EQH/anchor_147/DN.in

The script automatically inserts the appropriate anchor:

dn_fraglib_anchor_file /gpfs/projects/rizzo/iamanor/DOCK6_Development/Dynamics_Referencing/for_isaac/Dynamic_Reference_for_Isaac/anchors/anchor_147.mol2

It also inserts the appropriate receptor spheres:

receptor_site_file /gpfs/projects/rizzo/iamanor/Systems_and_Library_Files/001_Systems_Files/002_DRef_Systems/1EQH/1EQH.rec.clust.close.sph

and grid prefix:

descriptor_grid_score_grid_prefix /gpfs/projects/rizzo/iamanor/Systems_and_Library_Files/001_Systems_Files/002_DRef_Systems/1EQH/1EQH.rec

The rest of the DOCK6.13 De Novo protocol remains consistent across calculations.

After input generation, inspect one or more files before submitting the entire dataset.

For example:

cat runs/1EQH/anchor_1/DN.in

and:

cat runs/1EQH/anchor_380/DN.in

It is also useful to inspect another receptor system:

cat runs/7CMU/anchor_1/DN.in

Confirm that:

1. The anchor path changes correctly.

2. The receptor sphere path contains the correct receptor system.

3. The grid prefix contains the correct receptor system.

4. The generic fragment library paths remain unchanged.

## Step 4: Create the Calculation Task Table

After generating the input files, run:

./003.make_task_list.sh

This creates:

state/tasks.tsv

The task table records every independent calculation.

The columns are:

task_id

system

anchor

anchor_file

calculation_directory

Inspect the beginning of the task table:

head state/tasks.tsv

Inspect the end:

tail state/tasks.tsv

Count the number of calculations:

awk 'END {print NR-1}' state/tasks.tsv

For the current 21-system and 380-anchor experiment, the expected number is:

7980

Each task represents exactly one:

SYSTEM + ANCHOR

combination.

For example:

Task 1 may correspond to:

1EQH + anchor_1

Task 2:

1EQH + anchor_2

and so forth.

The task table provides a reproducible mapping between calculations and their corresponding directories.

## Step 5: Optional Single-Task Test

Before submitting all 7,980 calculations, it is strongly recommended to test one calculation manually.

For example:

./004.run_one_task.sh 1

Task 1 should correspond to the first entry in:

state/tasks.tsv

Check it with:

sed -n '1,2p' state/tasks.tsv

After the test completes, inspect the calculation directory.

For example:

ls -lh runs/1EQH/anchor_1/

A successful calculation should produce:

DN.in

DN.out

DOCK_DN.denovo_build.mol2

The worker also creates:

.success

for a successfully completed calculation.

Check the generated MOL2 file:

grep -c '^@<TRIPOS>MOLECULE' runs/1EQH/anchor_1/DOCK_DN.denovo_build.mol2

This reports the number of generated molecules.

Also inspect the DOCK output:

tail -n 50 runs/1EQH/anchor_1/DN.out

Only proceed to the full submission after confirming that a representative single calculation runs correctly.

## Step 6: Submit the Full De Novo Dataset

Once the single-task test succeeds, submit the full workflow using:

./006.submit_DN.sh

Do not submit 005.run_DN_systems.slurm manually under normal operation.

006.submit_DN.sh determines the number of receptor systems and constructs the appropriate SLURM array automatically.

The workflow parallelizes calculations at two levels.

The first level is the receptor system.

Each SLURM array element corresponds to one receptor system.

For example:

Array task 1 -> 1EQH

Array task 2 -> 1EVE

Array task 3 -> 1HWI

and so forth.

The second level is the anchor calculations within each system.

Each receptor-system job receives one 28-core node.

Individual serial DOCK6.13 calculations are distributed across those cores.

For a system such as 1EQH:

anchor_1 may run on one core

anchor_2 may run on another core

anchor_3 may run on another core

...

up to 28 independent anchor calculations can run concurrently on the node.

As calculations finish, additional anchor calculations are launched until all anchors for that receptor system have been processed.

This workflow does not use MPI for the individual DOCK calculations.

Each DOCK calculation is an independent serial process.

## SLURM Configuration

The current configuration uses:

Partition:

long-28core

Tasks per node:

28

Walltime:

48 hours

The number of receptor systems allowed to run simultaneously is controlled by:

MAX_SYSTEM_JOBS

in:

000.config.sh

For example:

MAX_SYSTEM_JOBS=4

means that at most four receptor-system jobs will run simultaneously.

Since each system job uses one 28-core node, this corresponds to a maximum of approximately:

4 x 28 = 112 concurrent independent DOCK calculations

when all four nodes are fully occupied.

This setting can be changed depending on available HPC resources and scheduling policy.

## Step 7: Monitor the SLURM Jobs

After submission, monitor the jobs using:

squeue -u $USER

For continuous monitoring:

watch -n 30 "squeue -u $USER"

Press:

Ctrl+C

to exit `watch`.

The SLURM logs are written to:

logs/

The naming pattern is:

DN_JOBID_ARRAYID.out

For example:

DN_1234567_1.out

DN_1234567_2.out

DN_1234567_3.out

Each log corresponds to one receptor-system array job.

To inspect a running log:

tail -f logs/DN_JOBID_ARRAYID.out

Replace the filename with the actual log file.

To inspect all recent logs:

ls -lht logs/ | head

## Restart and Resubmission Behavior

The workflow is designed to be restartable.

Before running a task, 004.run_one_task.sh checks whether:

DOCK_DN.denovo_build.mol2

already exists, is nonempty, and contains at least one:

@<TRIPOS>MOLECULE

record.

If a valid output already exists, the task is considered complete and DOCK is not rerun.

Therefore, the workflow can safely be resubmitted after:

walltime termination

node failure

individual DOCK failures

scheduler interruption

partial completion

or manual cancellation.

Completed calculations will be skipped.

Incomplete calculations will be attempted again.

This prevents unnecessary repetition of successfully completed De Novo calculations.

## Step 8: Check Calculation Completion

After the jobs have finished, run:

./007.check_DN_results.sh

This examines every calculation listed in:

state/tasks.tsv

and creates:

state/status.tsv

Each task is classified as:

SUCCESS

FAILED

or:

MISSING

SUCCESS means that a nonempty:

DOCK_DN.denovo_build.mol2

exists and contains at least one MOL2 molecule record.

FAILED indicates that the calculation appears to have run but did not produce a valid final molecular output.

MISSING indicates that the calculation has not produced an output and does not appear to have completed.

The status script reports:

Total tasks

Successful tasks

Failed tasks

Missing/not-run tasks

Total generated molecules

It also produces a per-system summary.

The full status table can be inspected using:

less state/status.tsv

To count successful calculations:

awk -F '\t' '$4=="SUCCESS" {n++} END {print n+0}' state/status.tsv

To count failed calculations:

awk -F '\t' '$4=="FAILED" {n++} END {print n+0}' state/status.tsv

To count missing calculations:

awk -F '\t' '$4=="MISSING" {n++} END {print n+0}' state/status.tsv

To inspect only failed calculations:

awk -F '\t' '$4=="FAILED"' state/status.tsv

To inspect only missing calculations:

awk -F '\t' '$4=="MISSING"' state/status.tsv

## Step 9: Resubmit Incomplete Calculations

If some calculations failed or were interrupted, the full submission command can be run again:

./006.submit_DN.sh

The worker automatically skips calculations that already have valid output MOL2 files.

Therefore, completed calculations will not be repeated.

After the resubmitted jobs finish, rerun:

./007.check_DN_results.sh

Continue until the desired level of completion has been reached.

## Step 10: Concatenate Successful De Novo Molecules

After validating the calculations, run:

./008.concatenate_results.sh

This collects all valid:

DOCK_DN.denovo_build.mol2

files and concatenates them into:

combined/All_DN_Generated.mol2

Only valid MOL2 outputs containing:

@<TRIPOS>MOLECULE

records are included.

The script also creates:

combined/All_DN_Generated_manifest.tsv

## Combined MOL2 Dataset

The final combined molecular dataset is:

combined/All_DN_Generated.mol2

This is a multi-MOL2 file containing molecules generated across the successful system-anchor calculations.

The total number of molecules can be checked using:

grep -c '^@<TRIPOS>MOLECULE' combined/All_DN_Generated.mol2

If the `countmol` utility is available, the dataset can also be checked using:

countmol combined/All_DN_Generated.mol2

## Provenance Manifest

The workflow creates:

combined/All_DN_Generated_manifest.tsv

This file records the provenance of every block of molecules added to the combined MOL2 dataset.

The columns are:

system

anchor

molecules

first_index

last_index

source_file

For example, a row may indicate that molecules 1 through 30 originated from:

1EQH + anchor_1

and molecules 31 through 58 originated from:

1EQH + anchor_2

This allows molecules in the combined dataset to be traced back to the receptor system and anchor calculation that generated them.

Inspect the manifest using:

less combined/All_DN_Generated_manifest.tsv

## Recommended Complete Run Sequence

For a completely new experiment, run the workflow in the following order:

cd /gpfs/projects/rizzo/iamanor/Collaborations/Pak/001_voxbirch/001_DN_Data

bash 009.make_executable.sh

./001.discover_inputs.sh

cat state/systems.txt

wc -l state/systems.txt

head state/anchors.txt

tail state/anchors.txt

wc -l state/anchors.txt

./002.setup_DN_runs.sh

cat runs/1EQH/anchor_1/DN.in

./003.make_task_list.sh

head state/tasks.tsv

tail state/tasks.tsv

awk 'END {print NR-1}' state/tasks.tsv

./004.run_one_task.sh 1

ls -lh runs/1EQH/anchor_1/

tail -n 50 runs/1EQH/anchor_1/DN.out

grep -c '^@<TRIPOS>MOLECULE' runs/1EQH/anchor_1/DOCK_DN.denovo_build.mol2

./006.submit_DN.sh

squeue -u $USER

watch -n 30 "squeue -u $USER"

After the calculations finish:

./007.check_DN_results.sh

less state/status.tsv

If incomplete calculations remain:

./006.submit_DN.sh

After the desired calculations have completed:

./007.check_DN_results.sh

./008.concatenate_results.sh

Finally verify the combined molecular dataset:

grep -c '^@<TRIPOS>MOLECULE' combined/All_DN_Generated.mol2

and inspect the provenance manifest:

less combined/All_DN_Generated_manifest.tsv

## Quick Run Sequence

For experienced users who have already validated the configuration, the essential workflow is:

./001.discover_inputs.sh

./002.setup_DN_runs.sh

./003.make_task_list.sh

./004.run_one_task.sh 1

./006.submit_DN.sh

./007.check_DN_results.sh

./008.concatenate_results.sh

## Important Files

Configuration:

000.config.sh

System list:

state/systems.txt

Anchor list:

state/anchors.txt

Calculation task table:

state/tasks.tsv

Calculation status table:

state/status.tsv

Individual calculations:

runs/SYSTEM/anchor_N/

SLURM logs:

logs/

Combined molecular dataset:

combined/All_DN_Generated.mol2

Dataset provenance:

combined/All_DN_Generated_manifest.tsv

## Modifying the System Set

The receptor systems are initially discovered automatically by:

001.discover_inputs.sh

and written to:

state/systems.txt

If only a subset of systems should be used for an experiment, the system list can be edited after discovery and before running:

002.setup_DN_runs.sh

For example, a small test could use:

1EQH

1EVE

1O86

After changing the system list, the subsequent setup and task-generation scripts will use only those systems.

Running 001.discover_inputs.sh again will regenerate the complete discovered system list.

## Modifying the Anchor Set

The anchors are initially discovered automatically and written to:

state/anchors.txt

For a smaller experiment, this file can be edited after discovery.

For example:

anchor_1.mol2

anchor_2.mol2

anchor_3.mol2

anchor_4.mol2

anchor_5.mol2

The subsequent setup and task-generation scripts will then use only those anchors.

Running 001.discover_inputs.sh again will regenerate the complete anchor list from the anchor directory.

## Testing a Small Subset

Before a large production calculation, it may be useful to test only a small number of systems and anchors.

First run:

./001.discover_inputs.sh

Then temporarily modify:

state/systems.txt

and:

state/anchors.txt

For example, use one system:

1EQH

and three anchors:

anchor_1.mol2

anchor_2.mol2

anchor_3.mol2

Then run:

./002.setup_DN_runs.sh

./003.make_task_list.sh

./004.run_one_task.sh 1

This provides a small-scale validation of the entire setup before launching the complete dataset.

## Output Validation

A successful calculation should normally contain:

DN.in

DN.out

DOCK_DN.denovo_build.mol2

.success

A failed calculation may contain:

DN.in

DN.out

.failed

but no valid:

DOCK_DN.denovo_build.mol2

The status checker determines success primarily from the molecular output rather than simply assuming that the existence of DN.out means that the calculation succeeded.

## Data Management

The `runs/` directory may become large because it can contain thousands of calculation directories.

The generated calculation data should therefore not normally be committed to GitHub.

The files most appropriate for version control are the workflow scripts and documentation:

000.config.sh

001.discover_inputs.sh

002.setup_DN_runs.sh

003.make_task_list.sh

004.run_one_task.sh

005.run_DN_systems.slurm

006.submit_DN.sh

007.check_DN_results.sh

008.concatenate_results.sh

009.make_executable.sh

README.md

Large generated files such as:

runs/

logs/

combined/

should generally remain on the HPC filesystem rather than being stored directly in the Git repository.

The `state/` files may be retained when useful for documenting a particular experiment, but they can also be regenerated from the source system and anchor directories.

## Scientific Reproducibility

The workflow separates configuration from execution.

All important paths are maintained in:

000.config.sh

The receptor list is recorded in:

state/systems.txt

The anchor list is recorded in:

state/anchors.txt

Every calculation is recorded in:

state/tasks.tsv

Calculation outcomes are recorded in:

state/status.tsv

The combined dataset is accompanied by:

combined/All_DN_Generated_manifest.tsv

This structure makes it possible to determine:

which receptor systems were used

which anchors were used

how many calculations were expected

which calculations succeeded

which calculations failed

how many molecules were generated

which system and anchor produced each section of the final dataset

and where the original calculation output is stored.

## Downstream Analysis

The final output:

combined/All_DN_Generated.mol2

is intended to serve as an input molecular dataset for subsequent analyses.

Potential downstream applications include:

Similarity Island clustering

Hungarian Matching Similarity analysis

Fingerprint similarity

Tanimoto similarity

Volume-overlap similarity

Molecular diversity analysis

Energy-based ranking

System-specific clustering

Anchor-specific clustering

Cross-system comparison of generated molecular space

## Summary

The workflow performs the following major operations:

1. Discover receptor systems and anchors.

2. Validate all required system, library, parameter, and executable files.

3. Generate a DOCK6.13 De Novo input for every system-anchor pair.

4. Build a reproducible task table.

5. Test individual calculations when desired.

6. Submit system-level SLURM array jobs.

7. Run multiple independent anchor calculations concurrently on each node.

8. Automatically skip calculations that have already completed.

9. Detect successful, failed, and missing calculations.

10. Safely restart incomplete calculations.

11. Concatenate valid generated molecules.

12. Record the provenance of the final multi-MOL2 dataset.

For the current experiment:

21 receptor systems x 380 anchors = 7,980 independent DOCK6.13 De Novo calculations.

The resulting combined molecular library can then be used for downstream molecular similarity and clustering studies.
