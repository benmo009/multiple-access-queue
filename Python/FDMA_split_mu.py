from FDMAQueue import FDMAQueue
import matplotlib.pyplot as plt 
import numpy as np
import math
import time

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
    avgAge = np.zeros((bLength, numSources,))

    start_time = time.time()

    for i in range(bLength):
        b = splitFactor[i]
        serviceRate = [b * mu, (1-b) * mu]

        for j in range(numSimulations):
            print("[{:d}/{:d}] Simulation {:d} for b={:.2f}".format(i, bLength, j, b), end='\r')
            fdma = FDMAQueue(tFinal, dt, numSources, arrivalRate, serviceRate)
            avgAge[i] += fdma.getAvgAge()

        avgAge[i] = avgAge[i] / numSimulations
        print("b = {:.2f}, avgAge = [ {:.2f}, {:.2f} ]".format(b, avgAge[i,0], avgAge[i,1]), end='\n')

    print("Program took {:.2f}s to run".format(time.time() - start_time) )

    plt.plot(splitFactor, avgAge[:,0], '.', label="Source 1, $\lambda$ = {:.3f}".format(arrivalRate[0]))
    plt.plot(splitFactor, avgAge[:,1], '.', label="Source 2, $\lambda$ = {:.3f}".format(arrivalRate[1]))
    plt.legend()
    plt.xlabel("Splitting Factor, b")
    plt.ylabel("Average Age")
    plt.show()

    
    