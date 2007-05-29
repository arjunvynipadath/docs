	    Open Fabrics Enterprise Distribution (OFED)
                            Version 1.2
			      README
			  
			  May 2007


This is the OpenFabrics Enterprise Distribution (OFED) version 1.2 software
package supporting InfiniBand fabrics. It is composed of several software
modules intended for use on a computer cluster constructed as an InfiniBand 
network.

*** Note:  If you plan to upgrade OFED on your cluster, please upgrade all
	   its nodes to this new version.

This document includes the following sections:

1. HW and SW Requirements
2. OFED Package Contents
3. A Note on the Installation Process
4. Building OFED Software RPMs
5. Installing OFED
6. Starting and Verifying the IB Fabric
7. MPI (Message Passing Interface) 
8. Related Documentation


OpenFabrics Home Page:  http://www.openfabrics.org
The OFED rev 1.2 software download available in www.openib.org/downloads.html

Please email bugs and error reports to your InfiniBand vendor, or use bugzilla
http://openib.org/bugzilla/



1. HW and SW Requirements:
==========================
1) Server platform with InfiniBand HCA (see OFED Distribution
   Release Notes for details)

2) Linux OS (see OFED Distribution Release Notes for details) 

3) Administrator privileges on your machine(s)

4) Disk Space: 	- For Build & Installation: 300MB
		- For Installation only:    200MB 

5) For the OFED Distribution to compile on your machine, some software packages
   of your OS distribution are required. These are listed here.

OS Distribution		Required Packages
---------------		----------------------------------   	
General:
o  Common to all        gcc, glib, glib-devel, glibc, glibc-devel,
                        automake, autoconf, libtool.
o  RedHat, Fedora       kernel-devel, rpm-build
o  SLES 9.0             kernel-source, udev, rpm
o  SLES 10.0            kernel-source, rpm

Note:   To build 32-bit libraries on x86_64 and ppc64 glibc-devel 32bit
        should be installed

Specific Component Requirements:
o  OSU MPI requires:    Fortran Compiler(default: gcc-g77) 
o  ibutils:  		tcl-8.4, tcl-devel-8.4, tk
o  tvflash: 		pciutils-devel
o  mvapich2:            libsysfs, libsysfs-devel

*** Important Note for open-iscsi users:
    Installing iSER as part of OFED installation will also install open-iscsi.
    Before installing OFED, please uninstall any open-iscsi version that may
    be installed on your machine. Installing OFED with iSER support while
    another open-iscsi version is already installed will cause the installation
    process to fail.

2. OFED Package Contents
========================

The OFED Distribution package generates RPMs for installing the following:
  
  o   OpenFabrics core and ULPs:
	- HCA drivers (mthca, mlx4, ipath, ehca)
	- core 
	- Upper Layer Protocols: IPoIB, SDP, SRP Initiator, iSER Initiator, 
	  and uDAPL
  o   OpenFabrics utilities:
	- OpenSM: InfiniBand Subnet Manager
  	- Diagnostic tools
	- Performance tests
  o   MPI:
	- OSU MPI stack supporting the InfiniBand interface
	- Open MPI stack supporting the InfiniBand interface
	- MPI benchmark tests (OSU BW/LAT, Intel MPI Benchmark, Presta)
  o   open-iscsi: open-iscsi initiator with iSER support
  o   Sources of all software modules (under conditions mentioned in the 
      modules' LICENSE files) 
  o   Documentation


3. A Note on the Installation Process
=====================================

The OFED build process can take up to 40 minutes. If you are planning to
install the OFED package on a multi-node cluster, it is recommended to build
OFED RPMs once into a shared directory, and use the created RPMs in order to
install the package on the rest of the cluster machines. 

Use the script build.sh to build the OFED RPMs. This script can be used as a
non-root user. 

To install the package, use the install.sh script. When installing from scratch,
install.sh will first build the RPMs, then install them onto the local machine.
If the RPMs already exist, the install.sh script will simply install them onto
the local machine without re-building them.

*** Important Note for Open MPI users ONLY: 
    You must install OFED (run install.sh). Building the OFED RPMs is 
    not sufficient.

4. Building OFED Software RPMs
==============================

Building OFED SW RPM packages can be a separate process or part of the
installer. In the latter case you may skip this section and move to the next
one: "Installing OFED Software".

Some users may wish to build OFED RPM files separate from the main
installation flow. To do this, please run the ./build.sh  script. (See note in
Section 3 above.)

The build process will temporarily use the following default directory:
/var/tmp/OFED. The build.sh script will prompt the user to enter a different
temporary directory if desired.

build.sh will also prompt the user for the installation directory. By default it
is /usr
The RPMs will be placed under ./RPMS directory.

For further details, see "Building OFED RPMs" and "Advanced Usage of OFED" in
OFED_Installation_Guide.txt under OFED-1.2/docs. 


5. Installing OFED Software
============================

The default installation directory is:   /usr

Install Quick Guide:
1) Download and extract: tar xzvf OFED-1.2.tgz file.
2) Change into directory: cd OFED-1.2
3) Run as root: ./install.sh
4) Follow the directions to install required components. For details, please see
   OFED_Installation_Guide.txt under OFED-1.2/docs.


