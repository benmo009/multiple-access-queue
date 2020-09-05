#ifndef AoIQueue_h_
#define AoIQueue_h_

#include <iostream>
#include <random>
#include <vector>
#include <iomanip>
#include <fstream>
#include <string>

class AoIQueue {
public:
    AoIQueue();
    AoIQueue(double end, double dt, double lam, double m);

    ~AoIQueue();

    void print();
    bool exportData(const std::string& filename);
    double getAvgAge() { return _avgAge; }
    double getAvgDelay() { return _avgDelay; }

    void reroll();

private:
    void GenerateNumEvents();
    void GenerateArrivals();
    void GenerateServiceTimes();
    void CalculatePacketServed();
    void CalculateAge();

    void init();
    void clear();
    void allocateArrays();

    double _tFinal;
    double _tStep;

    double _lambda;
    double _mu;

    int _nEvents;
    double* _timeArrived;
    double* _timeFinished;
    double* _packetAge;

    double* _serviceTime;
    double* _delayTime;

    double* _age;
    double* _time;
    int _nIntervals;

    double _avgAge;
    double _avgDelay;


};


#endif