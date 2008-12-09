SCSI RDMA Protocol (SRP) Target driver for Linux
=================================================

SRP Target driver is designed to work directly on top of OpenFabrics
OFED-1.x software stack (http://www.openfabrics.org) or Infiniband
drivers in Linux kernel tree (kernel.org). It also interfaces with 
Generic SCSI target mid-level driver - SCST (http://scst.sourceforge.net)

By interfacing with SCST driver we are able to work and support a lot IO
modes on real or virtual devices in the backend
1. scst_disk  -- interfacing with scsi sub-system to claim and export real
scsi devices ie. disks, hardware raid volumes, tape library as SRP's luns

2. scst_vdisk -- fileio and blockio modes. This allows you to turn software
raid volumes, LVM volumes, IDE disks, block devices and normal files into
SRP's luns

3. NULLIO mode will allow you to measure the performance without sending IOs
to *real* devices


Prerequisites
-------------
0. Supported distributions: RHEL 5/5.1/5.2, SLES 10 sp1/sp2 and vanilla kernels >
   2.6.16
Note: On distribution default kernels you can run scst_vdisk blockio mode
      to have good performance. You can also run scst_disk ie. scsi pass-thru
      mode; however, you have to compile scst with -DSTRICT_SERIALIZING 
      enabled and this does not yield good performance.
      It is required to recompile the kernel to have good performance with
      scst_disk ie. scsi pass-thru mode

1. Download and install SCST driver.

a. download scst-1.0.0.tar.gz from this URL
   http://scst.sourceforge.net/downloads.html
If your distribution is RHEL 5.2 please go to step <e>

b. untar and install scst-1.0.0
   $ tar zxvf scst-1.0.0.tar.gz
   $ cd scst-1.0.0
  
   For RedHat distributions:
   $ make && make install

   For SuSE distributions:
   . Save the following patch to /tmp/scst_sles_spX.patch

/************************  Start scst_sless_spX.patch *********************/
diff -Naur scst-1.0.0/src/scst_lib.c scst-1.0.0.wk/src/scst_lib.c
--- scst-1.0.0/src/scst_lib.c	2008-06-26 23:20:18.000000000 -0700
+++ scst-1.0.0.wk/src/scst_lib.c	2008-12-08 15:28:46.000000000 -0800
@@ -1071,7 +1071,7 @@
 	return orig_cmd;
 }
 
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 18)
+#if LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 16)
 static void scst_req_done(struct scsi_cmnd *scsi_cmd)
 {
 	struct scsi_request *req;
@@ -1134,7 +1134,7 @@
 	TRACE_EXIT();
 	return;
 }
-#else /* LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 18) */
+#else /* LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 16) */
 static void scst_send_release(struct scst_device *dev)
 {
 	struct scsi_device *scsi_dev;
@@ -1183,7 +1183,7 @@
 	TRACE_EXIT();
 	return;
 }
-#endif /* LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 18) */
+#endif /* LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 16) */
 
 /* scst_mutex supposed to be held */
 static void scst_clear_reservation(struct scst_tgt_dev *tgt_dev)
@@ -1421,7 +1421,7 @@
 	sBUG_ON(cmd->inc_blocking || cmd->needs_unblocking ||
 		cmd->dec_on_dev_needed);
 
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 18)
+#if LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 16)
 #if defined(EXTRACHECKS)
 	if (cmd->scsi_req) {
 		PRINT_ERROR("%s: %s", __func__, "Cmd with unfreed "
@@ -1596,7 +1596,7 @@
 	return;
 }
 
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 18)
+#if LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 16)
 int scst_alloc_request(struct scst_cmd *cmd)
 {
 	int res = 0;
diff -Naur scst-1.0.0/src/scst_main.c scst-1.0.0.wk/src/scst_main.c
--- scst-1.0.0/src/scst_main.c	2008-07-07 12:04:00.000000000 -0700
+++ scst-1.0.0.wk/src/scst_main.c	2008-12-08 15:25:05.000000000 -0800
@@ -1593,7 +1593,7 @@
 
 	TRACE_ENTRY();
 
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 18)
+#if LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 16)
 	{
 		struct scsi_request *req;
 		BUILD_BUG_ON(SCST_SENSE_BUFFERSIZE !=
diff -Naur scst-1.0.0/src/scst_priv.h scst-1.0.0.wk/src/scst_priv.h
--- scst-1.0.0/src/scst_priv.h	2008-06-12 04:40:53.000000000 -0700
+++ scst-1.0.0.wk/src/scst_priv.h	2008-12-08 15:25:43.000000000 -0800
@@ -27,7 +27,7 @@
 #include <scsi/scsi_device.h>
 #include <scsi/scsi_host.h>
 
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 18)
+#if LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 16)
 #include <scsi/scsi_request.h>
 #endif
 
@@ -320,7 +320,7 @@
 void scst_check_retries(struct scst_tgt *tgt);
 void scst_tgt_retry_timer_fn(unsigned long arg);
 
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 18)
+#if LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 16)
 int scst_alloc_request(struct scst_cmd *cmd);
 void scst_release_request(struct scst_cmd *cmd);
 
