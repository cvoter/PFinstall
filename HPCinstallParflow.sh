#!/bin/bash
# Carolyn Voter
# HPCsetupParflow.sh
# Defines environment variables for parflow install

# Usage: HPCsetupParflow.sh <MPI_INSTALL> <HYPRE_INSTALL> <TCL_INSTALL> <PFSIMULATOR_INSTALL> <PFTOOLS_INSTALL> <PARFLOW_TEST>
# Examples:
#  Install everything: setupParflow.sh 1 1 1 1 1 1
#  Install parflow only: setupParflow.sh 0 0 0 1 1 1
#  Test parflow only: setupParflow.sh 0 0 0 0 0 1

# ==============================================================================
# SLURM REQUESTS
# ==============================================================================
#SBATCH --partition=loheide3
#SBATCH --time=24:00:00
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --error=/home/cvoter/Jobs/%J.err
#SBATCH --output=/home/cvoter/Jobs/%J.out

# ==============================================================================
# INTERPRET ARGUMENTS
# 1 = Install MPI? 1 = yes, 0 = no
# 2 = Install Hypre? 1 = yes, 0 = no
# 3 = Install TCL? 1 = yes, 0 = no
# 4 = Install pfsimulator? 1 = yes, 0 = no
# 5 = Install pftools? 1 = yes, 0 = no
# 6 = Test Parflow? 1 = yes, 0 = no
# ==============================================================================
MPI_INSTALL=$1
HYPRE_INSTALL=$2
TCL_INSTALL=$3
PFSIMULATOR_INSTALL=$4
PFTOOLS_INSTALL=$5
PARFLOW_TEST=$6

# ==============================================================================
# SET ENVIRONMENT VARIABLES
# ==============================================================================
export BASE=/home/cvoter/ParFlow

module load mpi/gcc/mpich-3.1
export MPI_PATH=/usr/mpi/gcc/mpich-3.1

# ==============================================================================
# CALL INSTALL SCRIPT
# ==============================================================================
sh installParflow.sh $MPI_INSTALL $HYPRE_INSTALL $TCL_INSTALL $PFSIMULATOR_INSTALL $PFTOOLS_INSTALL $PARFLOW_TEST
