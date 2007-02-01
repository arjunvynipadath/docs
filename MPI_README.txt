		Open Fabrics Enterprise Distribution (OFED)
			MPI in OFED 1.1 README

			    October 2006


===============================================================================
Table of Contents
===============================================================================
1. General
2. OSU MVAPICH MPI
3. Open MPI


===============================================================================
1. General
===============================================================================
Two MPI stacks are included in this release of OFED:

- Ohio State University (OSU) MVAPICH 0.9.7 (Modified by Mellanox
  Technologies)
- Open MPI 1.1.1-1

Setup, compilation and run information of OSU MVAPICH and Open MPI is
provided below in sections 2 and 3 respectively.

1.1 Installation Note
---------------------
In Step 2 of the main menu of install.sh, options 2, 3 and 4 can install
one or more MPI stacks. Please refer to docs/OFED_Installation_Guide.txt
to learn about the different options.

The installation script allows each MPI to be compiled using one or
more compilers. Users need to set, per MPI stack installed, the PATH
and/or LD_LIBRARY_PATH so as to install the desired compiled MPI stacks.

1.2 MPI Tests
-------------
OFED includes four basic tests that can be run against each MPI stack:
bandwidth (bw), latency (lt), Intel MPI Benchmark, and Presta. The tests
are located under: <prefix>/mpi/<compiler>/<mpi stack>/tests/, 
where <prefix> is /usr/local/ofed by default.

===============================================================================
2. OSU MVAPICH MPI
===============================================================================

This package is a modified version of the Ohio State University (OSU)
MVAPICH Rev 0.9.7 MPI software package, and is the officially supported
MPI stack for this release of OFED. Modifications to the original version
include: additional features, bug fixes, and RPM packaging.
See http://nowlab.cse.ohio-state.edu/projects/mpi-iba/ for more details.
 

2.1 Setting up for OSU MVAPICH MPI
----------------------------------
To launch OSU MPI jobs, its installation directory needs to be included
in PATH and LD_LIBRARY_PATH. To set them, execute one of the following
commands:
  source <prefix>/mpi/<compiler>/<mpi stack>/etc/mvapich.sh
	-- when using sh for launching MPI jobs
 or
  source <prefix>/mpi/<compiler>/<mpi stack>/etc/mvapich.csh
	-- when using csh for launching MPI jobs


2.2 Compiling OSU MVAPICH MPI Applications:
-------------------------------------------
***Important note***: 
A valid Fortran compiler must be present in order to build the MVAPICH MPI
stack and tests.

The default gcc-g77 Fortran compiler is provided with all RedHat Linux
releases.  SuSE distributions earlier than SuSE Linux 9.0 do not provide
this compiler as part of the default installation.

The following compilers are supported by OFED's OSU MPI package: gcc,
intel and pathscale.  The install script prompts the user to choose
the compiler with which to build the OSU MVAPICH MPI RPM. Note that more
than one compiler can be selected simultaneously, if desired.

For details see:
  http://nowlab.cse.ohio-state.edu/projects/mpi-iba/mvapich_user_guide.html

To review the default configuration of the installation, check the default
configuration file: <prefix>/mpi/<compiler>/<mpi stack>/etc/mvapich.conf

2.3 Running OSU MVAPICH MPI Applications:
----------------------------------------- 
Requirements:
o At least two nodes. Example: mtlm01, mtlm02
o Machine file: Includes the list of machines. Example: /root/cluster
o Bidirectional rsh or ssh without a password
 
Note for OSU: ssh will be used unless -rsh is specified. In order to use
rsh, add to the mpirun_rsh command the parameter: -rsh

*** Running OSU tests ***

/usr/local/ofed/mpi/gcc/mvapich-0.9.7-mlx2.2.0/bin/mpirun_rsh -np 2 -hostfile /root/cluster /usr/local/ofed/mpi/gcc/mvapich-0.9.7-mlx2.2.0/tests/osu_benchmarks-2.2/osu_bw
/usr/local/ofed/mpi/gcc/mvapich-0.9.7-mlx2.2.0/bin/mpirun_rsh -np 2 -hostfile /root/cluster /usr/local/ofed/mpi/gcc/mvapich-0.9.7-mlx2.2.0/tests/osu_benchmarks-2.2/osu_latency
/usr/local/ofed/mpi/gcc/mvapich-0.9.7-mlx2.2.0/bin/mpirun_rsh -np 2 -hostfile /root/cluster /usr/local/ofed/mpi/gcc/mvapich-0.9.7-mlx2.2.0/tests/osu_benchmarks-2.2/osu_bibw
/usr/local/ofed/mpi/gcc/mvapich-0.9.7-mlx2.2.0/bin/mpirun_rsh -np 2 -hostfile /root/cluster /usr/local/ofed/mpi/gcc/mvapich-0.9.7-mlx2.2.0/tests/osu_benchmarks-2.2/osu_bcast

*** Running Intel MPI Benchmark test (Full test) ***

/usr/local/ofed/mpi/gcc/mvapich-0.9.7-mlx2.2.0/bin/mpirun_rsh -np 2 -hostfile /root/cluster /usr/local/ofed/mpi/gcc/mvapich-0.9.7-mlx2.2.0/tests/IMB-2.3/IMB-MPI1
 
*** Running Presta test ***

