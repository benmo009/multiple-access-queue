% Age of Information Simulation
% Simulate multi source, M/M/1 FCFS Queue
% using a FDMA service policy
% For n sources, use n separate queues and servers to serve each source at
% the same time

clc
close all

%% Set Simulation Parameters
% Define step size and simulation duration (seconds)
dt = 0.1;
tFinal = (1)*1800;
% Create time vector
t = [0:dt:tFinal];  

% Define number of sources
numSources = 2;

% Set transmission rates for each source (packet/second)
lambda = zeros(numSources,1);
lambda(1) = 1/60;
lambda(2) = 1/45;

% Set average service time (seconds)
% Make sure the mu's sum up to be equal to the mu in the TDMA simulation
mu = zeros(numSources,1);
mu(1) = 1/60;
mu(2) = 1/60;

currentDir = pwd;
saveTo = [currentDir, '/../Data/FDMA_plots/'];

for i = 1:10
    [avgAge, avgWait] = FDMA(tFinal, dt, numSources, lambda, mu, true);
    for j = 1:numSources
        filename = sprintf('(%d)_FDMA_source_%d-of-%d.png', i, j, numSources);
        saveas(figure(j), [saveTo, filename]);
    end
    close all
end

