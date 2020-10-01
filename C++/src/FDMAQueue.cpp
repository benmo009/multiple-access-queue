#include "FDMAQueue.h"
#include "AoIQueue.h"


FDMAQueue::FDMAQueue() {
    init();
}

FDMAQueue::FDMAQueue(int sources, double* lambda, double mu, double* b, double tFinal, double dt) {
    init();

    _nSources = sources;
    _lambda = lambda;
    _mu = mu;
    _b = b;
    _tFinal = tFinal;
    _tStep = dt;


    _queues = new AoIQueue*[_nSources];
    _avgAge = new double[_nSources];
    _avgDelay = new double[_nSources];

    for (int i = 0; i < _nSources; ++i) {
        _queues[i] = new AoIQueue(tFinal, dt, _lambda[i], _b[i]*_mu);
        
        _avgAge[i] = _queues[i]->getAvgAge();
        _avgDelay[i] = _queues[i]->getAvgDelay();
    }

}

FDMAQueue::~FDMAQueue() {
    if (_queues != NULL) {
        for (int i = 0; i < _nSources; ++i) {
            if (_queues[i] != NULL) {
                delete _queues[i];
            }
        }
        delete [] _queues;
    }

    if (_lambda != NULL) { delete [] _lambda; }
    if (_lambda != NULL) { delete [] _b; }
    if (_lambda != NULL) { delete [] _avgAge; }
    if (_lambda != NULL) { delete [] _avgDelay; }
}

void FDMAQueue::init() {
    // Initialize all pointers to NULL
    _queues = NULL;
    _lambda = NULL;
    _b = NULL;
    _avgAge = NULL;
    _avgDelay = NULL;
}

// Prints information about the FDMA Queue
void FDMAQueue::print() {
    std::cout << _nSources << " Source FDMA Queue" << std::endl;
    std::cout << "Simulation time of " << _tFinal << "s, with step size " << _tStep << "s" << std::endl;
    std::cout << std::endl;
    
    std::cout << std::setw(10) << "source";
    std::cout << std::setw(10) << "lambda";
    std::cout << std::setw(10) << "b";
    std::cout << std::setw(10) << "mu";
    std::cout << std::setw(10) << "avg age";
    std::cout << std::setw(12) << "avg delay";
    std::cout << std::endl;

    for (int i = 0; i < _nSources; ++i) {
        std::cout << std::setw(10) << i;
        std::cout << std::setw(10) << _lambda[i];
        std::cout << std::setw(10) << _b[i];
        std::cout << std::setw(10) << _b[i] * _mu;
        std::cout << std::setw(10) << _avgAge[i];
        std::cout << std::setw(12) << _avgDelay[i];
        std::cout << std::endl;
    }
    
}

// Prints detailed information about each source
void FDMAQueue::printQueues(){
    for (int i = 0; i < _nSources; ++i) {
        std::cout << "Source " << i << std::endl;
        _queues[i]->print();
    }
}

// Exports age data into different files
bool FDMAQueue::exportData(const std::string& filename){
    bool ret = true;
    std::string fullFile;
    for (int i = 0; i < _nSources; ++i) {
        fullFile = filename + "_Source" + std::to_string(i) + ".csv";
        ret = _queues[i]->exportData(fullFile);
    }

    return ret;
}

// Returns average age array for all sources
double* FDMAQueue::getAvgAge(){
    return _avgAge;
}

// Return average age value for specified source
double FDMAQueue::getAvgAge(int source){
    return _avgAge[source];
}

// Returns average delay array for all sources
double* FDMAQueue::getAvgDelay(){
    return _avgDelay;
}

// Return average delay for specified source
double FDMAQueue::getAvgDelay(int source){
    return _avgDelay[source];
}

