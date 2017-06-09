#!/bin/bash
# Carolyn Voter 2017.05

# Setup Parflow and associated libraries on Windows cygwin
# Based on Parflow README (same as User Manual) and additional info on installing Silo and Hypre at: http://parflow.blogspot.com/

# Make sure have *.tar files for openmpi, hypre, silo, tcl, and the svn parflow folder
# Current 05/26/2017, can obtain:
#   open mpi from here: http://www.open-mpi.org/software/ompi/v1.8/downloads/openmpi-1.8.3.tar.gz
#   hypre from here: http://computation.llnl.gov/project/linear_solvers/software.php
#	NOTE: hypre 2.10 (and presumably more recent versions) is not compatible with parflow, use hypre 2.9b
#   silo from here: https://wci.llnl.gov/simulation/computer-codes/silo/downloads
#	NOTE: silo 4.10.2 confirmed by developers as compatible
#   tcl from here: https://www.tcl.tk/software/tcltk/download.html


# To obtain parflow, do this:
#   svn checkout https://parflow.svn.cvsdude.com/parflow/parflow/trunk parflow
# For specific version:
#   svn checkout -r 729 https://parflow.svn.cvsdude.com/parflow/parflow/trunk parflow
# For specific version within submit script:
#   (echo p; echo no) | svn checkout --username pfcheckout --password ParFlow1234 -r 729 https://parflow.svn.cvsdude.com/parflow/parflow/trunk parflow
# If prompted for username/password, use this:
#   username: pfcheckout
#   password: ParFlow1234
# On 05/25/2017, obtained v895 <--Same version that has been working on CHTC since June 2016

# -------------------------------------------
# SET ENVIRONMENT VARIABLES
export CC=gcc
export CXX=g++
export FC=gfortran
export F77=gfortran
#export HOME=/home/Carolyn/ParFlow
export BASE=/home/Carolyn/ParFlow
export PARFLOW_DIR=$BASE/parflow
export SILO_PATH=$BASE/silo-4.10.2
export HYPRE_PATH=$BASE/hypre-2.9.0b
export TCL_PATH=$BASE/tcl-8.6.6
export MPI_PATH=$BASE/openmpi-2.1.1
#export LD_LIBRARY_PATH=$MPI_PATH/lib:$LD_LIBRARY_PATH
export PATH=$MPI_PATH/bin:$PATH

# -------------------------------------------
# UNTAR ALL DIRS
cd $BASE
tar xfz openmpi-2.1.1.tar.gz
tar xfz hypre-2.9.0b.tar.gz
tar xzf silo-4.10.2.tar.gz
tar xfz tcl8.6.6-src.tar.gz


# -------------------------------------------
# INSTALL OPEN MPI
cd $MPI_PATH
./configure --prefix=$MPI_PATH > $BASE/installation_logs/mpi.out 2>&1 || exit 1
make >> $BASE/installation_logs/mpi.out 2>&1 || exit 1
make install >> $BASE/installation_logs/mpi.out 2>&1 || exit 1

# -------------------------------------------
# INSTALL HYPRE
cd $HYPRE_PATH/src
./configure --prefix=$HYPRE_PATH --with-MPI \
--with-MPI-include=$MPI_PATH/include --with-MPI-libs=mpi \
--with-MPI-lib-dirs=$MPI_PATH/lib > $BASE/installation_logs/hypre.out 2>&1 || exit 1
make >> $BASE/installation_logs/hypre.out 2>&1 || exit 1
make install >> $BASE/installation_logs/hypre.out 2>&1 || exit 1

# -------------------------------------------
# INSTALL SILO
cd $SILO_PATH
#./configure --prefix=$SILO_PATH --disable-silex --with-hdf5=$HDF5_PATH/include,$HDF5_PATH/lib > $BASE/installation_logs/siloHDF5.out 2>&1 || exit 1
./configure --prefix=$SILO_PATH --disable-silex > $BASE/installation_logs/silo.out 2>&1 || exit 1
make >> $BASE/installation_logs/silo.out 2>&1 || exit 1
make install >> $BASE/installation_logs/silo.out 2>&1 || exit 1

# -------------------------------------------
# INSTALL TCL
cd $BASE/tcl8.6.6/unix
./configure --prefix=$TCL_PATH --enable-shared > $BASE/installation_logs/tcl.out 2>&1 || exit 1
make >> $BASE/installation_logs/tcl.out 2>&1 || exit 1
make install >> $BASE/installation_logs/tcl.out 2>&1 || exit 1

# -------------------------------------------
# EXPORT LIBRARIES
export LD_LIBRARY_PATH=$TCL_PATH/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$SILO_PATH/lib:$LD_LIBRARY_PATH

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
