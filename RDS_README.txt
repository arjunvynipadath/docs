RDS(7)			   Linux Programmer’s Manual			RDS(7)



NAME
       rds - RDS socket API

SYNOPSIS
       #include <sys/socket.h>
       #include <netinet/in.h>
       #define RDS_CANCEL_SENT_TO    1
       #define RDS_SNDBUF  2

       rds_socket = socket(pf_rds, SOCK_SEQPACKET, 0);

DESCRIPTION
       This is an implementation of the RDS socket API.	 It provides reliable,
       in-order datagram delivery between sockets over	a  variety  of	trans-
       ports.


SOCKET CREATION
       RDS is still in development and as such does not have a reserved proto-
       col family constant.  Applications must read the string	representation
       of  the	protocol  family  value	 from the pf_rds sysctl parameter file
       described below.


BINDING
       A new RDS socket has no local address when it is	 first	returned  from
       socket(2).   It	must  be  bound	 to a local address by calling bind(2)
       before any messages can be sent or received.  RDS sockets do  not  sup-
       port connecting to remote endpoints with connect(2).  An RDS socket can
       only be bound to one address and only one socket	 can  be  bound	 to  a
       given  address.	If no port is specified in the binding address then an
       unbound port is selected at random.

       RDS has the notion of associating a socket to an underlying  transport.
       The  transport  for a socket is decided based on the local address that
       is bound.  From that point on the socket can  only  reach  destinations
       which are available through the this transport.


MESSAGE TRANSMISSION
       Messages	 may  be  sent	using sendmsg(2) once the RDS socket is bound.
       Message length cannot exceed 4 gigabytes as the wire protocol  uses  an
       unsigned 32 bit integer to express the message length.

       RDS does not support out of band data.

       A  successful sendmsg(2) call puts the message in the socket’s transmit
       queue where it will remain until either	the  destination  acknowledges
       that the message is no longer in the network or the application removes
       the message from the send queue.	 Messages are removed  from  the  send
       queue with the RDS_CANCEL_SENT_TO socket option described below.

       A  given RDS socket has limited transmit buffer space for each destina-
       tion address.  While a message is in the	 transmit  queue  its  payload
       bytes  are accounted for.  If an attempt is made to send a message to a
       destination whose buffer does not have room for the  new	 message  then
       the sender will block or EAGAIN will be returned depending on MSG_DONT-
       WAIT message flag.  The SO_SNDTIMEO socket option dictates how long the
       send will wait for buffer.

       The  size of the send buffer for a given destination is governed by the
       RDS_SNDBUF socket option and sysctl parameters  described  below.   The
       SO_SNDBUF socket option is ignored.

       A  message sent with no payload bytes will not consume any space in the
       destination’s send buffer but will result in a message receipt  on  the
       destination.   The  receiver  will not get any payload data but will be
       able to see the sender’s address.


MESSAGE RECEIPT
       Messages may be received with recvmsg(2) on an RDS socket  once	it  is
       bound to a source address.  The MSG_DONTWAIT message flag determines if
       the receive will block waiting for message arrival and the  SO_RCVTIMEO
       socket  option  dictates	 how long the receive will wait.  The MSG_PEEK
       flag stops the message from being removed from the receive queue.

       The memory consumed by messages waiting for delivery does not limit the
       number  of  messages  that  can be queued for receive.  Senders must be
       careful not to overwhelm the receiver  by  sizing  their	 send  buffers
       appropriately.  The SO_RCVBUF socket option is ignored.

       If the length of the message exceeds the size of the buffer provided to
       recvmsg(2) then the remainder of the bytes in the message are discarded
       and the MSG_TRUNC flag is set in the msg_flags field.  In this truncat-
       ing case recvmsg(2) will still return the number of bytes  copied,  not
       the length of entire messge.  If MSG_TRUNC is set in the flags argument
       to recvmsg(2) then it will return the number of	bytes  in  the	entire
       message.	  Thus	one  can  examine  the size of the next message in the
       receive queue without incuring a copying overhead by providing  a  zero
       length buffer and setting MSG_PEEK and MSG_TRUNC in the flags argument.

       The sending address of a zero-length message will still be provided  in
       the msg_name field.


POLL
       RDS supports a limited poll(2) API.  POLLIN is returned when there is a
       message waiting in the  socket’s	 receive  queue.   POLLOUT  is	always
       returned,  it  is  up to the application to back off if poll is used to
       trigger sends.


