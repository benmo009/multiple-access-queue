#ifndef FDMAQueue_h_
#define FDMAQueue_h_

#include <string>

class AoIQueue;

class FDMAQueue {
public:
    FDMAQueue();
    FDMAQueue(int sources, double* lambda, double mu, double* b, double tFinal, double dt);

    ~FDMAQueue();

    void print();
    void printQueues();
    bool exportData(const std::string& filename);

    double* getAvgAge();
    double getAvgAge(int source);

    double* getAvgDelay();
    double getAvgDelay(int source);

private:
    void init();


    int _nSources;  // Number of sources
    AoIQueue** _queues; // Array of AoIQueues of length _nSources

    double* _lambda; // Stores lambda values for each source
    double _mu; // Overall service rate
    double* _b;  // Array of b values, should add up to 1

    double* _avgAge;  // stores the average age for each source
    double* _avgDelay;  // stores the average delay for each source

    double _tFinal;
    double _tStep;

};



#endif