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
0. Supported distributions: RHEL 5.2/5.3/5.4, SLES 10 sp2/sp3, SLES 11 

NOTES: On distribution default kernels you can run scst_vdisk blockio mode
       to have good performance. You can also run scst_disk ie. scsi pass-thru
       mode; however, you have to compile scst with -DSTRICT_SERIALIZING 
       enabled and this does not yield good performance.
       It is required to recompile the kernel to have good performance with
       scst_disk ie. scsi pass-thru mode

1. Download and install SCST driver (supported version 1.0.1.1)

1a. Download scst-1.0.1.1.tar.gz from this URL
    http://scst.sourceforge.net/downloads.html

1b. untar and install scst-1.0.1.1

    $ tar zxvf scst-1.0.1.1.tar.gz
    $ cd scst-1.0.1.1
  
    THIS STEP IS SPECIFIC FOR SLES 10 sp2 distribution:
    . Save the following patch to /tmp/scst_sles10_sp2.patch

/************************  Start scst_sless_sp2.patch *********************/

diff -Naur scst-1.0.1.1-orig/src/scst_lib.c scst-1.0.1.1/src/scst_lib.c
--- scst-1.0.1.1-orig/src/scst_lib.c	2010-03-05 18:17:22.000000000 -0800
+++ scst-1.0.1.1/src/scst_lib.c	2010-03-05 18:22:50.000000000 -0800
@@ -1680,7 +1680,7 @@
 	return res;
 }
 
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 18)
+#if LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 16)
 static void scst_req_done(struct scsi_cmnd *scsi_cmd)
 {
 	struct scsi_request *req;
@@ -1743,7 +1743,7 @@
 	TRACE_EXIT();
 	return;
 }
-#else /* LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 18) */
+#else /* LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 16) */
 static void scst_send_release(struct scst_device *dev)
 {
 	struct scsi_device *scsi_dev;
@@ -1790,7 +1790,7 @@
 	TRACE_EXIT();
 	return;
 }
-#endif /* LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 18) */
+#endif /* LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 16) */
 
 /* scst_mutex supposed to be held */
 static void scst_clear_reservation(struct scst_tgt_dev *tgt_dev)
@@ -2038,7 +2038,7 @@
 	sBUG_ON(cmd->inc_blocking || cmd->needs_unblocking ||
 		cmd->dec_on_dev_needed);
 
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 18)
+#if LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 16)
 #if defined(CONFIG_SCST_EXTRACHECKS)
 	if (cmd->scsi_req) {
 		PRINT_ERROR("%s: %s", __func__, "Cmd with unfreed "
@@ -2212,7 +2212,7 @@
 	return;
 }
 
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 18)
+#if LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 16)
 int scst_alloc_request(struct scst_cmd *cmd)
 {
 	int res = 0;
diff -Naur scst-1.0.1.1-orig/src/scst_main.c scst-1.0.1.1/src/scst_main.c
--- scst-1.0.1.1-orig/src/scst_main.c	2010-03-05 18:17:22.000000000 -0800
+++ scst-1.0.1.1/src/scst_main.c	2010-03-05 18:34:48.000000000 -0800
@@ -1676,7 +1676,7 @@
 
 	TRACE_ENTRY();
 
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 18)
+#if LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 16)
 	{
 		struct scsi_request *req;
 		BUILD_BUG_ON(SCST_SENSE_BUFFERSIZE !=
diff -Naur scst-1.0.1.1-orig/src/scst_priv.h scst-1.0.1.1/src/scst_priv.h
--- scst-1.0.1.1-orig/src/scst_priv.h	2010-03-05 18:17:22.000000000 -0800
+++ scst-1.0.1.1/src/scst_priv.h	2010-03-05 18:35:07.000000000 -0800
@@ -27,7 +27,7 @@
 #include <scsi/scsi_device.h>
 #include <scsi/scsi_host.h>
 
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 18)
+#if LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 16)
 #include <scsi/scsi_request.h>
 #endif
 
@@ -322,7 +322,7 @@
 void scst_check_retries(struct scst_tgt *tgt);
 void scst_tgt_retry_timer_fn(unsigned long arg);
 
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 18)
+#if LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 16)
 int scst_alloc_request(struct scst_cmd *cmd);
 void scst_release_request(struct scst_cmd *cmd);
 
diff -Naur scst-1.0.1.1-orig/src/scst_targ.c scst-1.0.1.1/src/scst_targ.c
--- scst-1.0.1.1-orig/src/scst_targ.c	2010-03-05 18:17:22.000000000 -0800
+++ scst-1.0.1.1/src/scst_targ.c	2010-03-05 18:36:03.000000000 -0800
@@ -1273,7 +1273,7 @@
 	return context;
 }
 
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 18)
+#if LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 16)
 static inline struct scst_cmd *scst_get_cmd(struct scsi_cmnd *scsi_cmd,
 					    struct scsi_request **req)
 {
@@ -1325,7 +1325,7 @@
 	TRACE_EXIT();
 	return;
 }
