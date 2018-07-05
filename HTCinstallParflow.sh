#!/bin/bash
# Carolyn Voter
# HTCsetupParflow.sh
# Defines environment variables for parflow install

# Usage: HTCsetupParflow.sh <MPI_INSTALL> <HYPRE_INSTALL> <TCL_INSTALL> <PFSIMULATOR_INSTALL> <PFTOOLS_INSTALL> <PARFLOW_TEST>
# Examples:
#  Install everything: setupParflow.sh 1 1 1 1 1 1
#  Install parflow only: setupParflow.sh 0 0 0 1 1 1
#  Test parflow only: setupParflow.sh 0 0 0 0 0 1
# Requires the following environment variables to be defined in parent script:
# BASE - parent directory for parflow and all required libraries
# MPI_PATH - path to MPI libraries
# MPI_URL, MPI_TAR - required if installing MPI

# Additional Notes:
#  2016.01 - hypre 2.10 is not compatible with parflow, use hypre 2.9b
#  2016.02 - silo 4.19.2 confirmed by developers as compatible.
#  2017.06 - parflow hosted on github (https://github.com/parflow/parflow.git)

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
export HOME=/mnt/gluster/cvoter/ParFlow
export BASE=/mnt/gluster/cvoter/ParFlow
export MPI_PATH=/mnt/gluster/chtc/mpich-3.1
export PATH=$MPI_PATH/bin:$PATH

# ==============================================================================
# CALL INSTALL SCRIPT
# ==============================================================================
sh installParflow.sh $MPI_INSTALL $HYPRE_INSTALL $TCL_INSTALL $PFSIMULATOR_INSTALL $PFTOOLS_INSTALL $PARFLOW_TEST