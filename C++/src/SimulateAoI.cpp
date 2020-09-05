#include "AoIQueue.h"

int main(int argc, char* argv[]) {

    double tFinal = 5040;
    double tStep = 0.1;
    double lambda = 1.0/60.0;
    double mu = 0.1;

    AoIQueue queue(tFinal, tStep, lambda, mu);
    queue.print();

    std::cout << "Average Age: " << queue.getAvgAge() << std::endl;
    std::cout << "Average Delay: " << queue.getAvgDelay() << std::endl;

    std::string filename = "data/AgeOutput.csv";
    queue.exportData(filename);

    return 0;
}
