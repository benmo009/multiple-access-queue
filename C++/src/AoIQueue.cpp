#include "AoIQueue.h"


AoIQueue::AoIQueue() {
    init();
}


AoIQueue::AoIQueue(double end, double dt, double lam, double m) {
    init();

    // Assign member variables
    _tFinal = end;
    _tStep = dt;
    _lambda = lam;
    _mu = m;

    // Generate number of packet arrivals
    _nEvents = 0;
    while (_nEvents == 0) {
        GenerateNumEvents();
    }
    

    // Generate arrival times for each packet
    GenerateArrivals();

    // Generate service times for each packet
    GenerateServiceTimes();

    // Calculate when each packet is finished being served
    CalculatePacketServed();
   
    // Cut of simulation time to when the last packet was served. This might
    // balance simulations where packets stop being served early on in the
    // simulation
    _tFinal = _timeFinished[_nEvents-1];

    // Calculate the amount of steps in the simulation
    _nIntervals = (_tFinal / _tStep) + 1;

    CalculateAge();
}

AoIQueue::~AoIQueue() {
    clear();
}

// Initializes member variables
void AoIQueue::init() {
    // Initialize pointers to NULL
    _timeArrived = NULL;
    _timeFinished = NULL;
    _packetAge = NULL;
    _serviceTime = NULL;
    _delayTime = NULL;
    _age = NULL;
    _time = NULL;
}

void AoIQueue::clear() {
    // Delete all dynamically allocated arrays
    if (_timeArrived != NULL) { delete [] _timeArrived; }
    if (_timeFinished != NULL) { delete [] _timeFinished; }
    if (_packetAge != NULL) { delete [] _packetAge; }
    if (_serviceTime != NULL) { delete [] _serviceTime; }
    if (_delayTime != NULL) { delete [] _delayTime; }
    if (_age != NULL) { delete [] _age; }
    if (_time != NULL) { delete [] _time; }
}

void AoIQueue::allocateArrays() {
    // Allocate arrays based on number of arrivals
    _timeArrived = new double[_nEvents];
    _timeFinished = new double[_nEvents];
    _packetAge = new double[_nEvents];
    _serviceTime = new double[_nEvents];
    _delayTime = new double[_nEvents];
}

void AoIQueue::GenerateNumEvents() {
    // Expected number of events based on lambda and total simulation time
    int expectedEvents = _tFinal * _lambda;

    // Create random number generator
    std::random_device rd;
    std::mt19937 generator (rd());

    std::poisson_distribution<int> poissonDist(expectedEvents);

    // Generate number of transmission events
    _nEvents = poissonDist(generator);

    // Allocate all arrays that are of size _nEvents
    allocateArrays();
}

void AoIQueue::GenerateArrivals() {
    // Create random number generator based off exponential distribution 
    std::random_device rd;
    std::mt19937 generator (rd());

    std::exponential_distribution<double> expDist(_lambda);

    // Generate timestamps of arrivals for each packet
    for (int i = 0; i < _nEvents; ++i) {
        // Generate time since last packet using exponential distribution
        double timestamp = expDist(generator);
        // Round to match step size precision
        timestamp = round(timestamp / _tStep) * _tStep;

        // Add to arrivals vector
        if (i == 0){ // First packet
            _timeArrived[i] = timestamp;
        }
        else { // Add up the times to get the timestamp an arrival happened
            _timeArrived[i] = timestamp + _timeArrived[i-1];
        }
    }
}

void AoIQueue::GenerateServiceTimes() {
    // Create random number generator based off exponential distribution 
    std::random_device rd;
    std::mt19937 generator (rd());

    std::exponential_distribution<double> expDist(_mu);

    // Generate timestamps of arrivals for each packet
    for (int i = 0; i < _nEvents; ++i) {
        // Generate time since last packet using exponential distribution
        double timestamp = expDist(generator);

        // Round to match step size precision
        timestamp = round(timestamp / _tStep) * _tStep;

        // Add to arrivals vector
        _serviceTime[i] = timestamp;
    }
}

void AoIQueue::CalculatePacketServed() {
    // Calculate time first packet finished being served
    _delayTime[0] = 0;
    _timeFinished[0] = _timeArrived[0] + _delayTime[0] + _serviceTime[0];
    _packetAge[0] = _timeFinished[0] - _timeArrived[0];

    // Sum of all delay times to calculate average delay
    double sumDelay = 0;

    for (int i = 1; i < _nEvents; ++i) {
        if (_timeArrived[i] >= _timeFinished[i-1]) {
            _delayTime[i] = 0;
        }
        else {
            _delayTime[i] = _timeFinished[i-1] - _timeArrived[i];
        }

        sumDelay += _delayTime[i];
        _timeFinished[i] = _timeArrived[i] + _delayTime[i] + _serviceTime[i];
        _packetAge[i] = _timeFinished[i] - _timeArrived[i];
    }

    // Store the average delay
    _avgDelay = sumDelay / _nEvents;
}

void AoIQueue::CalculateAge() {
    // Allocate age and time arrays
    _age = new double[_nIntervals];
    _time = new double[_nIntervals];

    // Set the initial age
    _age[0] = 0;
    double sumAge = 0;

    // Pointers to keep track of the current packet
    double* currentPacket = _timeFinished;
    double* currentAge = _packetAge;

    // Iterate through each time step
    for (int i = 0; i < _nIntervals; ++i) {
        // Record the current time
        _time[i] = i * _tStep;

        // Increase the age by _tStep
        if (i > 0) {
            _age[i] = _age[i-1] + _tStep;
        }

        // Check if a packet is done being served at the current time
        double timeToPacket = _time[i] - *currentPacket;
        double cutoff = _tStep / 10;
        if ( (timeToPacket < cutoff) && (timeToPacket > -cutoff)) {
            // Decrease the age at current time to the age of the new packet
            _age[i] = *currentAge;

            // Increment the pointers
            currentPacket++;
            currentAge++;
        }

        sumAge += _age[i];
    }

    // Store the avgerage age
    _avgAge = sumAge / _nIntervals;
}

void AoIQueue::print() {
    std::cout << "Total number of events: " << _nEvents << std::endl;
    std::cout << "lambda: " << _lambda << std::endl;
    std::cout << "    mu: " << _mu << std::endl;
    // Print data
    std::cout << std::endl;
    std::cout << std::setw(10) << "Arrival";
    std::cout << std::setw(10) << "Service";
    std::cout << std::setw(10) << "Delay";
    std::cout << std::setw(10) << "Served";
    std::cout << std::setw(10) << "Age";
    
    std::cout << std::endl;
    for (int i = 0; i < _nEvents; ++i) {
        std::cout << std::setw(10) << _timeArrived[i];
        std::cout << std::setw(10) << _serviceTime[i];
        std::cout << std::setw(10) << _delayTime[i];
        std::cout << std::setw(10) << _timeFinished[i];
        std::cout << std::setw(10) << _packetAge[i];
        std::cout << std::endl;
    }

    std::cout << std::endl;

    std::cout << "Average Age = " << _avgAge << std::endl;
    std::cout << "Average Delay = " << _avgDelay << std::endl;
    std::cout << std::endl;
}

bool AoIQueue::exportData(const std::string& filename) {
    std::ofstream outFile(filename);
    if (!outFile.good()) {
        std::cerr << "Could not open " << filename << " to write" << std::endl;
        return false;
    }

    outFile << "time,age,avgAge" <<std::endl;

    for (int i = 0; i < _nIntervals; ++i) {
        outFile << _time[i] << "," << _age[i] << "," << _avgAge << std::endl;
    }

    return true;
}