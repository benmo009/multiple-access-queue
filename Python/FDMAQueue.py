from collections import deque
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
        for i in range(self._numSources):
            lam = self._lambda[i]
            mu = self._mu[i] 
            self._queues.append( AoIQueue(tFinal, tStep, lam, mu) )
            self._avgAge[i] = self._queues[i].getAvgAge()
            self._avgDelay[i] = self._queues[i].getAvgDelay()

    def getAvgAge(self):
        return self._avgAge

    def getAvgDelay(self):
        return self._avgDelay

    def plotAge(self):
        pass

if __name__ == "__main__":
    tFinal = 3600
    dt = 0.1
    numSources = 2
    arrivalRate = [1/60, 1/45]
    mu = 1/30

    b = 0.5
    serviceRate = [b * mu, (1-b)*mu ]

    numSimulations = 1000
    
    avgAge = np.zeros((numSources,))
    for i in range(numSimulations):
        fdma = FDMAQueue(tFinal, dt, numSources, arrivalRate, serviceRate)
        avgAge += fdma.getAvgAge()


    avgAge = avgAge / numSimulations
    print(avgAge)
            
