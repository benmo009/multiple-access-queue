#include "FDMAQueue.h"
#include <iostream>
#include <fstream>
#include <math.h>

int main(int argc, char* argv[]) {
    // arguments: nSimulations tFinal tStep mu outFile
    if (argc != 6) {
        std::cerr << "Invalid arguments." << std::endl;
        std::cerr << "Arguments should be in form:" << std::endl;
        std::cerr << "nSimulations tFinal tStep mu outFile" << std::endl;
        return(1);
    }

    // Store the arguments
    int nSimulations = std::atoi(argv[1]);
    double tFinal = std::atof(argv[2]);
    double tStep = std::atof(argv[3]);
    double mu = std::atof(argv[4]);
    std::string filename = argv[5]; // "C++/data/FDMA_SplitMu.csv"

    // What to store in output?
    // b  avgAge

    // Open the output file to write
    std::ofstream outFile(filename);
    if (!outFile.good()) {
        std::cerr << "Cannot open " << filename << " to write" << std::endl;
        return(1);
    }
    outFile << "b,source1,source2" << std::endl;

    const int numSources = 2;
    // Define Lambda
    double lambda[numSources]; // = new double[numSources];
    lambda[0] = 0.0167;
    lambda[1] = 0.025;

    // Define b range
    double minB = 0.25;
    double maxB = 0.75;
    int numB = 100;

    double* b = new double[numB]; // Array for storing all b values to simulate
    double** avgAge = new double*[numB]; // Array for storing avg age for each b

    double difference = 100000.0;
    double bestB;
    
    // Iterate through each b value
    for (int i = 0; i < numB; ++i) {

        // Calculate b
        b[i] = ((maxB - minB)/(numB-1)) * i + minB;
        std::cout << b[i] << std::endl;

        double sumAvgAge[numSources];
        sumAvgAge[0] = 0;
        sumAvgAge[1] = 0;

        avgAge[i] = new double[numSources];
        for (int j = 0; j < nSimulations; ++j) {

            double* bArr = new double[numSources];
            bArr[0] = b[i];
            bArr[1] = 1 - b[i];

            double* lambdaArr = new double[numSources];
            lambdaArr[0] = lambda[0];
            lambdaArr[1] = lambda[1];

            FDMAQueue fdma(numSources, lambdaArr, mu, bArr, tFinal, tStep);
            sumAvgAge[0] += fdma.getAvgAge(0);
            sumAvgAge[1] += fdma.getAvgAge(1);
        }

        avgAge[i][0] = sumAvgAge[0] / nSimulations;
        avgAge[i][1] = sumAvgAge[1] / nSimulations;

        outFile << b[i] << "," << avgAge[i][0] << "," << avgAge[i][1] << std::endl;   

        // Find the optimal b value
        if (fabs(avgAge[i][1] - avgAge[i][0]) < difference) {
            difference = abs(avgAge[i][1] - avgAge[i][0]);
            bestB = b[i];
        }     
    }

    std::cout << "Optimal b: " << bestB << std::endl;
    std::cout << "With difference: " << difference << std::endl;

    // Clean up the arrays
    delete [] b;
    for (int i = 0; i < numB; ++i) {
        delete [] avgAge[i];
    }
    delete [] avgAge;
}