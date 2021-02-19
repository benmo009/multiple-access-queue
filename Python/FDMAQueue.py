import numpy as np
import matplotlib.pyplot as plt
import math
import helper
from AoIQueue import AoIQueue

class FDMAQueue:
    def __init__(self, tFinal, tStep, numSources, arrivalRate, serviceRate):
        self._numSources = numSources
        self._lambda = arrivalRate  # vector of arrival rates for each source
        self._mu = serviceRate  # vector of service rates for each source

        self._queues = []
        self._avgAge = np.zeros((numSources,))
        self._avgDelay = np.zeros((numSources,))
        self.percentServed = np.zeros((numSources,))
        for i in range(self._numSources):
            lam = self._lambda[i]
            mu = self._mu[i] 
            self._queues.append( AoIQueue(tFinal, tStep, lam, mu) )
            self._avgAge[i] = self._queues[i].avgAge
            self._avgDelay[i] = self._queues[i].avgDelay
            self.percentServed[i] = self._queues[i].percentServed

    def getAvgAge(self):
        return self._avgAge

    def getAvgDelay(self):
        return self._avgDelay

    def plotAge(self):
        fig, axs = plt.subplots(self._numSources,1)
        for i in range(self._numSources):
            queue = self._queues[i]
            avgAge = queue.avgAge

            axs[i].plot(queue._t, queue._age, label="Age")
            avgAgePlt = avgAge * np.ones(np.size(queue._age))
            axs[i].plot(queue._t, avgAgePlt,
                    label="Average Age = {:.2f}".format(avgAge))
            axs[i].set_xlabel("time (s)")
            axs[i].set_ylabel("age (s)")
            axs[i].legend()
        
        fig.tight_layout()
        plt.show()

if __name__ == "__main__":
    tFinal = 3600
    dt = 0.1
    numSources = 2
    arrivalRate = [0.009, 0.009]
    mu = 1/30

    b = 0.5
    serviceRate = [b * mu, (1-b)*mu ]

    numSimulations = 1000
    
    avgAge = np.zeros((numSources,))
    avgPercentServed = np.zeros((numSources,))
    for i in range(numSimulations):
        print("Simulation {:d} out of {:d}".format(i, numSimulations), end="\r")
        fdma = FDMAQueue(tFinal, dt, numSources, arrivalRate, serviceRate)
        avgAge += fdma.getAvgAge()
        avgPercentServed += fdma.percentServed


    avgAge = avgAge / numSimulations
    avgPercentServed = avgPercentServed / numSimulations
    print(avgAge)
    print(avgPercentServed)

    fdma = FDMAQueue(tFinal, dt, numSources, arrivalRate, serviceRate)
    fdma.plotAge()
            
