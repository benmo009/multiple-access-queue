import numpy as np
import matplotlib.pyplot as plt 
from helper import GenerateTransmissions, GenerateServiceTime
import math

class AoIQueue:
    def __init__(self, tFinal, tStep, arrivalRate, serviceRate):
        # Initialize simulation parameters
        self._tFinal = tFinal  # Total simulation time
        self._tStep = tStep  # Simulation step size
        self._lambda = arrivalRate  # Packet Arrival Rate (packets/second)
        self._mu = serviceRate  # Service Rate (packets served/second)

        # Decimal places to round to based on step size
        precision = int(-math.log10(self._tStep))

        # Make time array
        padding = 5 * 1/self._lambda  # Add some time to the begining to average 10 packet arrivals 
        self._t = np.arange(0, padding + self._tFinal + self._tStep, self._tStep)
        start_time = padding
        end_time = max(self._t) #- padding

        # Generate array of packet arrival times and store the number of packets
        self._timeArrived = GenerateTransmissions(self._t, self._lambda)
          

        # Generate array of service times
        array_size = self._timeArrived.shape
        self._serviceTimes = GenerateServiceTime(
            self._mu, self._tStep,  array_size)

        # Make array for wait times in queue. The first value is 0
        self._delayTime = np.zeros(array_size)
        self._queueWait = np.zeros(array_size)
        # Make array to keep track of when packets finish being served
        self._timeFinished = np.zeros(array_size)
        # Packet age array to keep track of the age of each packet
        self._packetAge = np.zeros(array_size)

        # Initialize age array with initial age of 0
        self._age = np.copy(self._t)
        numServed = 0  # Counter for number of packets served

        # Go through each packet and calculate when they get served
        for i in range(len(self._timeArrived)):
            # Calculate when the first packet gets served
            if i == 0:
                # First packet that arrives is only as old as its service time
                firstPacketServed = self._timeArrived[0] + self._serviceTimes[0]
                self._timeFinished[0] = firstPacketServed
                self._packetAge[0] = self._serviceTimes[0]

            # Calculate the age of the rest of the packets
            else:
                if self._timeArrived[i] >= self._timeFinished[i-1]:
                    # Current packet arrived after last packed was finished serving
                    self._queueWait[i] = 0  # It doesn't have to wait

                else:
                    # Packet arrived before last packet is finished serving
                    self._queueWait[i] = self._timeFinished[i-1] - self._timeArrived[i]

                # Calculate when current packet gets served
                packetServed = self._timeArrived[i] + self._queueWait[i] + self._serviceTimes[i]
                self._timeFinished[i] = packetServed

                currentPacketAge = packetServed - self._timeArrived[i]
                self._packetAge[i] = currentPacketAge

            # Update the age for each packet
        
            # Get the time that current packet finished serving
            currentTime = self._timeFinished[i]  
            currentTime = round(currentTime, precision)

            # Cutoff the simulation at tFinal
            if currentTime > end_time:
                break

            # Find the corresponding index in the age array
            ageIndex = currentTime / self._tStep
            ageIndex = int(round(ageIndex))

            # Check for rounding errors
            if abs(self._t[ageIndex] - currentTime) > 1e-5:
                print(currentTime, end=' ')
                print(ageIndex, end=' ')
                print(self._t[ageIndex])
            
            # Decrease the age to the age of the packet that just got served
            reduceAge = self._age[ageIndex] - self._packetAge[i]
            self._age[ageIndex:] -= reduceAge

            if currentTime >= start_time and currentTime <= end_time:
                numServed += 1


        # Cutoff the padding at the beginning
        self._t = np.arange(0, self._tFinal+self._tStep, self._tStep)
        start_idx = int( start_time / self._tStep )
        end_idx = int( end_time / self._tStep ) + 1
        self._age = self._age[start_idx:end_idx] 


        # Calculate the averages
        self.avgAge = np.mean(self._age)
        self.avgQueueWait = np.mean(self._queueWait) 

        self._delayTime = self._queueWait + self._serviceTimes
        self.avgDelay = np.mean(self._delayTime)

        # Expected number of packets for the time window
        packets_expected = self._tFinal * self._lambda
        self.percentServed = numServed / packets_expected


    # Prints information about the simulation
    def printData(self):
        print("Simulating to time {:.1f}s with a step size of {:.2f}".format(
            self._tFinal, self._tStep))
        print("lambda: {:.3f} packets arriving per second".format(self._lambda))
        print("mu: {:.3f} packets served per second".format(self._mu))
        
        print("Arrival".rjust(10), end='')
        print("Service".rjust(10), end='')
        print("Delay".rjust(10), end='')
        print("Finished".rjust(10), end='')
        print("Age".rjust(10))

        for i in range(len(self._timeArrived)):
            print("{:.1f}".format(self._timeArrived[i]).rjust(10), end='')
            print("{:.1f}".format(self._serviceTimes[i]).rjust(10), end='')
            print("{:.1f}".format(self._delayTime[i]).rjust(10), end='')
            print("{:.1f}".format(self._timeFinished[i]).rjust(10), end='')
            print("{:.1f}".format(self._packetAge[i]).rjust(10))

    def plotAge(self):
        fig, ax = plt.subplots()
        ax.plot(self._t, self._age, label="Age of Information")
        avgAgePlt = self.avgAge * np.ones( np.size(self._age) )
        ax.plot(self._t, avgAgePlt,
                 label="Average Age = {:.2f}".format(self.avgAge))
        ax.set_xlabel("time (s)")
        ax.set_ylabel("age (s)")
        ax.legend()
        
      
    # Exports the age and time arrays in a csv file for other programs
    def exportResults(self, filename):
        outFile = open(filename, "w")
        outFile.write("time,age\n")
        for i in range(len(self._age)):
            outFile.write("{:f},{:f}\n".format(self._t[i], self._age[i]))

    # Exports timeTransmit and serviceTimes as csv file.
    # Mostly to use with matlab to test that the algorithm is correct
    def exportSimulationParams(self, filename):
        outFile = open(filename, "w")
        outFile.write("timeArrived, serviceTimes\n")
        for i in range(len(self._timeArrived)):
            outFile.write("{:f},{:f}\n".format(self._timeArrived[i], self._serviceTimes[i]))

    # # Returns the average age of the simulation
    # def getAvgAge(self):
    #     return self._avgAge

    # # Returns the average delay of the simulation
    # def getAvgDelay(self):
    #     return self._avgDelay

    # def getPercentServed(self):
    #     return self._percentServed

if __name__ == "__main__":
    tFinal = 18000
    dt = 0.1
    arrivalRate = 1/200
    serviceRate = 1/30

    
    queue = AoIQueue(tFinal, dt, arrivalRate, serviceRate)
    

    avgAges = queue.avgAge
    queue.printData()
    print(queue.percentServed)

    queue.plotAge()
    plt.show()
    
    