diff -Naur scst-1.0.0/src/scst_targ.c scst-1.0.0.wk/src/scst_targ.c
--- scst-1.0.0/src/scst_targ.c	2008-06-26 23:20:05.000000000 -0700
+++ scst-1.0.0.wk/src/scst_targ.c	2008-12-08 15:26:45.000000000 -0800
@@ -1132,7 +1132,7 @@
 	return context;
 }
 
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 18)
+#if LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 16)
 static inline struct scst_cmd *scst_get_cmd(struct scsi_cmnd *scsi_cmd,
 					    struct scsi_request **req)
 {
@@ -1183,7 +1183,7 @@
 	TRACE_EXIT();
 	return;
 }
-#else /* LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 18) */
+#else /* LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 16) */
 static void scst_cmd_done(void *data, char *sense, int result, int resid)
 {
 	struct scst_cmd *cmd;
@@ -1205,7 +1205,7 @@
 	TRACE_EXIT();
 	return;
 }
-#endif /* LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 18) */
+#endif /* LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 16) */
 
 static void scst_cmd_done_local(struct scst_cmd *cmd, int next_state)
 {
@@ -1771,7 +1771,7 @@
 	}
 #endif
 
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 18)
+#if LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 16)
 	if (unlikely(scst_alloc_request(cmd) != 0)) {
 		if (scst_cmd_atomic(cmd)) {
 			rc = SCST_EXEC_NEED_THREAD;
@@ -1823,7 +1823,7 @@
 out_error:
 	scst_set_cmd_error(cmd, SCST_LOAD_SENSE(scst_sense_hardw_error));
 
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 18)
+#if LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 16)
 out_busy:
 	scst_set_busy(cmd);
 	/* go through */
/************************  End scst_sless_spX.patch ***********************/

   . patch -p1 < /tmp/scst_sles_spX.patch
   . make && make install

c. save the following patch into /tmp/scsi_tgt.patch

/************************  Start scsi_tgt.patch *********************/
--- scsi_tgt.h	2008-07-20 14:25:30.000000000 -0700
+++ scsi_tgt.h	2008-07-20 14:25:09.000000000 -0700
@@ -42,7 +42,9 @@
 #endif

 #if LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 19)
+/*
 typedef _Bool bool;
+*/
 #define true  1
 #define false 0
 #endif
@@ -2330,7 +2332,7 @@
 void scst_async_mcmd_completed(struct scst_mgmt_cmd *mcmd, int status);

 #if LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 24)
-
+/*
 static inline struct page *sg_page(struct scatterlist *sg)
 {
	return sg->page;
@@ -2358,7 +2360,7 @@
	sg->offset = offset;
	sg->length = len;
 }
-
+*/
 #endif /* LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 24) */

 static inline void sg_clear(struct scatterlist *sg)
/************************  End scsi_tgt.patch *********************/

d. patch scsi_tgt.h file with /tmp/scsi_tgt.patch
   $ cd /usr/local/include/scst;
   $ cp scst.h scsi_tgt.h
   $ patch -p0 < /tmp/scsi_tgt.patch

These steps (e-h) are for RHEL 5.2 distributions only
Other versions (RHEL 5/5.1, SLES 10 sp1/sp2) should keep these steps (e-h)
and continue with step (2) - OFED installation

e. save the following patch into /tmp/scst.patch

/************************  Start scst.patch *********************/
--- scst.h	2008-07-20 14:25:30.000000000 -0700
+++ scst.h	2008-07-20 14:25:09.000000000 -0700
@@ -42,7 +42,9 @@
 #endif

 #if LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 19)
+/*
 typedef _Bool bool;
+*/
 #define true  1
 #define false 0
 #endif
/************************  End scst.patch *********************/

f. untar, patch, and install scst-1.0.0
   $ tar zxvf scst-1.0.0.tar.gz
   $ cd scst-1.0.0/include
   $ patch -p0 < /tmp/scst.patch
   $ cd ..
   $ make && make install

g. save the following patch into /tmp/scsi_tgt.patch

/************************  Start scsi_tgt.patch *********************/
--- scsi_tgt.h	2008-07-20 14:25:30.000000000 -0700
+++ scsi_tgt.h	2008-07-20 14:25:09.000000000 -0700
@@ -2330,7 +2332,7 @@
 void scst_async_mcmd_completed(struct scst_mgmt_cmd *mcmd, int status);

 #if LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 24)
-
+/*
 static inline struct page *sg_page(struct scatterlist *sg)
 {
	return sg->page;
@@ -2358,7 +2360,7 @@
	sg->offset = offset;
	sg->length = len;
 }
-
+*/
 #endif /* LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 24) */
static inline void sg_clear(struct scatterlist *sg)
/************************  End scsi_tgt.patch *********************/

h. patch scsi_tgt.h file with /tmp/scsi_tgt.patch
   $ cd /usr/local/include/scst
   $ cp scst.h scsi_tgt.h
   $ patch -p0 < /tmp/scsi_tgt.patch

2. Download/install OFED-1.3.1 or OFED-1.4 - SRP target is part of OFED

Note: if your system already have OFED stack installed, you need to remove
      all the previous built RPMs and reinstall
      
   $ cd ~/OFED-1.4
   $ rm RPMS/*
   $ ./install.pl -c ofed.conf

a. download OFED packages from this URL
   http://www.openfabrics.org/downloads/OFED/

b. install OFED - remember to choose srpt=y
   $ cd ~/OFED-1.4
   $ ./install.pl


How-to run
-----------
A. On srp target machine

1. Please refer to SCST's README for loading scst driver and its dev_handlers
drivers (scst_disk, scst_vdisk block or file IO mode, nullio, ...)

Note: In any mode you always need to have lun 0 in any group's device list
      Then you can have any lun number following lun 0 (it does not required
      have lun number in order except that the first lun is always 0)

      Setting SRPT_LOAD=yes in /etc/infiniband/openib.conf is not good enough
      It only load ib_srpt module and does not load scst and its dev_handlers
 
Example 1: working with VDISK BLOCKIO mode
           (using md0 device, sda, and cciss/c1d0)
a. modprobe scst
b. modprobe scst_vdisk
c. echo "open vdisk0 /dev/md0 BLOCKIO" > /proc/scsi_tgt/vdisk/vdisk
d. echo "open vdisk1 /dev/sda BLOCKIO" > /proc/scsi_tgt/vdisk/vdisk
e. echo "open vdisk2 /dev/cciss/c1d0 BLOCKIO" > /proc/scsi_tgt/vdisk/vdisk
f. echo "add vdisk0 0" >/proc/scsi_tgt/groups/Default/devices
g. echo "add vdisk1 1" >/proc/scsi_tgt/groups/Default/devices
h. echo "add vdisk2 2" >/proc/scsi_tgt/groups/Default/devices

Example 2: working with real back-end scsi disks in scsi pass-thru mode
a. modprobe scst
b. modprobe scst_disk
c. cat /proc/scsi_tgt/scsi_tgt
ibstor00:~ # cat /proc/scsi_tgt/scsi_tgt 
Device (host:ch:id:lun or name)                             Device handler
0:0:0:0                                                     dev_disk
4:0:0:0                                                     dev_disk
5:0:0:0                                                     dev_disk
6:0:0:0                                                     dev_disk
7:0:0:0                                                     dev_disk

Now you want to exclude the first scsi disk and expose the last 4 scsi disks
as IB/SRP luns for I/O

echo "add 4:0:0:0 0" >/proc/scsi_tgt/groups/Default/devices
echo "add 5:0:0:0 1" >/proc/scsi_tgt/groups/Default/devices
echo "add 6:0:0:0 2" >/proc/scsi_tgt/groups/Default/devices
echo "add 7:0:0:0 3" >/proc/scsi_tgt/groups/Default/devices

Example 3: working with scst_vdisk FILEIO mode
           (using md0 device and file 10G-file)
a. modprobe scst
b. modprobe scst_vdisk
c. echo "open vdisk0 /dev/md0" > /proc/scsi_tgt/vdisk/vdisk
d. echo "open vdisk1 /10G-file" > /proc/scsi_tgt/vdisk/vdisk
e. echo "add vdisk0 0" >/proc/scsi_tgt/groups/Default/devices
f. echo "add vdisk1 1" >/proc/scsi_tgt/groups/Default/devices

2. modprobe ib_srpt

B. On initiator machines you can manualy do the following steps:

1. modprobe ib_srp
2. ipsrpdm -c -d /dev/infiniband/umadX 
   (to discover new SRP target)
   umad0: port 1 of the first HCA
   umad1: port 2 of the first HCA
   umad2: port 1 of the second HCA
3. echo {new target info} > /sys/class/infiniband_srp/srp-mthca0-1/add_target
4. fdisk -l (will show new discovered scsi disks)

Example:
Assume that you use port 1 of first HCA in the system ie. mthca0

[root@lab104 ~]# ibsrpdm -c -d /dev/infiniband/umad0
id_ext=0002c90200226cf4,ioc_guid=0002c90200226cf4,
dgid=fe800000000000000002c90200226cf5,pkey=ffff,service_id=0002c90200226cf4
[root@lab104 ~]# echo id_ext=0002c90200226cf4,ioc_guid=0002c90200226cf4,
dgid=fe800000000000000002c90200226cf5,pkey=ffff,service_id=0002c90200226cf4 >
/sys/class/infiniband_srp/srp-mthca0-1/add_target

OR

+ You can edit /etc/infiniband/openib.conf to load srp driver and srp HA daemon
automatically ie. set SRP_LOAD=yes, and SRPHA_ENABLE=yes
+ To set up and use high availability feature you need dm-multipath driver
and multipath tool
+ Please refer to OFED-1.x SRP's user manual for more in-details instructions
on how-to enable/use HA feature

Here is an example of srp target setup file
--------------------------------------------

#!/bin/sh

modprobe scst scst_threads=1
modprobe scst_vdisk scst_vdisk_ID=100

echo "open vdisk0 /dev/cciss/c1d0 BLOCKIO" > /proc/scsi_tgt/vdisk/vdisk
echo "open vdisk1 /dev/sdb BLOCKIO" > /proc/scsi_tgt/vdisk/vdisk
echo "open vdisk2 /dev/sdc BLOCKIO" > /proc/scsi_tgt/vdisk/vdisk
echo "open vdisk3 /dev/sdd BLOCKIO" > /proc/scsi_tgt/vdisk/vdisk
echo "add vdisk0 0" > /proc/scsi_tgt/groups/Default/devices
echo "add vdisk1 1" > /proc/scsi_tgt/groups/Default/devices
echo "add vdisk2 2" > /proc/scsi_tgt/groups/Default/devices
echo "add vdisk3 3" > /proc/scsi_tgt/groups/Default/devices

modprobe ib_srpt

echo "add "mgmt"" > /proc/scsi_tgt/trace_level
echo "add "mgmt_dbg"" > /proc/scsi_tgt/trace_level
echo "add "out_of_mem"" > /proc/scsi_tgt/trace_level


How-to unload/shutdown
-----------------------

1. Unload ib_srpt
 $ modprobe -r ib_srpt
2. Unload scst and its dev_handlers first
 $ modprobe -r scst_vdisk scst
3. Unload ofed
 $ /etc/rc.d/openibd stop
