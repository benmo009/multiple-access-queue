from collections import deque
from operator import truediv
import numpy as np
import matplotlib.pyplot as plt 
import math
from helper import *
import time

class TDMAQueue:
    def __init__(self, tFinal, tStep, slotWidth, arrivalRate, serviceRate):
        self._numSources = len(slotWidth)
        self._slotWidth = slotWidth
        self._lambda = arrivalRate
        self._mu = serviceRate

        self._t = np.arange(0, tFinal + tStep, tStep)

        # Decimal places to round to based on step size
        precision = int(-math.log10(tStep))

        # Generate array of packet arrival times and store the number of packets
        self._numPackets = np.zeros((self._numSources,), dtype=int)
        self._timeArrived = np.array([])
        self._timeArrived.shape = (2,0)

        self._queue = []

        for i in range(self._numSources):
            transmissions = GenerateTransmissions(self._t, self._lambda[i])
            self._numPackets[i] = len(transmissions)
            arrival = np.zeros((2, self._numPackets[i]))
            arrival[0,:] = i * np.ones_like(transmissions)
            arrival[1,:] = transmissions
            self._timeArrived = np.append(self._timeArrived, arrival, axis=1)

            # Initialize the queue for each source
            self._queue.append(deque())
        
        # Sor the arrival times based on times
        idx = np.argsort(self._timeArrived[1,:])
        self._timeArrived = self._timeArrived[:,idx]
        
        # Initialize age array with initial age of 0
        self._age = self._t * np.ones((self._numSources, len(self._t)))

        # Calculate the Age
        # Step through important events
        #   - Packet Arrivals
        #   - Packet finished being served
        #   - Slot changes (only when the server is idle)

        # Index of the next packet that has to be served
        self._toServe = 0
        self._isPacket = False
        self._serving = False

        currentTime, packet = self.grabNextPacket()

        # Timestamp of when the most recent packet was served.
        self._lastPacketServed = -1
        slotTransition = 0;
        serveSource = 0;

        while True:
            # End the simulation once it reaches tFinal
            if currentTime > tFinal:
                break
            
            # Only need to calculate slot properties when entering a new slot
            if currentTime >= slotTransition:
                serveSource, slotTransition = self.CheckSlot(currentTime, tStep)

            
            if currentTime > self._lastPacketServed:
                # The server has been idle, either a packet just arrived, its a
                # slot change, or both

                if self._isPacket:  # Packet arrival
                    # Put the packet into the queue. In the case a packet arrives at
                    # the same time as a slot transision, there may be an older
                    # packet in the queue that has to be served first
                    source = self.AddToQueue(packet)

                    # Check if its in the right slot
                    if serveSource == source and not self._serving:
                        # Slot matches the source, generate a service time
                        self.ServePacket(source, currentTime, slotTransition, tStep)
                    
                
                else:  # Slot transision
                    # Check queue for a packet to serve
                    if not self._serving and len(self._queue[serveSource]) != 0:
                        # There is a packet in queue, generate service time
                        self.ServePacket(serveSource, currentTime, slotTransition, tStep)

            elif currentTime == self._lastPacketServed:
                # Server just finished, update the age
                source = int(self._lastPacket[0])
                packetAge = currentTime - self._lastPacket[1]
                ageIndex = currentTime / tStep
                ageIndex = int(round(ageIndex))

                reduceAge = self._age[source, ageIndex] - packetAge
                self._age[source, ageIndex::] -= reduceAge
                self._serving = False

                if self._isPacket:
                    source = self.AddToQueue(packet)
                
                if len(self._queue[serveSource]) != 0:
                    self.ServePacket(serveSource, currentTime, slotTransition, tStep)

            elif currentTime < self._lastPacketServed:
                # Packet arrived while the server is busy
                if self._isPacket:
                    source = self.AddToQueue(packet)
                
            
            if self._toServe >= (self._timeArrived.shape)[1]:
                # No more packet arrivals
                if currentTime >= self._lastPacketServed:
                    currentTime = slotTransition
                else:
                    currentTime = self._lastPacketServed
                self._isPacket = False
            else:
                if currentTime >= self._lastPacketServed:
                    currentTime = min(slotTransition, self._timeArrived[1,self._toServe])
                else:
                    currentTime = min(self._lastPacketServed, self._timeArrived[1,self._toServe])
                
                if currentTime == self._timeArrived[1, self._toServe]:
                    currentTime, packet = self.grabNextPacket()
                else:
                    self._isPacket = False

            if currentTime == slotTransition:
                self._serving = False
            
            # Check if the loop needs to end
            stopLoop = self._toServe >= (self._timeArrived.shape)[1]  # No more packets
            stopLoop = stopLoop and (currentTime > self._lastPacketServed)  #  Last packet was served
            
            if stopLoop:
                # Check if each queue is empty only if stopLoop is True
                for i in range(self._numSources):
                    if len(self._queue[i]) > 0:
                        stopLoop = False

            # End the simulation
            if stopLoop or currentTime > tFinal:
                break
        
        # Calculate the averages
        self._avgAge = np.mean(self._age, axis=1)
                        
    def ServePacket(self, source, currentTime, slotTransition, dt):
        source = int(source)
        S = GenerateServiceTime(self._mu, dt, 1)
        S = S[0]
        self._serving = True

        if S < slotTransition - currentTime:
            self._lastPacket = self._queue[source].popleft()
            self._lastPacketServed = currentTime + S


    def AddToQueue(self, packet):
        source = int(packet[0])
        self._queue[source].append(packet)
        return source


    # Returns the next packet to serve and the time it arrives
    def grabNextPacket(self):
        currentTime = self._timeArrived[1,self._toServe]
        packet = self._timeArrived[:, self._toServe]
        self._toServe += 1

        self._isPacket = True
        return currentTime, packet

    def CheckSlot(self, currentTime, precision):
        totalSlot = np.sum(self._slotWidth)
        slotNumber = currentTime // totalSlot
        relativeTime = currentTime % totalSlot

        serveSource = -1
        while serveSource < self._numSources:
            serveSource += 1
            relativeTime -= self._slotWidth[serveSource]
            if abs(relativeTime) < precision:
                continue

            if relativeTime < 0:
                break
        
            
        
        difference = (currentTime / totalSlot) - slotNumber
        if abs(difference - 1) < 1e-6:
            slotNumber = slotNumber + 1
        
        if serveSource == self._numSources - 1:
            slotTransition = (slotNumber + 1) * totalSlot
        else:
            slotTransition = slotNumber * totalSlot
            i = 0
            while i <= serveSource:
                slotTransition += self._slotWidth[i]
                i += 1
        
        return serveSource, slotTransition
    
    def getAvgAge(self):
        return self._avgAge

    def plotAge(self):
        pass

if __name__ == "__main__":
    tFinal = 1800
    dt = 0.1
    numSources = 2
    arrivalRate = [1/60, 1/45]
    mu = 1/30

    b = 0.5
    slotWidth = [b * 5/mu, (1-b)*5/mu]

    numSimulations = 1000

    avgAge = np.zeros((numSources,))
    start_time = time.time()
    for i in range(numSimulations):
        print("Simulation {:d} out of {:d}".format(
            i, numSimulations), end="\r")
        tdma = TDMAQueue(tFinal, dt, slotWidth, arrivalRate, mu)
        avgAge += tdma.getAvgAge()

    print("Elapsed Time: {:.f}s".format(time.time() - start_time))
    avgAge = avgAge / numSimulations
    print(avgAge)