RELIABILITY
       If sendmsg(2) succeeds then RDS guarantees that	the  message  will  be
       visible	to  recvmsg(2) on a socket bound to the destination address as
       long as that destination socket remains open.

       If there is no socket bound on the  destination	than  the  message  is
       silently	 dropped.   If	the sending RDS can’t be sure that there is no
       socket bound then it will try to send the message indefinitely until it
       can be sure or the sent message is canceled.

       If  a socket is closed then all pending sent messages on the socket are
       canceled and may or may not be seen by the receiver.

       The RDS_CANCEL_SENT_TO socket option can be used to cancel all  pending
       messages to a given destination.

       If  a  receiving socket is closed with pending messages then the sender
       considers those messages as  having  left  the  network	and  will  not
       retransmit them.

       A  message will only be seen by recvmsg(2) without MSG_PEEK once.  Once
       the message has been delivered it is removed from the sending  socket’s
       transmit queue.

       All  messages sent from the same socket to the same destination will be
       delivered in the order they’re  sent.   Messages	 sent  from  different
       sockets, or to different destinations, may be delivered in any order.


ADDRESS FORMATS
       RDS  uses  sockaddr_in  as  described  in  ip(7) to describe addresses,
       including setting sin_family to AF_INET .  RDS  only  supports  unicast
       communication -- broadcast and multicast addresses are not supported.


SOCKET OPTIONS
       The  following  RDS  specific  socket  options  are  available when the
       sol_rds sysctl parameter is read and used as the	 level	with  getsock-
       opt(2) or setsockopt(2)


       RDS_SNDBUF
	      This  determines the total number of bytes that may be queued in
	      the transmit queue for a given destination.  Changing this  does
	      not  have	 an  immediate	effect	on pending transmission, it is
	      intended to be set early and infrequently.  The  default,	 mini-
	      mum,  and maximum values of this option are governed by the snd-
	      buf_* sysctl parameters described below.


       RDS_CANCEL_SENT_TO
	      Setting this option is used to cancel messages sent  to  a  spe-
	      cific  destination.   The	 destination  address  is specified by
	      passing a sockaddr pointer and length as the optval  and	optlen
	      arguments	 to  setsockopt(2)  .  Errors are only returned if the
	      socket is not yet bound or if sockaddr is malformed.   No	 error
	      is returned if there are no messages queued for the given desti-
	      nation.  getsockopt(2) is not supported on this option and  will
	      return ENOPROTOOPT .


SYSCTL
       These   parameteres  may	 only  be  accessed  through  their  files  in
       /proc/sys/net/rds/ . Access through sysctl(2) is not supported.


       pf_rds This file contains the string  representation  of	 the  protocol
	      family  constant passed to socket(2) to create a new RDS socket.


       sol_rds
	      This file contains the string representation of the socket level
	      parameter	 that  is passed to getsockopt(2) and setsockopt(2) to
	      manipulate RDS socket options.


       sndbuf_default_bytes
	      This parameter determines the initial value of RDS_SNDBUF	 on  a
	      newly  created socket.  New values written to this file must not
	      be  less	than  sndbuf_min_bytes	and  not  greater  than	  snd-
	      buf_max_bytes

       sndbuf_max_bytes
	      This   parameter	determines  the	 maximum  value	 of  the  snd-
	      buf_default_bytes and sndbuf_min_bytes parameters.  It  can  not
	      be  greater  than the number of bytes represented in an unsigned
	      32bit integer (4 gigabytes).

       sndbuf_min_bytes
	      This  parameter  determines  the	minimum	 value	of  the	  snd-
	      buf_default_bytes	 and  sndbuf_max_bytes parameters.  It can not
	      be less than 0.

       reconnect_delay_min_ms
	      This parameter determines the minimum amount of time  that  will
	      pass  before  attempting	to  reconnect to a peer after a failed
	      connect attempt.

       reconnect_delay_max_ms
	      This parameter determines the maximum amount of time  that  will
	      seperate	reconnect  attempts.   The  reconnect delay approaches
	      this by exponentially increasing the minimum delay.


SEE ALSO
       socket(2), bind(2), sendmsg(2),	recvmsg(2),  getsockopt(2).   setsock-
       opt(2).



Linux Man Page								RDS(7)
