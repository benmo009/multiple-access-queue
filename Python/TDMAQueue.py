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

        # Make time array
        self._t = np.arange(0, tFinal + tStep, tStep)

        # Generate array of packet arrival times and store the number of packets
        self._numPackets = np.zeros((self._numSources,), dtype=int)
        self._timeArrived = np.array([])
        self._timeArrived.shape = (2,0)
        self._queue = []

        self._numPacketServed = np.zeros((self._numSources,), dtype=int)

        for i in range(self._numSources):
            # Generate arrival times for each source
            transmissions = GenerateTransmissions(self._t, self._lambda[i])
            self._numPackets[i] = len(transmissions)  # Count number of packets

            # Make 2 x numPackets array with first row as source number and
            # second row as time of arrival
            arrival = np.zeros((2, self._numPackets[i]))
            arrival[0,:] = i * np.ones_like(transmissions)
            arrival[1,:] = transmissions

            # Add arrival to end of timeAppend
            self._timeArrived = np.append(self._timeArrived, arrival, axis=1)

            # Initialize the queue for each source
            self._queue.append(deque())
        
        # Sort the arrival times from first to last
        idx = np.argsort(self._timeArrived[1,:])
        self._timeArrived = self._timeArrived[:,idx]
        
        # Initialize age array with initial age of 0
        self._age = self._t * np.ones((self._numSources, len(self._t)))

        # Calculate the Age
        # Step through important events
        #   - Packet Arrivals
        #   - Packet finished being served
        #   - Slot changes (only when the server is idle)

        self._toServe = 0  # Index of the next packet that has to be served
        self._isPacket = False  # Flag to tell if the current timestep is a packet arrival
        self._serving = False  # Flag to tell that server is busy

        # Set current time to first packet arrival
        currentTime, packet = self.grabNextPacket()

        # Initialize variables that will be used later
        self._lastPacketServed = -1
        slotTransition = 0
        serveSource = 0
        packetsServed = np.zeros((self._numSources,))

        while True:
            # Only need to calculate slot properties when entering a new slot
            if currentTime >= slotTransition:
                serveSource, slotTransition = self.CheckSlot(currentTime)


            if currentTime > self._lastPacketServed:
                # The server has been idle, either a packet just arrived, its a
                # slot change, or both
                if self._isPacket:  # Packet arrival
                    # Put the packet into the queue. In the case a packet arrives at
                    # the same time as a slot transition, there may be an older
                    # packet in the queue that has to be served first
                    source = self.AddToQueue(packet)

                    # Check if its in the right slot
                    if serveSource == source and not self._serving:
                        # Slot matches the source, generate a service time
                        self.ServePacket(source, currentTime, slotTransition, tStep)
                    
                else:  # Slot transition
                    # Check queue for a packet to serve
                    if not self._serving and len(self._queue[serveSource]) != 0:
                        # There is a packet in queue, generate service time
                        self.ServePacket(serveSource, currentTime, slotTransition, tStep)

            elif currentTime == self._lastPacketServed:
                # Server just finished, update the age
                source = int(self._lastPacket[0])
                packetAge = currentTime - self._lastPacket[1]
                packetsServed[source] += 1

                # add 1 to count how many packets were served for that user
                # TODO:
                # print('source {} is served'.format(source))
                self._numPacketServed[source] += 1

                # Find index in t that corresponds to current time
                ageIndex = currentTime / tStep
                ageIndex = int(round(ageIndex))  

                # Compute the decrease of the age after serving a packet
                reduceAge = self._age[source, ageIndex] - packetAge
                self._age[source, ageIndex::] -= reduceAge
                self._serving = False

                # Check if a packet also arrived at this time
                if self._isPacket:
                    source = self.AddToQueue(packet)
                # Check if there are any packets in the queue to serve               
                if len(self._queue[serveSource]) != 0:
                    self.ServePacket(serveSource, currentTime, slotTransition, tStep)

            elif currentTime < self._lastPacketServed:
                # Packet arrived while the server is busy
                if self._isPacket:
                    # Put the packet in the queue
                    source = self.AddToQueue(packet)
                
            
            # Figure out the next time step to go to
            if self._toServe >= (self._timeArrived.shape)[1]:
                # No more packet arrivals, but theres packets in queue
                if currentTime >= self._lastPacketServed:
                    # No packets being served, can only go to slot transitions
                    currentTime = slotTransition
                else:
                    # Go to when the current packet being served is done
                    currentTime = self._lastPacketServed
                self._isPacket = False  # Not a packet arrival
            else:
                if currentTime >= self._lastPacketServed:
                    # Go to whichever happens first, arrival or slot transition
                    currentTime = min(slotTransition, self._timeArrived[1,self._toServe])
                else:
                    # Go to whichever happens first, arrival or server finished
                    currentTime = min(self._lastPacketServed, self._timeArrived[1,self._toServe])
                
                # If the next timestep is a packet arrival, record the packet
                if currentTime == self._timeArrived[1, self._toServe]:
                    currentTime, packet = self.grabNextPacket()
                else:
                    self._isPacket = False  # Not a packet

            # If its a slot transition, the server stops working
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

            # End the simulation at tFinal or there are no more packets
            if stopLoop or currentTime >= tFinal:
                break
        
        # Calculate the averages
        self._avgAge = np.mean(self._age, axis=1)
        self.percentServed = packetsServed / self._numPackets


    # Function to generate a service time and checks if the packet can be served       
    def ServePacket(self, source, currentTime, slotTransition, dt):
        # Generate the service time
        S = GenerateServiceTime(self._mu, dt, 1)
        S = S[0]
        self._serving = True

        # Check to see if its small enough
        if S < slotTransition - currentTime:
            # Packet can be served within its slot
            source = int(source)
            self._lastPacket = self._queue[source].popleft()
            self._lastPacketServed = currentTime + S


    # Adds a packet to the queue and returns the source number
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

    # Function to check what slot the program is currently in
    def CheckSlot(self, currentTime):
        totalSlot = np.sum(self._slotWidth)  # Entire width of the slot
        slotNumber = currentTime // totalSlot  # Number of full slots 
        relativeTime = currentTime % totalSlot  # How far into current slot

        serveSource = -1
        while serveSource < self._numSources:
            serveSource += 1
            relativeTime -= self._slotWidth[serveSource]
            # If its 0 or close to 0, go to next source
            if abs(relativeTime) < 1e-6:  
                continue
            
            # serve source is the first one that results in a negative
            if relativeTime < 0:
                break
        
        # Added to remove floating point errors
        difference = (currentTime / totalSlot) - slotNumber
        if abs(difference - 1) < 1e-6:
            slotNumber = slotNumber + 1
        
        # Compute the time until the next slot transition
        if serveSource == self._numSources - 1:
            slotTransition = (slotNumber + 1) * totalSlot
        else:
            slotTransition = slotNumber * totalSlot
            i = 0
            while i <= serveSource:
                slotTransition += self._slotWidth[i]
                i += 1
        
        return serveSource, slotTransition
    

    # Get the average age of the simulation
    def getAvgAge(self):
        return self._avgAge

    def CompletionPercentage(self):
        return self._numPacketServed / self._numPackets
    
    def plotJobCompletion(self):
        '''
        This method here helps to plot percentage of job done
        '''
        fig,axs = plt.subplots(self._numSources,1)
        for i in range(self._numSources):
            # Plot the age vs time
            axs[i].plot(self._t, self._age[i,:], label="Age")

            # Plot the average age
            avgAgePlt = avgAge[i] * np.ones(np.size(self._t))
            axs[i].plot(self._t, avgAgePlt,
                        label="Average Age = {:.2f}".format(avgAge[i]))
            axs[i].set_xlabel("Time (s)")
            axs[i].set_ylabel("Age (s)")
            axs[i].legend()

        plt.show()
        return 

