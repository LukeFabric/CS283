1. How does the remote client determine when a command's output is fully received from the server, and what techniques can be used to handle partial reads or ensure complete message transmission?

The remote client determines when a command's output is fully received from the server when it receives the EOF character. The techniques that can be used to handdle partial reads are to loop until the client receives the EOF character, then it can stop listening and prepare to send another transmission to the server. This ensures that the client receives the entire output from the server, and it lets it know when it can start sending commands again.

2. This week's lecture on TCP explains that it is a reliable stream protocol rather than a message-oriented one. Since TCP does not preserve message boundaries, how should a networked shell protocol define and detect the beginning and end of a command sent over a TCP connection? What challenges arise if this is not handled correctly?

The networked shell protocol should use techniques like implementing headers that carry additional metadata, such as message length and if more packets are coming to transmit data, which come ahead of the message payload. The challenges are if the client or server does not understand the headers, leading to improper understanding of the packet and it failing to process commands or executing commands that are not complete.

3. Describe the general differences between stateful and stateless protocols.

A stateful protocol maintains communication and a status between a client and a host, with the host knowing what is on the other end and remembering what happened to each packet so it can guarantee delivery to the client. Stateless protocols do not maintain this communication between the client and host, with stateless protocols not able to guarantee that all the data will reach the client. This gives them less overhead, making them faster, but that also makes them more susceptible to failure.

4. Our lecture this week stated that UDP is "unreliable". If that is the case, why would we ever use it?

We use UDP because in situations where speed is the highest priority, it makes more sense to use a protocol with less overhead like UDP. Since it doesn't have to establish and maintain connections, as well as guaranteee delivery, it can just send data quickly and provide more speed.


5. What interface/abstraction is provided by the operating system to enable applications to use network communications?

The interface provided by the operating system to enable applications to use network communications is the sockets api,
which is used to establish and maintain connections.
