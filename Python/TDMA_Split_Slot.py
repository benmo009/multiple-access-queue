from TDMAQueue import TDMAQueue
import matplotlib.pyplot as plt
import numpy as np
import time

if __name__ == "__main__":
    # Set simulation step size and duration (seconds)
    tFinal = 1800
    dt = 0.1

    # Set number of sources
    numSources = 2

    # Set average service rate (packet/second)
    mu = 1/30
    T = 5/mu

    # Set splitting factor b
    bLength = 100
    splitFactor = np.linspace(0.3, 0.7, bLength)

    # Set arrival rates for each source (packet/second)
    arrivalRate = [0, 0]
    # Need to make sure that the arrival rate will always be less than the service rate
    arrivalRate[0] = mu * min(splitFactor) * 0.5
    arrivalRate[1] = mu * (1 - max(splitFactor)) * 0.3

    numSimulations = 1000
    avgAge = np.zeros((bLength, numSources,))

    start_time = time.time()

    for i in range(bLength):
        b = splitFactor[i]
        slotWidth = [b*T, (1-b)*T]

        for j in range(numSimulations):
            print("[{:d}/{:d}] Simulation {:d} for b={:.2f}".format(
                i, bLength, j, b), end='\r')

            tdma = TDMAQueue(tFinal, dt, slotWidth, arrivalRate, mu)
            avgAge[i] += tdma.getAvgAge()

        avgAge[i] = avgAge[i] / numSimulations
        print("b = {:.2f}, avgAge = [ {:.2f}, {:.2f} ]".format(
            b, avgAge[i, 0], avgAge[i, 1]), end='\n')

    print("Program took {:.2f}s to run".format(time.time() - start_time))

    diffAge = abs(avgAge[:, 0] - avgAge[:, 1])
    bestB = splitFactor[np.argmin(diffAge)]
    print(
        "b value that minimizes the difference between average age: {:.3f}".format(bestB))

    overallAvgAge = np.sum(avgAge, axis=1) / numSources
    bestB = splitFactor[np.argmin(overallAvgAge)]
    print(
        "b value that minimizes the overall average age: {:.3f}".format(bestB))

    plt.plot(splitFactor, avgAge[:, 0], '.',
             label="Source 1, $\lambda$ = {:.3f}".format(arrivalRate[0]))
    plt.plot(splitFactor, avgAge[:, 1], '.',
             label="Source 2, $\lambda$ = {:.3f}".format(arrivalRate[1]))
    plt.plot(splitFactor, overallAvgAge, '.', label="Overall Average Age")
    plt.legend()
    plt.xlabel("Splitting Factor, b")
    plt.ylabel("Average Age")
    plt.title("TDMA Split Time Slot")
    plt.show()
