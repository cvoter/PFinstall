#!/bin/bash
# Carolyn Voter
# setupParflow.sh
# setup and test parflow and associated libraries

# Usage: setupParflow.sh <MPI_INSTALL> <HYPRE_INSTALL> <TCL_INSTALL> <PFSIMULATOR_INSTALL> <PFTOOLS_INSTALL> <PARFLOW_TEST>
# Examples:
#  Install everything: setupParflow.sh 1 1 1 1 1 1
#  Install parflow only: setupParflow.sh 0 0 0 1 1 1
#  Test parflow only: setupParflow.sh 0 0 0 0 0 1

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
export CC=gcc
export CXX=g++
export FC=gfortran
export F77=gfortran

export HOME=/mnt/gluster/cvoter/ParFlow
export BASE=/mnt/gluster/cvoter/ParFlow
export PARFLOW_DIR=$BASE/parflow

export HYPRE_PATH=$BASE/hypre-2.9.0b
export HYPRE_TAR='hypre-2.9.0b.tar.gz'
export HYPRE_URL='https://computation.llnl.gov/projects/hypre-scalable-linear-solvers-multigrid-methods/download/hypre-2.9.0b.tar.gz'

export TCL_PATH=$BASE/tcl-8.6.8
export TCL_UNTAR=$BASE/tcl8.6.8
export TCL_TAR='tcl8.6.8-src.tar.gz'
export TCL_URL='https://prdownloads.sourceforge.net/tcl/tcl8.6.8-src.tar.gz'

export MPI_PATH=/mnt/gluster/chtc/mpich-3.1
export MPI_TAR='openmpi-3.0.0.tar.gz'
export MPI_URL='https://www.open-mpi.org/software/ompi/v3.0/downloads/openmpi-3.0.0.tar.gz'

if [[ ! -d $BASE/installation_logs ]]; then
  mkdir $BASE/installation_logs
fi

# ==============================================================================
# DEFINE FUNCTIONS
# ==============================================================================
# ------------------------------------------------------------------------------
# DOWNLOAD AND UNTAR DEPENDENCY
# ------------------------------------------------------------------------------
getLibrary () {
    cd $BASE
    wget $thisURL
	tar xfz $thisTAR
	rm $thisTAR
	cd $thisPATH
}

# ==============================================================================
# INSTALL DEPENDENCIES
# ==============================================================================
# ------------------------------------------------------------------------------
# MPI
# ------------------------------------------------------------------------------
if [[ $MPI_INSTALL -eq 1 ]]; then
    thisURL=$MPI_URL
    thisTAR=$MPI_TAR
    thisPATH=$MPI_PATH
    getLibrary
    cd src
    ./configure --prefix=$HYPRE_PATH --with-MPI \
    --with-MPI-include=$MPI_PATH/include --with-MPI-libs=mpi \
    --with-MPI-lib-dirs=$MPI_PATH/lib > $BASE/installation_logs/hypre.out 2>&1 || exit 1
    make >> $BASE/installation_logs/mpi.out 2>&1 || exit 1
    make install >> $BASE/installation_logs/mpi.out 2>&1 || exit 1
fi
export LD_LIBRARY_PATH=$MPI_PATH/lib:$LD_LIBRARY_PATH
export PATH=$MPI_PATH/bin:$PATH

# ------------------------------------------------------------------------------
# HYPRE
# ------------------------------------------------------------------------------
if [[ $HYPRE_INSTALL -eq 1 ]]; then
    thisURL=$HYPRE_URL
    thisTAR=$HYPRE_TAR
    thisPATH=$HYPRE_PATH
    getLibrary
    cd src
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
    thisURL=$TCL_URL
    thisTAR=$TCL_TAR
    thisPATH=$TCL_UNTAR
    getLibrary
    cd unix
    ./configure --prefix=$TCL_PATH --enable-shared > $BASE/installation_logs/tcl.out 2>&1 || exit 1
    make >> $BASE/installation_logs/tcl.out 2>&1 || exit 1
    make install >> $BASE/installation_logs/tcl.out 2>&1 || exit 1
    rm -rf $TCL_UNTAR
fi
export LD_LIBRARY_PATH=$TCL_PATH/lib:$LD_LIBRARY_PATH

# ==============================================================================
# INSTALL PARFLOW
# ==============================================================================
# ------------------------------------------------------------------------------
# PFSIMULATOR
# ------------------------------------------------------------------------------
if [[ $PFSIMULATOR_INSTALL -eq 1 ]]; then
    cd $PARFLOW_DIR/pfsimulator
    make clean
    ./configure --prefix=$PARFLOW_DIR \
    --enable-timing \
    --with-amps=mpi1 \
    --with-mpi-include=$MPI_PATH/include \
    --with-mpi-libs=mpich \
    --with-mpi-lib-dirs=$MPI_PATH/lib \
    --with-clm \
    --with-netcdf4=no \
    --with-hypre=$HYPRE_PATH \
    --with-amps-sequential-io > $BASE/installation_logs/pfsimulator.out 2>&1 || exit 1
    make >> $BASE/installation_logs/pfsimulator.out 2>&1 || exit 1
    make install >> $BASE/installation_logs/pfsimulator.out 2>&1 || exit 1
fi

# ------------------------------------------------------------------------------
# PFTOOLS
# ------------------------------------------------------------------------------
if [[ $PFTOOLS_INSTALL -eq 1 ]]; then
    cd $PARFLOW_DIR/pftools
    make clean
    ./configure --prefix=$PARFLOW_DIR \
    --with-amps=mpi1 \
    --with-amps-sequential-io \
    --with-tcl=$TCL_PATH > $BASE/installation_logs/pftools.out 2>&1 || exit 1
    make >> $BASE/installation_logs/pftools.out 2>&1 || exit 1
    make install >> $BASE/installation_logs/pftools.out 2>&1 || exit 1
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
