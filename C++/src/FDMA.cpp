#include "FDMAQueue.h"
#include <iostream>

int main() {
    // Set simulation parameters
    double tFinal = 500;
    double tStep = 0.1;
    int numSources = 2;

    // Define lambda values for each source
    double* lambda = new double[numSources]{0.015, 0.015};

    // Set overall mu value
    double mu = 0.1;

    // Set mu splitting factor
    double b = 0.25;
    double* bArr = new double[numSources]{b, 1-b};

    FDMAQueue fdma(numSources, lambda, mu, bArr, tFinal, tStep);

    fdma.print();
    //fdma.exportData("data/FDMA/data");

}