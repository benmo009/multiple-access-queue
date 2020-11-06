from FDMAQueue import FDMAQueue
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

    # Set splitting factor b
    bLength = 100
    splitFactor = np.linspace(0.3, 0.7, bLength)

    # Set arrival rates for each source (packet/second)
    arrivalRate = [0, 0]
    # Need to make sure that the arrival rate will always be less than the service rate
    arrivalRate[0] = mu * min(splitFactor) * 0.5
    arrivalRate[1] = mu * (1 - max(splitFactor)) * 0.9

    numSimulations = 1000 
    avgAge = np.zeros((bLength, numSources))
    avgServed = np.zeros((bLength, numSources))

    start_time = time.time()

    for i in range(bLength):
        b = splitFactor[i]
        serviceRate = [b * mu, (1-b) * mu]

        for j in range(numSimulations):
            print("[{:d}/{:d}] Simulation {:d} for b={:.2f}".format(i, bLength, j, b), end='\r')
            fdma = FDMAQueue(tFinal, dt, numSources, arrivalRate, serviceRate)
            avgAge[i] += fdma.getAvgAge()
            avgServed[i] += fdma.percentServed

        avgAge[i] = avgAge[i] / numSimulations
        avgServed[i] = avgServed[i] / numSimulations
        print("b = {:.2f}, avgAge = [ {:.2f}, {:.2f} ]".format(b, avgAge[i,0], avgAge[i,1]), end='\n')

    # Print the runtime
    print("Program took {:.2f}s to run".format(time.time() - start_time) )

    # Print important b values
    diffAge = abs(avgAge[:,0] - avgAge[:,1])
    b_minDiff = splitFactor[ np.argmin(diffAge) ]
    print("b value that minimizes the difference between average age: {:.3f}".format(b_minDiff))

    overallAvgAge = np.sum(avgAge, axis=1) / numSources
    b_minOverall = splitFactor[np.argmin(overallAvgAge)]
    print("b value that minimizes the overall average age: {:.3f}".format(b_minOverall))

    # Make plots
    fig, ax = plt.subplots(1,1)

    ax.plot(splitFactor, avgAge[:,0], '.', label="Source 1, $\lambda$ = {:.3f}".format(arrivalRate[0]))
    ax.plot(splitFactor, avgAge[:,1], '.', label="Source 2, $\lambda$ = {:.3f}".format(arrivalRate[1]))
    ax.plot(splitFactor, overallAvgAge, '.', label="Overall Average Age")
    ax.legend()
    ax.set_xlabel("Splitting Factor, b")
    ax.set_ylabel("Average Age")
    ax.set_title("FDMA Split $\mu$ - Age")

    # Plot percentage of packets served
    fig_serve, ax_serve = plt.subplots(1,1)
    ax_serve.plot(splitFactor, avgServed[:, 0], '.',
                label="Source 1, $\lambda$ = {:.3f}".format(arrivalRate[0]))
    ax_serve.plot(splitFactor, avgServed[:, 1], '.', 
                label="Source 2, $\lambda$ = {:.3f}".format(arrivalRate[1]))
    ax_serve.legend()
    ax_serve.set_xlabel("Splitting Factor, b")
    ax_serve.set_ylabel("Average Percent Served")
    ax_serve.set_title("FDMA Split $\mu$ - Percent Served")

    plt.show()


    
    
