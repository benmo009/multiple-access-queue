from FDMAQueue import FDMAQueue
import matplotlib.pyplot as plt 
import numpy as np
import math

if __name__ == "__main__":
    # Set simulation step size and duration (seconds)
    tFinal = 1800
    dt = 0.1

    # Set number of sources
    numSources = 2

    # Set arrival rates for each source (packet/second)
    arrivalRate = [1/60, 1/45]

    # Set average service rate (packet/second)
    mu = 1/30

    # Set splitting factor b
    bLength = 100
    splitFactor = np.linspace(0.25, 0.75, bLength)

    numSimulations = 1000

    for b in splitFactor:
        print(b, end=', ')
        serviceRate = [b * mu, (1-b) * mu]

        avgAge = np.zeros((numSources,))
        for i in range(numSimulations):
            fdma = FDMAQueue(tFinal, dt, numSources, arrivalRate, serviceRate)
            avgAge += fdma.getAvgAge()

        avgAge = avgAge / numSimulations
        print(avgAge)

    
    