-#else /* LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 18) */
+#else /* LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 16) */
 static void scst_cmd_done(void *data, char *sense, int result, int resid)
 {
 	struct scst_cmd *cmd;
@@ -1347,7 +1347,7 @@
 	TRACE_EXIT();
 	return;
 }
-#endif /* LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 18) */
+#endif /* LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 16) */
 
 static void scst_cmd_done_local(struct scst_cmd *cmd, int next_state,
 	enum scst_exec_context pref_context)
@@ -1881,7 +1881,7 @@
 static int scst_do_real_exec(struct scst_cmd *cmd)
 {
 	int res = SCST_EXEC_NOT_COMPLETED;
-#if LINUX_VERSION_CODE >= KERNEL_VERSION(2, 6, 18)
+#if LINUX_VERSION_CODE >= KERNEL_VERSION(2, 6, 16)
 	int rc;
 #endif
 	bool atomic = scst_cmd_atomic(cmd);
@@ -1948,7 +1948,7 @@
 	}
 #endif
 
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 18)
+#if LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 16)
 	if (unlikely(scst_alloc_request(cmd) != 0)) {
 		if (atomic) {
 			res = SCST_EXEC_NEED_THREAD;
@@ -1999,7 +1999,7 @@
 	scst_set_cmd_error(cmd, SCST_LOAD_SENSE(scst_sense_hardw_error));
 	goto out_done;
 
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 18)
+#if LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 16)
 out_busy:
 	scst_set_busy(cmd);
 	/* go through */

/************************  End scst_sless10_sp2.patch ***********************/

    . $ patch -p1 < /tmp/scst_sles10_sp2.patch


    For all distributions:

    $ make && make install

1c. Creating file /tmp/scst.patch.

    NOTES: FOR SLES 11 distribution, skip this step and go directly to step (2)

    . Other distributions please save the following patch to /tmp/scst.patch

/************************  Start scst.patch *********************/
diff -Naur scst/scst.h scst.wk/scst.h
--- scst/scst.h	2009-08-14 17:09:47.000000000 -0700
+++ scst.wk/scst.h	2009-08-14 17:01:28.000000000 -0700
@@ -2581,7 +2581,7 @@
 void scst_aen_done(struct scst_aen *aen);
 
 #if LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 24)
-
+#ifndef RHEL_RELEASE_CODE
 static inline struct page *sg_page(struct scatterlist *sg)
 {
 	return sg->page;
@@ -2610,6 +2610,7 @@
 	sg->length = len;
 }
 
+#endif
 #endif /* LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 24) */
 
 static inline void sg_clear(struct scatterlist *sg)
/************************  End scst.patch *********************/


1d. patch scst.h header file with /tmp/scst.patch

    $ cd /usr/local/include/scst
    $ patch -p1 < /tmp/scst.patch


2. Download/install OFED-1.5.1 package - SRP target is part of OFED package

NOTES: if your system already have OFED stack installed, you need to remove
       the previous built of kernel-ib RPMs and reinstall
      
   $ cd ~/OFED-1.5.1
   $ rm RPMS/*/*/kernel-ib*
   $ ./install.pl -c ofed.conf

   Make sure that srpt=y in the ofed.conf

2a. download OFED packages from this URL
    http://www.openfabrics.org/downloads/OFED/OFED-1.5.1/

2b. install OFED - remember to choose srpt=y

   $ cd ~/OFED-1.5.1
   $ ./install.pl


How-to run
-----------

A. On srp target machine

A1. Please refer to SCST's README for loading scst driver and its dev_handlers
    drivers (scst_disk, scst_vdisk block or file IO mode, nullio, ...)
    SCST's README locates in ~/scst-1.0.1.1/ directory

NOTES: In any mode you always need to have lun 0 in any group's device list
       Then you can have any lun number following lun 0 (it does not required
       have lun number in order except that the first lun is always 0)

       Setting SRPT_LOAD=yes in /etc/infiniband/openib.conf is not good enough
       It only load ib_srpt module and does not load scst and its dev_handlers

       SCST's scst_disk module (pass-thru mode) does not run on default
       distribution kernels (kernels come with RHEL 5.2/5.3/5.4 & SLES 11)
       because it requires to patch and recompile the kernel. It can only
       run with vanilla kernels.
 
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

A2. modprobe ib_srpt


B. On initiator machines you can manualy do the following steps:

B1. modprobe ib_srp
B2. ipsrpdm -c -d /dev/infiniband/umadX 
   (to discover new SRP target)
    umad0: port 1 of the first HCA
    umad1: port 2 of the first HCA
    umad2: port 1 of the second HCA
B3. echo {new target info} > /sys/class/infiniband_srp/srp-mthca0-1/add_target
B4. fdisk -l (will show new discovered scsi disks)

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

*********************** srpt.sh *****************************************
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

*********************** End srpt.sh **************************************


How-to unload/shutdown
-----------------------

1. Unload ib_srpt
 $ modprobe -r ib_srpt
2. Unload scst and its dev_handlers
 $ modprobe -r scst_vdisk scst
3. Unload ofed
 $ /etc/rc.d/openibd stop
