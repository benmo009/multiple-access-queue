% FDMA.m
% Function for running the FDMA simulation multiple times more easily. Input the
% total simulation time, timestep, number of sources, average rate of packet
% arrivals (lambda), and average service rate (mu). Lambda and mu should be in
% the form of a vector thats length matches the number of soures. Outputs the
% average age over the duration of the simulation and the average wait time in
% the queue

function [avgAge, avgWait] = FDMA(tFinal, dt, numSources, lambda, mu, plotResult)
    % Set plotResult to false if it wasn't given
    if nargin == 5
        plotResult = false;
    end

    % Initialize vectors for storing average age and wait times
    avgAge = zeros(numSources, 1);
    avgWait = zeros(numSources, 1);

    % Simulate the queue for each source
    for i = 1:numSources
        [avgAge(i), avgWait(i)] = SimulateAoI(tFinal, dt, lambda(i), mu(i), plotResult, i);
    end
end