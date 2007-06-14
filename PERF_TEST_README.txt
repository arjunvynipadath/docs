	     Open Fabrics Enterprise Distribution (OFED)
                Performance Tests README for OFED 1.2
		  
			  June 2007



===============================================================================
Table of Contents
===============================================================================
1. Overview
2. Notes on Testing Methodology
3. Test Descriptions
4. Running Tests

===============================================================================
1. Overview
===============================================================================
This is a collection of tests written over uverbs intended for use as a
performance micro-benchmark. As an example, the tests can be used for
HW or SW tuning and/or functional testing.

Please post results/observations to the openib-general mailing list.
See "Contact Us" at http://openib.org/mailman/listinfo/openib-general and
http://www.openib.org.


===============================================================================
2. Notes on Testing Methodology
===============================================================================
- The benchmark used the CPU cycle counter to get time stamps without context
  switch.  Some CPU architectures (e.g., Intel's 80486 or older PPC) do NOT
  have such capability.

- The benchmark measures round-trip time but reports half of that as one-way
  latency. This means that it may not be sufficiently accurate for asymmetrical
  configurations.

- Min/Median/Max result is reported.
  The median (vs average) is less sensitive to extreme scores.
  Typically, the "Max" value is the first value measured.

- Larger samples help marginally only. The default (1000) is pretty good.
  Note that an array of cycles_t (typically unsigned long) is allocated
  once to collect samples and again to store the difference between them.
  Really big sample sizes (e.g., 1 million) might expose other problems
  with the program.

- The "-H" option will dump the histogram for additional statistical analysis.
  See xgraph, ygraph, r-base (http://www.r-project.org/), pspp, or other 
  statistical math programs.

Architectures tested:	i686, x86_64, ia64



===============================================================================
4. Test Descriptions
===============================================================================

rdma_lat.c 	latency test with RDMA write transactions
rdma_bw.c 	streaming BW test with RDMA write transactions


The following tests are mainly useful for HW/SW benchmarking.
They are not intended as actual usage examples.

send_lat.c 	latency test with send transactions
send_bw.c 	BW test with send transactions
write_lat.c 	latency test with RDMA write transactions
write_bw.c 	BW test with RDMA write transactions
read_lat.c 	latency test with RDMA read transactions
read_bw.c 	BW test with RDMA read transactions

The executable name of each test starts with the general prefix "ib_",
e.g., ib_write_lat.

Running Tests
-------------

Prerequisites: 
	kernel 2.6
	ib_uverbs (kernel module) matches libibverbs
		("match" means binary compatible, but ideally of the same SVN rev)

Server:		./<test name> <options>
Client:		./<test name> <options> <server IP address>

		o  <server address> is IPv4 or IPv6 address. You can use the IPoIB
                   address if IPoIB is configured.
		o  --help lists the available <options>

  *** IMPORTANT NOTE: The SAME OPTIONS must be passed to both server and client.


Common Options to all tests:
  -p, --port=<port>            listen on/connect to port <port> (default: 18515)
  -m, --mtu=<mtu>              mtu size (default: 1024)
  -d, --ib-dev=<dev>           use IB device <dev> (default: first device found)
  -i, --ib-port=<port>         use port <port> of IB device (default: 1)
  -s, --size=<size>            size of message to exchange (default: 1)
  -a, --all                    run sizes from 2 till 2^23
  -t, --tx-depth=<dep>         size of tx queue (default: 50)
  -n, --iters=<iters>          number of exchanges (at least 100, default: 1000)
  -C, --report-cycles          report times in cpu cycle units
					(default: microseconds)
  -H, --report-histogram       print out all results
					(default: print summary only)
  -U, --report-unsorted        (implies -H) print out unsorted results
					(default: sorted)
  -V, --version                display version number

  *** IMPORTANT NOTE: You need to be running a Subnet Manager on the switch or
		      on one of the nodes in your fabric.

Example:
Run "ib_rdma_lat -C" on the server side.
Then run "ib_rdma_lat -C <server IP address>" on the client.

ib_rdma_lat will exit on both server and client after printing results.

