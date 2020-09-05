#include "AoIQueue.h"

int main() {

    double tFinal = 360;
    double tStep = 0.1;
    double lambda = 1.0/60.0;
    double mu = 0.1;

    AoIQueue queue(tFinal, tStep, lambda, mu);

    std::cout << "Average Age: " << queue.getAvgAge() << std::endl;
    std::cout << "Average Delay: " << queue.getAvgDelay() << std::endl;

    std::string filename = "AgeOutput.txt";
    queue.exportAge(filename);

    return 0;
}
