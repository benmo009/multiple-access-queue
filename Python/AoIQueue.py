import numpy as np
import matplotlib.pyplot as plt 
import helper
import math

class AoIQueue:
    def __init__(self, tFinal, tStep, arrivalRate, serviceRate):
        # Initialize simulation parameters
        self._tFinal = tFinal  # Total simulation time
        self._tStep = tStep  # Simulation step size
        self._lambda = arrivalRate  # Packet Arrival Rate (packets/second)
        self._mu = serviceRate  # Service Rate (packets served/second)

        # Make time array
        self._t = np.arange(0, self._tFinal + self._tStep, self._tStep)

        # Generate array of packet arrival times and store the number of packets
        self._timeArrived = helper.GenerateTransmissions(self._t, self._lambda)
        self._numPackets = len(self._timeArrived)

        # Generate array of service times
        array_size = (self._numPackets,)
        self._serviceTimes = helper.GenerateServiceTime(
            self._mu, self._tStep,  array_size)

        # Make array for wait times in queue. The first value is 0
        self._delayTime = np.zeros(array_size)
        # Make array to keep track of when packets finish being served
        self._timeFinished = np.zeros(array_size)
        # Packet age array to keep track of the age of each packet
        self._packetAge = np.zeros(array_size)

        # Calculate when the first packet gets served
        firstPacketServed = self._timeArrived[0] + self._serviceTimes[0]
        self._timeFinished[0] = firstPacketServed

        self._packetAge[0] = self._serviceTimes[0]

        # Go through each packet and calculate when they get served
        for i in range(1,self._numPackets):
            if self._timeArrived[i] >= self._timeFinished[i-1]:
                # Current packet arrived after last packed was finished serving
                self._delayTime[i] = 0  # It doesn't have to wait

            else:
                # Packet arrived before last packet is finished serving
                self._delayTime[i] = self._timeFinished[i-1] - self._timeArrived[i]

            # Calculate when current packet gets served
            packetServed = self._timeArrived[i] + self._delayTime[i] + self._serviceTimes[i]
            self._timeFinished[i] = packetServed

            currentPacketAge = packetServed - self._timeArrived[i]
            self._packetAge[i] = currentPacketAge

        # Update the t array for packets that finished after tFinal
        if self._timeFinished[-1] > self._tFinal:
            self._tFinal = self._timeFinished[-1]
            self._t = np.arange(0, self._tFinal+self._tStep, self._tStep)

        # Initialize age array with initial age of 0
        self._age = np.copy(self._t)

        # Iterate through each packet and update the age
        for i in range(self._numPackets):
            # Decimal places to round to based on step size
            precision = int(-math.log10(self._tStep))  

            # Get the time that current packet finished serving
            currentTime = self._timeFinished[i]  
            currentTime = round(currentTime, precision)

            # Find the corresponding index in the age array
            ageIndex = currentTime / self._tStep
            ageIndex = int(round(ageIndex))

            # Check for rounding errors
            if self._t[ageIndex] - currentTime > 1e-5:
                print(currentTime, end=' ')
                print(ageIndex, end=' ')
                print(self._t[ageIndex])
            
            # Decrease the age to the age of the packet that just got served
            reduceAge = self._age[ageIndex] - self._packetAge[i]
            self._age[ageIndex:] -= reduceAge
        
        # Calculate the averages
        self._avgAge = np.mean(self._age)
        self._avgDelay = np.mean(self._delayTime)

    # Prints information about the simulation
    def printData(self):
        print("Simulating to time {:.1f}s with a step size of {:.2f}".format(
            self._tFinal, self._tStep))
        print("lambda: {:.3f} packets arriving per second".format(self._lambda))
        print("mu: {:.3f} packets served per second".format(self._mu))

        print("{:d} packets sent".format(self._numPackets))
        
        print("Arrival".rjust(10), end='')
        print("Service".rjust(10), end='')
        print("Delay".rjust(10), end='')
        print("Finished".rjust(10), end='')
        print("Age".rjust(10))

        for i in range(self._numPackets):
            print("{:.1f}".format(self._timeArrived[i]).rjust(10), end='')
            print("{:.1f}".format(self._serviceTimes[i]).rjust(10), end='')
            print("{:.1f}".format(self._delayTime[i]).rjust(10), end='')
            print("{:.1f}".format(self._timeFinished[i]).rjust(10), end='')
            print("{:.1f}".format(self._packetAge[i]).rjust(10))

    def plotAge(self):
        plt.plot(self._t, self._age, label="Age of Information")
        avgAgePlt = self._avgAge * np.ones( np.size(self._age) )
        plt.plot(self._t, avgAgePlt,
                 label="Average Age = {:.2f}".format(self._avgAge))
        plt.xlabel("time (s)")
        plt.ylabel("age (s)")
        plt.legend()
        plt.show()
      
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
        for i in range(self._numPackets):
            outFile.write("{:f},{:f}\n".format(self._timeArrived[i], self._serviceTimes[i]))

    # Returns the average age of the simulation
    def getAvgAge(self):
        return self._avgAge

    # Returns the average delay of the simulation
    def getAvgDelay(self):
        return self._avgDelay

if __name__ == "__main__":
    tFinal = 3600
    dt = 0.1
    arrivalRate = 1/60
    serviceRate = 1/30

    numSimulations = 2000
    avgAges = np.zeros((numSimulations,))

    for i in range(numSimulations):
        queue = AoIQueue(tFinal, dt, arrivalRate, serviceRate)
        avgAges[i] = queue.getAvgAge()

    print(np.mean(avgAges))
    
    

