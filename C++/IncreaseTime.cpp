#include "AoIQueue.h"


int main() {
    std::ofstream outFile("IncreaseSimTime.csv");
    if (!outFile.good()) {
        std::cerr << "Could not open IncreaseSimTime.csv to write" << std::endl;
        return 1;
    }

    int nSimulations = 250;
    int nSteps = 100;
    

    double tStep = 0.1;
    double lambda = 1.0/60.0;
    double mu = 0.1;
    double tFinal;


    double simTimes[nSteps];
    double avgAge[nSteps];
    for (int i = 0; i < nSteps; ++i) {
        avgAge[i] = 0;
    }

    std::cout << std::setw(15) << "Simulation Time";
    std::cout << std::setw(15) << "Average Age";
    std::cout << std::endl;

    //outFile << "SimTime,AvgAge" << std::endl;
    for (int i = 1; i <= nSteps; ++i) {
        simTimes[i-1] = i * 360;
        std::cout << std::setw(15) << simTimes[i-1];
        tFinal = simTimes[i-1];

        for (int j = 0; j < nSimulations; ++j) {
            AoIQueue queue(tFinal, tStep, lambda, mu);
            avgAge[i-1] += queue.getAvgAge();
        }

        avgAge[i-1] = avgAge[i-1] / nSimulations;
        std::cout << std::setw(15) << avgAge[i-1] << std::endl;

        outFile << tFinal << "," << avgAge[i-1] << std::endl;

    }

    





}