Note: The install script removes previously installed IB packages and 
      re-installs from scratch. You will be prompted to acknowledge the deletion
      of the old packages. However, configuration files (.conf) will be
      preserved and saved with a ".rpmsave" extension. 


6. Starting and Verifying the IB Fabric
=======================================

1)  If you rebooted your machine after the installation process completed,
    IB interfaces should be up. If you did not reboot your machine, please
    enter the following command: /etc/init.d/openibd start

2)  Check that the IB driver is running on all nodes: ibv_devinfo should print
    "hca_id: <linux device name>" on the first line.
     
3)  Make sure that a Subnet Manager is running by invoking the sminfo utility.
    If an SM is not running, sminfo prints: 
    sminfo: iberror: query failed
    If an SM is running, sminfo prints the LID and other SM node information.
    Example:
    sminfo: sm lid 0x1 sm guid 0x2c9010b7c2ae1, activity count 20 priority 1 

    To check if OpenSM is running on the management node, enter: /etc/init.d/opensmd status
    To start OpenSM, enter: /etc/init.d/opensmd start

    Note: OpenSM parameters can be set via the file /etc/opensm.conf.
    Note: OpenSM can be configured to run upon boot by setting 'ONBOOT=yes' 
          in /etc/opensm.conf.

4)  Verify the status of ports by using ibv_devinfo: all connected ports should
    report a "PORT_ACTIVE" state.

5)  Check the network connectivity status: run ibchecknet to see if the subnet
    is "clean" and ready for ULP/application use. The following tools display 
    more information in addition to IB info: ibnetdiscover, ibhosts, and 
    ibswitches. 

6)  Alternatively, instead of running steps 3 to 5 you can use the ibdiagnet
    utility to perform a set of tests on your network. Upon finding an error,
    ibdiagnet will print a message starting with a "-E-". For a more complete
    report of the network features you should run ibdiagnet -r. If you have a
    topology file describing your network you can feed this file to ibdiagnet
    (using the option: -t <file>) and all reports will use the names they 
    appear in the file (instead of LIDs, GUIDs and directed routes).

7)  To run an application over SDP set the following variables:
    env LD_PRELOAD='stack_prefix'/lib/libsdp.so 
    LIBSDP_CONFIG_FILE='stack_prefix'/etc/libsdp.conf <application name> 
    (or LD_PRELOAD='stack_prefix'/lib64/libsdp.so on 64 bit machines)
    The default 'stack_prefix' is /usr


7. MPI (Message Passing Interface)
==================================

In Step 2 of the main menu of install.sh, options 2, 3 and 4 can
install one or more MPI stacks.  Multiple MPI stacks can be installed
simultaneously -- they will not conflict with each other.  

There are two MPI stacks included in this release of OFED:

- Ohio State University's MVAPICH 0.9.9 (specifically updated and
  modified by Mellanox Technologies and Cisco or this release of OFED)
- Open MPI 1.2.1

OFED also includes 4 basic tests that can be run against each MPI
stack: bandwidth (bw), latency (lt), Intel MPI Benchmark and Presta. The tests
are located under: <prefix>/mpi/<compiler>/<mpi stack>/tests/.

Please see MPI_README.txt for more details on each MPI package and how to run
the tests.


8. Related Documentation
========================
1) Release Notes for OFED Distribution components are to be found under 
   OFED-1.2/docs and, after the package installation, under 
   /usr/share/doc/ofed-docs-1.2 for RedHat
   /usr/share/doc/packages/ofed-docs-1.2 for SuSE.
2) For a detailed installation guide, see OFED_Installation_Guide.txt.
3) For more information, please visit the OFED web-page http://www.openfabrics.org


For more information contact your InfiniBand vendor. 

