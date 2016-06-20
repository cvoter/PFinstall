#!/bin/bash
# Carolyn Voter 2016.05

# Setup Parflow and associated libraries
# Based on Parflow README (same as User Manual) and additional info on installing Silo and Hypre at: geco.mines.edu/next/bench/parflow/index.html

# Make sure have *.tar files for mpich2, hdf5, hypre, silo, tcl, and the svn parflow folder
# Install to Gluster so don't need to install on local machines

# Current 02/08/2016, can obtain:
#   hypre from here: http://computation.llnl.gov/project/linear_solvers/software.php
#	NOTE: hypre 2.10 is not compatible with parflow, use hypre 2.9b
#   silo from here: https://wci.llnl.gov/simulation/computer-codes/silo/downloads
#	NOTE: silo 4.10.2 confirmed by developers as compatible
#   tcl from here: https://www.tcl.tk/software/tcltk/download.html


# To obtain parflow, do this:
#   cd /home/cvoter
#   svn checkout https://parflow.svn.cvsdude.com/parflow/parflow/trunk parflow
# For specific version:
#   svn checkout -r 729 https://parflow.svn.cvsdude.com/parflow/parflow/trunk parflow
# For specific version within submit script:
#   (echo p; echo no) |svn checkout --username pfcheckout --password ParFlow1234 -r 729 https://parflow.svn.cvsdude.com/parflow/parflow/trunk parflow
# If prompted for username/password, use this:
#   username: pfcheckout
#   password: ParFlow1234
# On 02/08/2016, obtained v734
# On 05/16/2016, obtained v890
# On 06/02/2016, obtained v895 <--WORKS!!!


# -------------------------------------------
# SET ENVIRONMENT VARIABLES
export CC=gcc
export CXX=g++
export FC=gfortran
export F77=gfortran
export HOME=/mnt/gluster/cvoter/ParFlow
export BASE=/mnt/gluster/cvoter/ParFlow
export PARFLOW_DIR=$BASE/parflow
export SILO_PATH=$BASE/silo-4.9.1-bsd
export HYPRE_PATH=$BASE/hypre-2.9.0b
export TCL_PATH=$BASE/tcl-8.6.5
export HDF5_PATH=$BASE/hdf5-1.8.17/hdf5
export MPI_PATH=/mnt/gluster/chtc/mpich-3.1
export LD_LIBRARY_PATH=$MPI_PATH/lib:$LD_LIBRARY_PATH
export PATH=$MPI_PATH/bin:$PATH

# -------------------------------------------
# UNTAR ALL DIRS
#cd $BASE
#tar xzf silo-4.9.1-bsd.tar.gz
#tar xfz hypre-2.9.0b.tar.gz
#tar xfz tcl8.6.5-src.tar.gz
tar xzf hdf5-1.8.17.tar.gz

# -------------------------------------------
# INSTALL HYPRE
#cd $HYPRE_PATH/src
#./configure --prefix=$HYPRE_PATH --with-MPI \
#--with-MPI-include=$MPI_PATH/include --with-MPI-libs=mpi \
#--with-MPI-lib-dirs=$MPI_PATH/lib > $BASE/installation_logs/hypre.out 2>&1 || exit 1
#make >> $BASE/installation_logs/hypre.out 2>&1 || exit 1
#make install >> $BASE/installation_logs/hypre.out 2>&1 || exit 1

# -------------------------------------------
# INSTALL HDF5
cd hdf5-1.8.17
./configure --prefix=$BASE/hdf5-1.8.17 --enable-fortran --enable-cxx /
--enable-static-exec  --enable-using-memchecker --with-gnu-ld >> $BASE/installation_logs/hdf5.out 2>&1 || exit 1
make >> $BASE/installation_logs/hdf5.out 2>&1 || exit 1
make install >> $BASE/installation_logs/hdf5.out 2>&1 || exit 1

# -------------------------------------------
# INSTALL SILO
cd $SILO_PATH
./configure --prefix=$SILO_PATH --disable-silex /
--with-hdf5=$HDF5_PATH/include,$HDF5_PATH/lib > $BASE/installation_logs/siloHDF5.out 2>&1 || exit 1
make >> $BASE/installation_logs/siloHDF5.out 2>&1 || exit 1
make install >> $BASE/installation_logs/siloHDF5.out 2>&1 || exit 1

# -------------------------------------------
# INSTALL TCL
#cd $BASE/tcl8.6.5/unix
#./configure --prefix=$TCL_PATH --enable-shared > $BASE/installation_logs/tcl.out 2>&1 || exit 1
#make >> $BASE/installation_logs/tcl.out 2>&1 || exit 1
#make install >> $BASE/installation_logs/tcl.out 2>&1 || exit 1

# -------------------------------------------
# EXPORT LIBRARIES
export LD_LIBRARY_PATH=$TCL_PATH/lib:$LD_LIBRARY_PATH
#export LD_LIBRARY_PATH=$SILO_PATH/lib:$LD_LIBRARY_PATH

# -------------------------------------------
# INSTALL PARFLOW SIMULATOR
cd $PARFLOW_DIR/pfsimulator
make veryclean
./configure --prefix=$PARFLOW_DIR \
--enable-timing \
--with-amps=mpi1 \
--with-mpi-include=$MPI_PATH/include \
--with-mpi-libs=mpich \
--with-mpi-lib-dirs=$MPI_PATH/lib \
--with-clm \
--with-hypre=$HYPRE_PATH \
--with-amps-sequential-io \
--with-hdf5=$HDF5_PATH \
--with-silo=$SILO_PATH > $BASE/installation_logs/pfsimulator.out 2>&1 || exit 1
make >> $BASE/installation_logs/pfsimulator.out 2>&1 || exit 1
make install >> $BASE/installation_logs/pfsimulator.out 2>&1 || exit 1

# -------------------------------------------
# INSTALL PARFLOW TOOLS
cd $PARFLOW_DIR/pftools
make veryclean
./configure --prefix=$PARFLOW_DIR \
--with-amps=mpi1 \
--with-amps-sequential-io \
--with-silo=$SILO_PATH \
--with-hdf5=$HDF5_PATH \
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
