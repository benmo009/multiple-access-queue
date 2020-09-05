#ifndef FDMAQueue_h_
#define FDMAQueue_h_

class AoIQueue;


class FDMAQueue {
public:
    FDMAQueue();
    FDMAQueue(int sources, double* lambda, double mu, double* b, double tFinal, double dt);

    ~FDMAQueue();


private:
    int _nSources;  // Number of sources
    AoIQueue** _queues; // Array of AoIQueues of length _nSources

    double* _lambda; // Stores lambda values for each source
    double _mu; // Overall service rate
    double* _b;  // Array of b values, should add up to 1

    double* _avgAge;  // stores the average age for each source
    double* _avgDelay;  // stores the average delay for each source

};



#endif