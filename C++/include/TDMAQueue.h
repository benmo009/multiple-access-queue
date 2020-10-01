#ifndef TDMAQueue_h_
#define TDMAQueue_h_

#include <vector>

class TDMAQueue {
public:
    TDMAQueue();
    
    ~TDMAQueue();

private:
    double _nSources;
    double _tFinal;
    double _tStep;
    double _mu;
    double* _lambda;
    double* _b;

    // Some kind of queue


    double*
    


};


#endif