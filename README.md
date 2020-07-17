multiple-access-queue
Matlab code to simulate the behavior of multiple sources being served by a
single server.

Two methods for dealing with multiple sources
 - TDMA: Allocate time slots that alternate sources. The server will only serve
   the source that currently has the time slot.
 - FDMA: Split up the queue and server such that each source has a separate
   queue and is being served independently, but at half the rate.

TODO (unordered):
- [ ] proportional slots

- [ ] source 1 can be served anytime / priority -> possible for TDMA
- [ ] limiting the source size -> possible for FDMA
- [ ] 3 users

- [ ] metric: avergae wait time? elapsed time? avergae age? average wait?
- [ ] metric: each packets waiting in the queue
- [ ] metric: how long packet stay in the queue

- [ ] linear regression find optimal slot duration and optimal lambda ?

        - age should be at its minimum [prediction curve, how does the average data change]

- [ ] two buffer system (?) : TDMA -> 2 sources are sending in



--> 

- [x] compute average delay
- [ ] finite buffer queue
- [ ] slot duration as inverse of arrival rate
- [x] Find best slot duration
- [ ] Look for differences in the methods
- [ ] See what happens when you scale up the number of sources
- [ ] Look at how avg age changes with simulation time
- [ ] double buffer to limit arrival rates