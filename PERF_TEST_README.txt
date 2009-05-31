	     Open Fabrics Enterprise Distribution (OFED)
                Performance Tests README for OFED 1.4.1
		  
			  May 2009



===============================================================================
Table of Contents
===============================================================================
1. Overview
2. Notes on Testing Method
3. Test Descriptions
4. Running Tests

===============================================================================
1. Overview
===============================================================================
This is a collection of tests written over uverbs intended for use as a
performance micro-benchmark. As an example, the tests can be used for
hardware or software tuning and/or functional testing.

Please post results and observations to the openib-general mailing list.
See "Contact Us" at http://openib.org/mailman/listinfo/openib-general and
http://www.openib.org.


===============================================================================
2. Notes on Testing Method
===============================================================================
- The benchmark uses the CPU cycle counter to get time stamps without a context
  switch. Some CPU architectures (e.g., Intel's 80486 or older PPC) do NOT have
  such capability.

- The benchmark measures round-trip time but reports half of that as one-way
  latency. This means that it may not be sufficiently accurate for asymmetrical
  configurations.

- Min/Median/Max results are reported.
  The Median (vs average) is less sensitive to extreme scores.
  Typically, the Max value is the first value measured.

- Larger samples only help marginally. The default (1000) is very satisfactory.
  Note that an array of cycles_t (typically an unsigned long) is allocated
  once to collect samples and again to store the difference between them.
  Really big sample sizes (e.g., 1 million) might expose other problems
  with the program.

- The "-H" option will dump the histogram for additional statistical analysis.
  See xgraph, ygraph, r-base (http://www.r-project.org/), pspp, or other 
  statistical math programs.

Architectures tested:	i686, x86_64, ia64, ppc64


===============================================================================
3. Test Descriptions
===============================================================================



The following tests are mainly useful for hardware/software benchmarking.

write_lat.c 	latency test with RDMA write transactions
write_bw.c 	bandwidth test with RDMA write transactions
send_lat.c 	latency test with send transactions
send_bw.c 	bandwidth test with send transactions
read_lat.c 	latency test with RDMA read transactions
read_bw.c 	bandwidth test with RDMA read transactions


Legacy tests: (To be removed in the next release)
rdma_lat.c 	latency test with RDMA write transactions
rdma_bw.c 	streaming bandwidth test with RDMA write transactions

The executable name of each test starts with the general prefix "ib_";
for example, ib_write_lat.


===============================================================================
4. Running Tests
===============================================================================

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


Options in the tests (some options are applicable to part of the tests):
  -p, --port=<port>            listen on/connect to port <port> (default: 18515)
  -c, --connection=<RC/UC>     connection type RC/UC (default RC)
  -m, --mtu=<mtu>              mtu size (default: 1024)
  -d, --ib-dev=<dev>           use IB device <dev> (default: first device found)
  -i, --ib-port=<port>         use port <port> of IB device (default: 1)
  -s, --size=<size>            size of message to exchange (default: 1)
  -a, --all                    run sizes from 2 till 2^23
  -t, --tx-depth=<dep>         size of tx queue (default: 50)
  -n, --iters=<iters>          number of exchanges (at least 100, default: 1000)
  -u, --qp-timeout=<timeout>   QP timeout, timeout value is 4 usec * 2^timeout 
					(default 14\n)
  -g, --post=<num of posts>    number of posts for each qp in the chain
					(default tx_depth). for write_bw test
  -g, --mcg                    send messages to multicast group(only available
					in UD connection. for send tests
  -o, --outs=<num>             num of outstanding read/atom (default 4)
  -q, --qp=<num of qp's>       num of qp's (default 1)
  -r, --rx-depth=<dep>         make rx queue bigger than tx (default 600)
  -I, --inline_size=<size>     max size of message to be sent in inline mode
					(default 400)
  -C, --report-cycles          report times in cpu cycle units
					(default: microseconds)
  -H, --report-histogram       print out all results
					(default: print summary only)
  -U, --report-unsorted        (implies -H) print out unsorted results
					(default: sorted)
  -V, --version                display version number
  -F, --CPU-freq               do not fail even if cpufreq_ondemand module is
					loaded
  -N, --no peak-bw             cancel peak-bw calculation (default with peak-bw)
  -e, --events                 sleep on CQ events (default poll)
  -l, --signal                 signal completion on each msg
  -b, --bidirectional          measure bidirectional bandwidth 
					(default unidirectional)

  *** IMPORTANT NOTE: You need to be running a Subnet Manager on the switch or
		      on one of the nodes in your fabric.

Example:
Run "ib_write_lat -a" on the server side.
Then run "ib_write_lat -a <server IP address>" on the client side.

ib_write_lat will exit on both server and client after printing results.