if __name__ == "__main__":
    tFinal = 1800
    dt = 0.1
    numSources = 2
    arrivalRate = [0.009, 0.009]
    mu = 1/30

    b = 0.5
    T = 4/mu
    slotWidth = [b * T, (1-b)*T]

    numSimulations = 10

    avgAge = np.zeros((numSources,))
    packetsServed = np.zeros((numSources,))
    avgNumPackets = np.zeros((numSources,))
    start_time = time.time()
    for i in range(numSimulations):
        print("Simulation {:d} out of {:d}".format(
            i, numSimulations), end="\r")
        tdma = TDMAQueue(tFinal, dt, slotWidth, arrivalRate, mu)
        avgAge += tdma.getAvgAge()
        packetsServed += tdma.percentServed
        avgNumPackets += tdma._numPackets

    print("Elapsed Time: {:f}s".format(time.time() - start_time))
    avgAge = avgAge / numSimulations
    packetsServed = packetsServed / numSimulations
    avgNumPackets = avgNumPackets / numSimulations
    print(avgAge)
    print(packetsServed)
    print(avgNumPackets)

    tdma = TDMAQueue(tFinal, dt, slotWidth, arrivalRate, mu)
    print(tdma._numPackets)
    print(tdma.percentServed)
    tdma.plotAge()
    

