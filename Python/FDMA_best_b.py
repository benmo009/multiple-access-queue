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
    b_min = 0.3
    b_max = 0.7
    splitFactor = np.arange(b_min, b_max+0.01, 0.01)
    bLength = len(splitFactor)

    # Set arrival rates for each source (packet/second)
    # Need to make sure that the arrival rate will always be less than the service rate
    arrivalRate_max = min( mu*b_min, (1-b_max)*mu )
    arrivalRate = arrivalRate_max * np.arange(0.35, 0.95, 0.05)
    lamLength = len(arrivalRate)

    # Make meshgrids for 3d plot
    X,Y = np.meshgrid(arrivalRate, arrivalRate)
    Z = np.zeros_like(X)
    b_minDiff = np.zeros_like(X)
    b_minOverall = np.zeros_like(X)

    numSimulations = 1000

    start_time = time.time()
    for k in range(len(arrivalRate)):
        lam_1 = arrivalRate[k]
        for l in range(len(arrivalRate)):
            lam_2 = arrivalRate[l]
            # Make array of arrival rates
            lam = [lam_1, lam_2]
            print("[{:d}/{:d}] lambda = [{:.4f}, {:.4f}]".format(k*l + l, lamLength**2, lam_1, lam_2))

            avgAge = np.zeros((bLength, numSources,))
            for i in range(bLength):
                b = splitFactor[i]
                serviceRate = [b * mu, (1-b) * mu]

                for j in range(numSimulations):
                    print("\t[{:d}/{:d}] Simulation {:>4d} for b={:.2f}".format(i, bLength, j, b), end='\r')
                    fdma = FDMAQueue(tFinal, dt, numSources, lam, serviceRate)
                    avgAge[i] += fdma.getAvgAge()

                avgAge[i] = avgAge[i] / numSimulations
                
            # Find best b values
            diffAge = abs(avgAge[:, 0] - avgAge[:, 1])
            b_minDiff[k,l] = splitFactor[np.argmin(diffAge)]

            overallAvgAge = np.sum(avgAge, axis=1) / numSources
            b_minOverall[k,l] = splitFactor[np.argmin(overallAvgAge)]

    print("Program took {:.2f}s to run".format(time.time() - start_time) )


    # mesh_fig = plt.figure()
    # mesh_ax = mesh_fig.add_subplot(111, projection='3d')
    # mesh_ax.plot_wireframe(X, Y, Z)
    # mesh_ax.set_title("Overall Average Age over Different Arrival Rates")
    # mesh_ax.set_xlabel("$\lambda_1$")
    # mesh_ax.set_ylabel("$\lambda_2$")
    # mesh_ax.set_zlabel("Age")

    diff_b_fig = plt.figure()
    diff_b_ax = diff_b_fig.add_subplot(111, projection='3d')
    diff_b_ax.plot_wireframe(X, Y, b_minDiff)
    diff_b_ax.set_title("b Value that Minimizes Difference in Age")
    diff_b_ax.set_xlabel("$\lambda_1$")
    diff_b_ax.set_ylabel("$\lambda_2$")
    diff_b_ax.set_zlabel("Splitting Factor, b")

    overall_b_fig = plt.figure()
    overall_b_ax = overall_b_fig.add_subplot(111, projection='3d')
    overall_b_ax.plot_wireframe(X, Y, b_minOverall)
    overall_b_ax.set_title("b Value that Minimizes Overall Age")
    overall_b_ax.set_xlabel("$\lambda_1$")
    overall_b_ax.set_ylabel("$\lambda_2$")
    overall_b_ax.set_zlabel("Splitting Factor, b")
    
    plt.show()
