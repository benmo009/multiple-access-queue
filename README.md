multiple-access-queue

Matlab code to simulate the behavior of multiple sources being served by a
single server.

Two methods for dealing with multiple sources
 - TDMA: Allocate time slots that alternate sources. The server will only serve
   the source that currently has the time slot.
 - FDMA: Split up the queue and server such that each source has a separate
   queue and is being served independently, but at half the rate.

TODO (unordered):
- [x] Compute average delay
- [x] Find best slot duration
- [x] Plot results from both methods to look for differences
- [ ] TDMA where source 1 has priority
- [ ] Limit queue size
- [ ] Use Linear Regression to find optimal lambda/slot duration
- [ ] Slot durations proportional to individual arrival rates
- [ ] Double buffer to limit arrival rates
- [ ] Slot duration as inverse of arrival rate
- [ ] Scale up the number of sources
- [ ] Look at how avg age changes with simulation time
