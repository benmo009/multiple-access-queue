#include "FDMAQueue.h"
#include <iostream>
#include <fstream>

int main(int argc, char* argv[]) {
    // // arguments: nSimulations tFinal tStep mu outFile
    // if (argc != 6) {
    //     std::cerr << "Invalid arguments." << std::endl;
    //     std::cerr << "Arguments should be in form:" << std::endl;
    //     std::cerr << "nSimulations tFinal tStep mu outFile" << std::endl;
    //     return(1);
    // }

    // Store the arguments
    int nSimulations = 500; // std::atoi(argv[1]);
    double tFinal = 1800; // std::atof(argv[2]);
    double tStep = 0.1; // std::atof(argv[3]);
    double mu = 0.1; // std::atof(argv[4]);
    std::string filename = "C++/data/FDMA_SplitMu.csv"; // argv[5];

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
    // Define lambda
    double minLambda = 0.015;
    double maxLambda = 0.03;
    int numLambda = 50;

    double* lambdaArr = new double[numLambda];

    double lambda[numSources]; // = new double[numSources];
    lambda[0] = 0.0167;
    lambda[1] = 0.025;

    // Define b range
    double minB = 0.25;
    double maxB = 0.75;
    int numB = 100;

    double* b = new double[numB]; // Array for storing all b values to simulate
    double** avgAge = new double*[numB]; // Array for storing avg age for each b
    
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
    }

    // Clean up the arrays
    delete [] b;
    for (int i = 0; i < numB; ++i) {
        delete [] avgAge[i];
    }
    delete [] avgAge;
}