/usr/local/ofed/mpi/gcc/mvapich-0.9.7-mlx2.2.0/bin/mpirun_rsh -np 2 -hostfile /root/cluster /usr/local/ofed/mpi/gcc/mvapich-0.9.7-mlx2.2.0/tests/presta-1.4.0/com -o 100
/usr/local/ofed/mpi/gcc/mvapich-0.9.7-mlx2.2.0/bin/mpirun_rsh -np 2 -hostfile /root/cluster /usr/local/ofed/mpi/gcc/mvapich-0.9.7-mlx2.2.0/tests/presta-1.4.0/glob -o 100
/usr/local/ofed/mpi/gcc/mvapich-0.9.7-mlx2.2.0/bin/mpirun_rsh -np 2 -hostfile /root/cluster /usr/local/ofed/mpi/gcc/mvapich-0.9.7-mlx2.2.0/tests/presta-1.4.0/globalop


===============================================================================
3. Open MPI
===============================================================================

Open MPI is a next-generation MPI implementation from the Open MPI
Project (http://www.open-mpi.org/). Version 1.1.1-1 of Open MPI is
included in this release, which is also available directly
from the main Open MPI web site.  This MPI stack is being offered in
OFED as a "technology preview," meaning that it is not officially
supported yet.  It is expected that future releases of OFED will have
fully supported versions of Open MPI.

A working Fortran compiler is not required to build Open MPI, but some
of the included MPI tests are written in Fortran. These tests will not
compile/run if Open MPI is built without Fortran support.

The following compilers are supported by OFED's Open MPI package: GNU,
Pathscale, Intel, or Portland.  The install script prompts the user
for the compiler with which to build the Open MPI RPM. Note that more
than one compiler can be selected simultaneously, if desired.

Users should check the main Open MPI web site for additional
documentation and support. (Note: The FAQ file considers 
InfiniBand tuning among other issues.)

3.1 Setting up for Open MPI:
----------------------------
The Open MPI team strongly advises users to put the Open MPI installation
directory in their PATH and LD_LIBRARY_PATH. This can be done at the
system level if all users are going to use Open MPI.  Specifically:
- add <prefix>/bin to PATH
- add <prefix>/lib to LD_LIBRARY_PATH

<prefix> is the directory where the desired Open MPI instance was installed.
("instance" refers to the compiler used for Open MPI compilation at install
time.)

If using rsh or ssh to launch MPI jobs, you *must* set the variables described
above in your shell startup files (e.g., .bashrc, .cshrc, etc.).

If you are using a job scheduler to launch MPI jobs (e.g., SLURM, Torque),
setting the PATH and LD_LIBRARY_PATH is still required, but it does
not need to be set in your shell startup files.  Procedures describing
how to add these values to PATH and LD_LIBRARY_PATH are described in
detail at:
    http://www.open-mpi.org/faq/?category=running

3.2 Compiling Open MPI Applications:
------------------------------------
(copied from http://www.open-mpi.org/faq/?category=mpi-apps -- see 
this web page for more details)

The Open MPI team strongly recommends that you simply use Open MPI's
"wrapper" compilers to compile your MPI applications. That is, instead
of using (for example) gcc to compile your program, use mpicc. Open
MPI provides a wrapper compiler for four languages:

          Language       Wrapper compiler name 
          -------------  --------------------------------
          C              mpicc
          C++            mpiCC, mpicxx, or mpic++
                         (note that mpiCC will not exist
                          on case-insensitive file-systems)
          Fortran 77     mpif77
          Fortran 90     mpif90
          -------------  --------------------------------

Note that if no Fortran 77 or Fortran 90 compilers were found when
Open MPI was built, Fortran 77 and 90 support will automatically be
disabled (respectively).

If you expect to compile your program as: 

    > gcc my_mpi_application.c -lmpi -o my_mpi_application
 
Simply use the following instead: 

    > mpicc my_mpi_application.c -o my_mpi_application

Specifically: simply adding "-lmpi" to your normal compile/link
command line *will not work*.  See
http://www.open-mpi.org/faq/?category=mpi-apps if you cannot use the
Open MPI wrapper compilers.
 
Note that Open MPI's wrapper compilers do not do any actual compiling
or linking; all they do is manipulate the command line and add in all
the relevant compiler / linker flags and then invoke the underlying
compiler / linker (hence, the name "wrapper" compiler). More
specifically, if you run into a compiler or linker error, check your
source code and/or back-end compiler -- it is usually not the fault of
the Open MPI wrapper compiler.

3.3 Running Open MPI Applications:
----------------------------------
Open MPI uses either the "mpirun" or "mpiexec" commands to launch
applications.  If your cluster uses a resource manager (such as SLURM
or Torque), providing a hostfile is not necessary:

    > mpirun -np 4 my_mpi_application

If you use rsh/ssh to launch applications, they must be set up to NOT
prompt for a password (see http://www.open-mpi.org/faq/?category=rsh
for more details on this topic). Moreover, you need to provide a hostfile
containing a list of hosts to run on.

Example:

    > cat hostfile
    node1.example.com
    node2.example.com
    node3.example.com
    node4.example.com

    > mpirun -np 4 -hostfile hostfile my_mpi_application
      (application runs on all 4 nodes)

In the following examples, replace <N> with the number of nodes to run on,
and <HOSTFILE> with the filename of a valid hostfile listing the nodes
to run on.

Example1: Running the OSU bandwidth:

    > cd /usr/local/ofed/mpi/gcc/openmpi-1.1.1-1/tests/osu_benchmarks-2.2
    > mpirun -np <N> -hostfile <HOSTFILE> osu_bw

Example2: Running the Intel MPI Benchmark benchmarks:

    > cd /usr/local/ofed/mpi/gcc/openmpi-1.1.1-1/tests/IMB-2.3
    > mpirun -np <N> -hostfile <HOSTFILE> IMB-MPI1

Example3: Running the Presta benchmarks:

    > cd /usr/local/ofed/mpi/gcc/openmpi-1.1.1-1/tests/presta-1.4.0
    > mpirun -np <N> -hostfile <HOSTFILE> com -o 100
