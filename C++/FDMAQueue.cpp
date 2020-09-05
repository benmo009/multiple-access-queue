#include "FDMAQueue.h"
#include "AoIQueue.h"

FDMAQueue::FDMAQueue() {
    _nSources = 0;
    _queues = NULL;

    _lambda = NULL;
    _mu = 0;
    _b = NULL;

    _avgAge = NULL;
    _avgDelay = NULL; 
}

FDMAQueue::FDMAQueue(int sources, double* lambda, double mu, double* b, double tFinal, double dt) {
    _queues = NULL;
    _lambda = NULL;
    _avgAge = NULL;
    _avgDelay = NULL;
    _b = NULL;


    _nSources = sources;
    _lambda = lambda;
    _mu = mu;
    _b = b;


    _queues = new AoIQueue*[_nSources];
    _avgAge = new double[_nSources];
    _avgDelay = new double[_nSources];

    for (int i = 0; i < _nSources; ++i) {
        _queues[i] = new AoIQueue(tFinal, dt, _lambda[i], _b[i]*_mu);
        _queues[i]->print();
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