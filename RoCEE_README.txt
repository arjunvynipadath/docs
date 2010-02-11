===============================================================================
                       OFED-1.5.1 RoCEE Support README
			        February 2010
===============================================================================

Contents:
=========
1. Overview
2. Software Dependencies
3. User Guidelines
4. Ported Applications
5. Firmware Requirements
6. Known Issues


1. Overview
===========
RDMA over Converged Enhanced Ethernet (RoCEE) allows InfiniBand (IB) transport
over Ethernet networks. It encapsulates IB transport and GRH headers in
Ethernet packets bearing a dedicated ether type.
While the use of GRH is optional within IB subnets, it is mandatory when using
RoCEE. Verbs applications written over IB verbs should work seamlessly, but
they require provisioning of GRH information when creating address vectors. The
library and driver are modified to provide for mapping from GID to MAC
addresses required by the hardware.

2. Software Dependencies
========================
In order to use RoCEE over Mellanox ConnectX(R) hardware, the mlx4_en driver
must be loaded. Please refer to MLNX_EN_README.txt for further details.


3. User Guidelines
==================
Since RoCEE encapsulates InfiniBand traffic in Ethernet frames, the
corresponding net device must be up and running. In case of Mellanox
hardware, mlx4_en must be loaded and the corresponding interface configured.
- Make sure mlx4_en.ko is loaded
- Make sure an IP address has been configured to this interface
- Run "ibv_devinfo". There is a new field named "link_layer" which can be
  either "Ethernet" or "IB". If the value is IB, then you need to use
  connectx_port_config to change the ConnectX ports designation to eth (see
  mlx4_release_notes.txt for details)
- Configure the IP address of the interface so that the link will become
  active
- All IB verbs applications which run over IB verbs should work on RoCEE
  links as long as they use GRH headers (that is, as long as they specify use
  of GRH in their address vector)


4. Ported Applications
======================
- ibv_*_pingpong examples have been ported too. The user must specify the GID
  of the remote peer using the new '-g' option. The GID has the same format as
  that in /sys/class/infiniband/mlx4_0/ports/1/gids/0

- Note: Care should be taken when using ibv_ud_pingpong. The default message
  size is 2K, which is likely to exceed the MTU of the RoCEE link. Use 
  ibv_devinfo to inspect the link MTU and specify an appropriate message size

- All rdma_cm applications should work seamlessly without any change

- libsdp works without any change

- Performance tests have been ported


5. Firmware Requirements
========================
RoCEE requires ConnectX firmware version 2.7.000 or newer. Some features
require newer, not yet released firmware versions. For example, loopback
support is available in firmware version 2.7.700 or later.


6. Known Issues
===============
- PowerPC and ia64 architectures are not supported. x32 architectures were
  not tested.

- SRP is not supported.
