// Class for simulating a FCFS m/m/1 queue and measuring the average age of each
// packet transmitted. 

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
    void exportTransmissions();

private:
    // Generates the number of events for the queue from a binomial distribution
    void GenerateNumEvents();  

    // Generates a vector of packet arrival times from exponential distribution
    void GenerateArrivals();

    // Generates a vector of service times from exponential distribution
    void GenerateServiceTimes();

    // Calculates when packets get finished serving
    void CalculatePacketServed();

    // Calculates the age of each packet after they get served
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