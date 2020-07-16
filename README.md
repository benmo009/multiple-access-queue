multiple-access-queue
Matlab code to simulate the behavior of multiple sources being served by a
single server.

Two methods for dealing with multiple sources
 - TDMA: Allocate time slots that alternate sources. The server will only serve
   the source that currently has the time slot.
 - FDMA: Split up the queue and server such that each source has a separate
   queue and is being served independently, but at half the rate.

TODO (unordered):
1. proportional slots
2. source 1 can be served anytime
3. compute average delay
4. finite buffer queue
5. slot duration as inverse of arrival rate
6. Find best slot duration
7. Look for differences in the methods
8. See what happens when you scale up the number of sources
9. Look at how avg age changes with simulation time