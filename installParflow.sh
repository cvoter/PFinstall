#!/bin/bash
# Carolyn Voter
# installParflow.sh
# setup and test parflow and associated libraries

# Usage: sh installParflow.sh <HYPRE_INSTALL> <TCL_INSTALL> <PARFLOW_INSTALL> <PARFLOW_TEST>
# Examples:
#  Install everything: sh installParflow.sh 1 1 1 1
#  Install parflow only: sh installParflow.sh 0 0 1 1
#  Test parflow only: sh installParflow.sh 0 0 0 1
# Requires the following environment variables to be defined in parent script:
# BASE - parent directory for parflow and all required libraries
# MPI_PATH - path to MPI libraries

# Additional Notes:
#  2016.01 - hypre 2.10 is not compatible with parflow, use hypre 2.9b
#  2016.02 - silo 4.19.2 confirmed by developers as compatible.
#  2017.06 - parflow hosted on github (https://github.com/parflow/parflow.git)
#  2021.08 - parflow now built with CMAKE, no separate pfsimulator and pftools, 
#            use git for tcl (branch: core-8-6-branch) and hypre (tags: v2.18.2) (checkout prior to install), 
#            rely on system modules for mpi

# ==============================================================================
# INTERPRET ARGUMENTS
# 1 = Install Hypre? 1 = yes, 0 = no
# 2 = Install TCL? 1 = yes, 0 = no
# 3 = Install Parflow? 1 = yes, 0 = no
# 4 = Test Parflow? 1 = yes, 0 = no
# ==============================================================================
HYPRE_INSTALL=$1
TCL_INSTALL=$2
PARFLOW_INSTALL=$3
PARFLOW_TEST=$4

# ==============================================================================
# SET ENVIRONMENT VARIABLES
# ==============================================================================
export CC=gcc
export CXX=g++
export FC=gfortran
export F77=gfortran

export PARFLOW_DIR=$BASE/parflow
export HYPRE_PATH=$BASE/hypre
export TCL_PATH=$BASE/tcl

if [[ ! -d $BASE/installation_logs ]]; then
  mkdir $BASE/installation_logs
fi

# ==============================================================================
# INSTALL DEPENDENCIES
# ==============================================================================
# ------------------------------------------------------------------------------
# MPI
# ------------------------------------------------------------------------------
export LD_LIBRARY_PATH=$MPI_PATH/lib:$LD_LIBRARY_PATH

# ------------------------------------------------------------------------------
# HYPRE
# ------------------------------------------------------------------------------
if [[ $HYPRE_INSTALL -eq 1 ]]; then
    cd $HYPRE_PATH/src
    ./configure --prefix=$HYPRE_PATH --with-MPI \
    --with-MPI-include=$MPI_PATH/include --with-MPI-libs=mpi \
    --with-MPI-lib-dirs=$MPI_PATH/lib > $BASE/installation_logs/hypre.out 2>&1 || exit 1
    make >> $BASE/installation_logs/hypre.out 2>&1 || exit 1
    make install >> $BASE/installation_logs/hypre.out 2>&1 || exit 1
fi

# ------------------------------------------------------------------------------
# TCL
# ------------------------------------------------------------------------------
if [[ $TCL_INSTALL -eq 1 ]]; then
    $TCL_PATH/unix
    ./configure --prefix=$TCL_PATH --enable-shared > $BASE/installation_logs/tcl.out 2>&1 || exit 1
    make >> $BASE/installation_logs/tcl.out 2>&1 || exit 1
    make install >> $BASE/installation_logs/tcl.out 2>&1 || exit 1
    rm -rf $TCL_UNTAR
fi
export LD_LIBRARY_PATH=$TCL_PATH/lib:$LD_LIBRARY_PATH

# ==============================================================================
# INSTALL PARFLOW
# ==============================================================================
if [[ $PARFLOW_INSTALL -eq 1 ]]; then
  cd $BASE
  mkdir build
  cd build
  ccmake ../parflow \
    -DPARFLOW_AMPS_LAYER=mpi1 \
    -DPARFLOW_AMPS_SEQUENTIAL_IO=TRUE \
    -DPARFLOW_ENABLE_TIMING=TRUE \
    -DPARFLOW_HAVE_CLM=ON \
    -DTCL_TCLSH=${TCL_PATH}/bin/tclsh8.6 \
    -DHYPRE_ROOT=${HYPRE_PATH} \
    -DCMAKE_INSTALL_PREFIX=${PARFLOW_DIR}
  make >> $BASE/installation_logs/parflow.out 2>&1 || exit 1
  make install >> $BASE/installation_logs/parflow.out 2>&1 || exit 1
fi

# ==============================================================================
# TEST PARFLOW
# ==============================================================================
if [[ $PARFLOW_TEST -eq 1 ]]; then
    cd $PARFLOW_DIR/test
    make veryclean
    make check > $BASE/installation_logs/pfcheck.out 2>&1
fi
	
# ==============================================================================
# EXIT
# ==============================================================================
exit 0
