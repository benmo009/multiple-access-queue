import numpy as np
import matplotlib.pyplot as plt
import math

# Generates an array of transmission times from an exponential distribution
def GenerateTransmissions(t, arrivalRate):
    # Calculate the total number of steps in the simulation
    n = len(t)

    # Calculate probability of a packet arriving at each step
    dt = t[1] - t[0]
    p = arrivalRate * dt

    # Generate an array of random numbers between 0 and 1 for each time step
    R = np.random.uniform(0,1,(n,))

    # Find the time values when the random numbers are less than the probability
    events = t[np.where(R < p)]

    # Re-call the functon in case no events were generated
    if len(events) == 0:
        events = GenerateTransmissions(t, arrivalRate)

    return events

# Generates service times from an exponential distribution with mean mu
def GenerateServiceTime(mu, dt, size=None):
    # Generate an array of random exponential variables with mean 1/mu
    S = np.random.exponential(1/mu, size)
    
    precision = int( -math.log10(dt) )
    S = np.round(S, precision)

    return S

if __name__ == "__main__":
    print("AoIQueue")
    tFinal = 3600
    dt = 0.1
    t = np.arange(0, tFinal+dt, dt)
    arrivalRate = 1/60

    expected= int(tFinal * arrivalRate)
    print("Expected number of events: {:d}".format(expected))

    timeTransmit = GenerateTransmissions(t, arrivalRate)
    numEvents = len(timeTransmit)
    print("Number of events generated: {:d}".format(numEvents))

    S = GenerateServiceTime(1/30, dt)
    print(S)

