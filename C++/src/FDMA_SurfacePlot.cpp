#include "FDMAQueue.h"
#include <iostream>
#include <fstream>
#include <math.h>
#include <iomanip>

int main(int argc, char* argv[]) {
    // // arguments: nSimulations tFinal tStep mu outFile
    // if (argc != 6) {
    //     std::cerr << "Invalid arguments." << std::endl;
    //     std::cerr << "Arguments should be in form:" << std::endl;
    //     std::cerr << "nSimulations tFinal tStep mu outFile" << std::endl;
    //     return(1);
    // }

    // Store the arguments
    int nSimulations = 2500; // std::atoi(argv[1]);
    double tFinal = 1800; // std::atof(argv[2]);
    double tStep = 0.1; // std::atof(argv[3]);
    double mu = 0.1; // std::atof(argv[4]);
    std::string b_filename = "C++/data/FDMA_SurfaceB.csv"; // argv[5];
    std::string age_filename = "C++/data/FDMA_SurfaceAge.csv";
    // What to store in output?
    // b  avgAge

    // Open the output file to write
    std::ofstream outFileB(b_filename);
    if (!outFileB.good()) {
        std::cerr << "Cannot open " << b_filename << " to write" << std::endl;
        return(1);
    }

    std::ofstream outFileAge(age_filename);
    if (!outFileAge.good()) {
        std::cerr << "Cannot open " << age_filename << " to write" << std::endl;
        return(1);
    }

    const int numSources = 2;
    // Define lambda
    double minLambda = 0.015;
    double maxLambda = 0.03;
    int numLambda = 10;

    std::cout << std::setw(8) << "";
    outFileB << std::setw(8) << ",";
    outFileAge << std::setw(8) << ",";

    double* lambdaArr = new double[numLambda];
    for (int i = 0; i < numLambda; ++i) {
        lambdaArr[i] = ((maxLambda - minLambda)/(numLambda-1)) * i + minLambda;
        std::cout << std::setw(8) << std::setprecision(3) << lambdaArr[i];
        outFileB << std::setw(7) << std::setprecision(3) << lambdaArr[i] << ",";
        outFileAge << std::setw(7) << std::setprecision(3) << lambdaArr[i] << ",";
    }

    std::cout << std::endl;
    outFileB << std::endl;
    outFileAge << std::endl;

    // Define b range
    double minB = 0.4;
    double maxB = 0.7;
    int numB = 20;

    double* bArr = new double[numB]; // Array for storing all b values to simulate
    for (int i = 0; i < numB; ++i) {
        // Calculate b
        bArr[i] = ((maxB - minB)/(numB-1)) * i + minB;
    }


    for (int l1 = 0; l1 < numLambda; ++l1) { 
        std::cout << std::setw(8) << std::setprecision(3) << lambdaArr[l1];
        std::cout.flush();

        outFileB << std::setw(7) << std::setprecision(3) << lambdaArr[l1] << ",";
        outFileAge << std::setw(7) << std::setprecision(3) << lambdaArr[l1] << ",";

        for (int l2 = 0; l2 < numLambda; ++l2) {

            double difference = 100000.0;
            double bestB;
            double bestAvgAge;

            for(int bi = 0; bi < numB; ++bi) {
                double sumAvgAge[numSources];
                sumAvgAge[0] = 0;
                sumAvgAge[1] = 0;

                for (int i = 0; i < nSimulations; ++i) {
                    double* b = new double[numSources];
                    b[0] = bArr[bi];
                    b[1] = 1 - b[0];

                    double* lambda = new double[numSources];
                    lambda[0] = lambdaArr[l1];
                    lambda[1] = lambdaArr[l2];

                    FDMAQueue fdma(numSources, lambda, mu, b, tFinal, tStep);
                    sumAvgAge[0] += fdma.getAvgAge(0);
                    sumAvgAge[1] += fdma.getAvgAge(1);
                }

                sumAvgAge[0] = sumAvgAge[0] / nSimulations;
                sumAvgAge[1] = sumAvgAge[1] / nSimulations;

                // Find the optimal b value
                if (fabs(sumAvgAge[1] - sumAvgAge[0]) < difference) {
                    difference = fabs(sumAvgAge[1] - sumAvgAge[0]);
                    bestB = bArr[bi];
                    bestAvgAge = (sumAvgAge[0] + sumAvgAge[1]) / numSources;
                }      
            }
            std::cout << std::setw(8) << std::setprecision(3) << bestB;  
            std::cout.flush();

            outFileB << std::setw(7) << std::setprecision(3) << bestB << ",";
            outFileAge << std::setw(7) << std::setprecision(5) << bestAvgAge << ",";


        }
        std::cout << std::endl;
        outFileB << std::endl;
        outFileAge << std::endl;
    }
    
    // Clean up the arrays
    delete [] bArr;
    delete [] lambdaArr;


    return(0);
}