#!/usr/bin/env python

import math
import time
import numpy as np
import matplotlib.pyplot as plt
from FDMAQueue import FDMAQueue


def plot_delay_vs_throughput(throughput, delay, arrivalRate):
    fig = plt.figure()
    ax1 = fig.add_subplot(111)
    ax2 = ax1.twiny()

    # Add some extra space for the second axis at the bottom
    fig.subplots_adjust(bottom=0.2)

    ax1.plot(throughput[:,0], delay[:,0], label=r"Source 1, $\lambda=$%.3f" % arrivalRate[0])
    ax1.plot(throughput[:,0], delay[:,1], label=r"Source 2, $\lambda=$%.3f" % arrivalRate[1])
    ax1.plot(throughput[:,0], np.sum(delay, axis=1), "-", label="Sum Delay")    
    ax1.set_xlabel("Throughput for source 1")
    ax1.legend()

    new_tick_locations = ax1.get_xticks()

    # Move twinned axis ticks and label from top to bottom
    ax2.xaxis.set_ticks_position("bottom")
    ax2.xaxis.set_label_position("bottom")

    # Offset the twin axis below the host
    ax2.spines["bottom"].set_position(("axes", -0.15))

    # Turn on the frame for the twin axis, but then hide all 
    # but the bottom spine
    ax2.set_frame_on(True)
    ax2.patch.set_visible(False)

    for sp in ax2.spines.values():
        sp.set_visible(False)
    ax2.spines["bottom"].set_visible(True)

    ax2.set_xticks(new_tick_locations)
    ax2.set_xlim(ax1.get_xlim())
    ax2.set_xticklabels(np.flip(new_tick_locations))
    ax2.set_xlabel("Throughput for source 2")

    fig.tight_layout()

    plt.show()

if __name__ =="__main__":
    # Set number of sources
    numSources = 2

    # Set average service rate (packet/second)
    mu = 1/30

    # Compute every splitting factor value used
    bLength = 30
    bValues = np.linspace(0.1, 0.9, bLength)
    # Each row is a set of split factor pairs
    splitFactors = np.zeros((bLength, 2)) 
    splitFactors[:,0] = bValues
    splitFactors[:,1] = 1 - bValues

    # Set arrival rates for each source (packet/second)
    arrivalRate = np.zeros(2)
    # Need to make sure that the arrival rate will always be less than the service rate
    arrivalRate[0] = mu * min(bValues) * 0.9
    arrivalRate[1] = mu * (1 - max(bValues)) * 0.9

    # Compute each service rate based on the split factors
    serviceRates = splitFactors * mu

    # Compute throughput for each split factor value
    throughput = arrivalRate * np.log(serviceRates / arrivalRate)
    sum_throughput = np.sum(throughput, axis=1)

    # Get numerical results
    tFinal = 7200
    tStep = 0.1
    numSimulations = 1000

    avgDelay = np.zeros((bLength, numSources))

    start_time = time.time()
    for i in range(bLength):
        for j in range(numSimulations):
            print("[%d/%d] Simulation %d" % (i, bLength, j))
            fdma = FDMAQueue(tFinal, tStep, numSources, arrivalRate, serviceRates[i,:])
            avgDelay[i,:] += fdma.getAvgDelay()
        
        avgDelay[i,:] /= numSimulations
    print("Took %.3f seconds" % (time.time() - start_time) )

    plot_delay_vs_throughput(throughput, avgDelay, arrivalRate)