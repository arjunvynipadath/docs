Mellanox Technologies - www.mellanox.com
***********************************************

mstflint: A BURNING FIRMWARE APPLICATION
----------------------------------------

1) Overview
    This document describes the mstflint burning tool for Mellanox manufactured
    adapter cards. The tool is available for download from:
    https://openfabrics.org/svn/gen2/branches/<version>/src/userspace/mstflint/

    The mstflint package contains the burning tool software, and provides
    access to the relevant source code. Please see the file LICENSE for
    licensing details.

 ***** IMPORTANT NOTE *****
    This burning tool should be used only with Mellanox-manufactured
    adapter cards. Using it with cards manufactured by other vendors may be harmful
    to the cards (due to different configurations).

    
2) mstflint Package Contents
    a) mstflint source code
    b) mtcr linux utility
       This utility enables the mstflint burning utility to access the adapter
       hardware registers


3) Installation
    a) Build the the mstflint utility.
        Example: 
        make

    b) Compilation should end with no error messages.
        For example:
	>make
	g++ -g -I. -Wall -O2 -fno-exceptions flint.cpp -o mstflint

    c) An executable mstflint will be generated in the current directory
       This is the mstflint utility that can be used to burn and examine
       the adapter on-board flash. You may copy this executable to an arbitrary
       location.

4) Requirements:
    a) Typically, you will need root privileges for flash access

    b) You will need the binary firmware-image file for your adapter card. See 
       http://www.mellanox.com/support/firmware_table.php for FW downloads.

    c) You must know the device location on the PCI bus.

       For example, to find an InfiniHost adapter card manufactured by Mellanox use:
	/sbin/lspci -d 15b3:5a44
	02:00.0 InfiniBand: Mellanox Technology: Unknown device 5a44 (rev a1)

	In this example, 02:00.0 identifies the device in the form bus:dev.fn
	
	For example, to find a ConnectX EN (Ethernet) Network Adapter Card (NIC)
        manufactured by Mellanox use:
	/sbin/lspci -d 15b3:6368 
	04:00.0 Ethernet controller: Mellanox Technologies Unknown device 6368 (rev a0)

5) Usage:
	Read mstflint usage. Enter: "./mstflint -h" for detailed help,

	Use mstflint to burn a device according to the burning instructions. 
	You will need to specify the device in the form bus:dev.fn as explained
	in section 4c) above, or in the alternative form
        /proc/bus/pci/bus/dev.fn .

       Examples:
       1) mstflint -d 02:00.0 v

	
       	In the above example, mstflint reads the /proc/bus/pci/devices
	to find the physical address of device Region0 (i.e., BAR0)
	and checks that the region size is exactly 0.
	It then accesses this region by means of the /dev/mem device.

       2) mstflint -d /proc/bus/pci/02/00.0 v

	This example accesses the device PCI configuration registers
	by means of the specified file under the /proc/bus/pci
	directory, and performs flash access by writing these
	registers.


7) Problem Reporting:
	Please collect the following information when reporting issues:

	uname -a
	cat /etc/issue
	cat /proc/bus/pci/devices
	lspci
        mstflint -d 02:00.0 v
        mstflint -d 02:00.0 q
