#!/bin/bash
# Carolyn Voter 2017.10

# Setup Parflow and associated libraries

# Make sure have *.tar files for hypre, tcl, and the github parflow folder
# Install to Gluster so don't need to install on local machines

# Current 02/08/2016, can obtain:
#   silo from here: https://wci.llnl.gov/simulation/computer-codes/silo/downloads
#   NOTE: silo 4.10.2 confirmed by developers as compatible


# HYPRE
#   Obtain hypre from here: http://computation.llnl.gov/project/linear_solvers/software.php
#   NOTE: as of Jan 2016, hypre 2.10 is not compatible with parflow, use hypre 2.9b.
#   Cannot find any documentation about hypre 2.11

# TCL
#   Obtain tcl from here: https://www.tcl.tk/software/tcltk/download.html

# PARFLOW
#   Hosted on github: https://github.com/parflow/parflow
#   git clone -b master --single-branch https://github.com/parflow/parflow.git
#   ISSUE (on Windows, same seems to be true here): parflow/acmacros/config.guess is too old. 
#   FIX: Copy config.guess from cygwin/usr/share/automake*
#		"cp usr/share/automake-1.12/config.guess home/Carolyn/ParFlow/parflow/acmacros/config.guess"
#   ISSUE: new option about netCDF configureation, gets confused unless you specify. 
#   FIX: add option to pfsimulator build: "--with-netcdf4=no"

# -------------------------------------------
# SET ENVIRONMENT VARIABLES
export CC=gcc
export CXX=g++
export FC=gfortran
export F77=gfortran
export HOME=/mnt/gluster/cvoter/ParFlow
export BASE=/mnt/gluster/cvoter/ParFlow
export PARFLOW_DIR=$BASE/parflow
export HYPRE_PATH=$BASE/hypre-2.9.0b
export TCL_PATH=$BASE/tcl-8.6.7
export MPI_PATH=/mnt/gluster/chtc/mpich-3.1
export LD_LIBRARY_PATH=$MPI_PATH/lib:$LD_LIBRARY_PATH
export PATH=$MPI_PATH/bin:$PATH

# -------------------------------------------
# UNTAR ALL DIRS
cd $BASE
#tar xfz hypre-2.9.0b.tar.gz
#tar xfz tcl8.6.7-src.tar.gz

# -------------------------------------------
# INSTALL HYPRE
#cd $HYPRE_PATH/src
#./configure --prefix=$HYPRE_PATH --with-MPI \
#--with-MPI-include=$MPI_PATH/include --with-MPI-libs=mpi \
#--with-MPI-lib-dirs=$MPI_PATH/lib > $BASE/installation_logs/hypre.out 2>&1 || exit 1
#make >> $BASE/installation_logs/hypre.out 2>&1 || exit 1
#make install >> $BASE/installation_logs/hypre.out 2>&1 || exit 1

# -------------------------------------------
# INSTALL TCL
#cd $BASE/tcl8.6.7/unix
#./configure --prefix=$TCL_PATH --enable-shared > $BASE/installation_logs/tcl.out 2>&1 || exit 1
#make >> $BASE/installation_logs/tcl.out 2>&1 || exit 1
#make install >> $BASE/installation_logs/tcl.out 2>&1 || exit 1

# -------------------------------------------
# EXPORT LIBRARIES
export LD_LIBRARY_PATH=$TCL_PATH/lib:$LD_LIBRARY_PATH

# -------------------------------------------
# INSTALL PARFLOW SIMULATOR
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

# -------------------------------------------
# INSTALL PARFLOW TOOLS
cd $PARFLOW_DIR/pftools
make clean
./configure --prefix=$PARFLOW_DIR \
--with-amps=mpi1 \
--with-amps-sequential-io \
--with-tcl=$TCL_PATH > $BASE/installation_logs/pftools.out 2>&1 || exit 1
make >> $BASE/installation_logs/pftools.out 2>&1 || exit 1
make install >> $BASE/installation_logs/pftools.out 2>&1 || exit 1

# -------------------------------------------
# TEST PARFLOW
cd $PARFLOW_DIR/test
make veryclean
make check > $BASE/installation_logs/pfcheck.out 2>&1

# -------------------------------------------
# EXIT
exit 0
