===============================================================================
	MLNX_EN driver for Mellanox Adapter Cards with 10GigE Support 
			README for OFED 1.4
			   
			December 2008
===============================================================================

Contents:
=========
1. Overview
2. Software Dependencies
3. Ethernet Driver Usage and Configuration
4. Known Issues
5. Troubleshooting


1. Overview
===========
MLNX_EN driver is composed from mlx4_core and mlx4_en kernel modules.

The MLNX_EN driver release exposes the following capabilities:
- Single/Dual port
- Fibre Channel over Ethernet (FCoE)
- Up to 16 Rx queues per port
- Rx steering mode: Receive Core Affinity (RCA)
- Tx arbitration mode: VLAN user-priority (off by default)
- MSI-X or INTx
- Adaptive interrupt moderation
- HW Tx/Rx checksum calculation
- Large Send Offload (i.e., TCP Segmentation Offload)
- Large Receive Offload
- Multi-core NAPI support
- VLAN Tx/Rx acceleration (HW VLAN stripping/insertion)
- HW VLAN filtering
- HW multicast filtering
- ifconfig up/down + mtu changes (up to 10K)
- Ethtool support
- Net device statistics
- CX4 connectors (XAUI) or XFP


2. Software Dependencies
========================
- The mlx4_en module uses a Linux implementation for Large Receive Offload 
  (LRO) in kernel 2.6.24 and later. These kernels require installing the 
  "inet_lro" module.


3. Ethernet Driver Usage and Configuration
==========================================

- To assign an IP address to the interface run:
  #> ifconfig eth<x> <ip>

   where 'x' is the OS assigned interface number.

- To check driver and device information run:
  #> ethtool -i eth<x>

  Example:
  #> ethtool -i eth2
  driver: mlx4_en (MT_04A0140005)
  version: 1.3.0 (Sep 2008)
  firmware-version: 2.5.400
  bus-info: 0000:13:00.0 

- To query stateless offload status run:
  #> ethtool -k eth<x>

- To set stateless offload status run:
  #> ethtool -K eth<x> [rx on|off] [tx on|off] [sg on|off] [tso on|off]

- To query interrupt coalescing settings run:
  #> ethtool -c eth<x>

- By default, the driver uses adaptive interrupt moderation for the receive path,
  which adjusts the moderation time according to the traffic pattern.
  Adaptive moderation settings can be set by:
  #> ethtool -C eth<x> adaptive-rx on|off

- To set interrupt coalescing settings run:
  #> ethtool -C eth<x> [rx-usecs N] [rx-frames N] [tx-usecs N] [tx-frames N]
  
  Note: usec settings correspond to the time to wait after the *last* packet 
  sent/received before triggering an interrupt

- To query pause frame settings run:
  #> ethtool -a eth<x>

- To set pause frame settings run:
  #> ethtool -A eth<x> [rx on|off] [tx on|off]

- To obtain additional device statistics, run:
  #> ethtool -S eth<x>


The driver defaults to the following parameters:
- Both ports are activated (i.e., a net device is created for each port)
- The number of Rx rings for each port is the number of on-line CPUs
- Per-core NAPI is enabled
- LRO is enabled with 32 concurrent sessions per Rx ring

Some of these values can be changed using module parameters, which are 
detailed by running:
#> modinfo mlx4_en 

To set non-default values to module parameters, the following line should be
added to /etc/modprobe.conf file:
 "options mlx4_en <param_name>=<value> <param_name>=<value> ..."

Values of all parameters can be observed in /sys/module/mlx4_en/parameters/. 


4. Known Issues
===============
- For RedHat EL4, adding and removing multiple vlan interfaces over the network
  interface created by the mlx4_en driver may lead to printing the following:
  "kernel: unregister_netdevice: waiting for eth<x.y> to become free. Usage count ="

- iperf with multiple (> 100) streams may fail on kernel.org 2.6.25 versions
  earlier than 2.6.25.9.


5. Troubleshooting
==================
Problem: I restarted the driver and received the following error message:
   mlx4_core 0000:13:00.0: PCI device did not come back after reset, aborting.
   mlx4_core 0000:13:00.0: Failed to reset HCA, aborting.

Suggestion: This error appears if you have burnt new firmware to the adapter
   card but have not rebooted the machine yet. Reboot the machine to allow the
   new firmware to take effect.

