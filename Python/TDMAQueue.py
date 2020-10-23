from collections import deque
import numpy as np
import matplotlib.pyplot as plt 
import math
import helper

class TDMAQueue:
    def __init__(self, tFinal, tStep, slotWidth, arrivalRate, serviceRate):
        self._numSources = len(slotWidth)
        self._slotWidth = slotWidth
        self._lambda = arrivalRate
        self._mu = serviceRate

        self._t = np.arange(0, tFinal + tStep, tStep)

        
