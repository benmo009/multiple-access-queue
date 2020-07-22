% Age of Information Simulation
% Simulate multi source, M/M/1 FCFS Queue
% using a TDMA service policy
% For n sources, allocate n different slots that the server will cycle
% through. For each slot, the server will only serve one source and ignore
% all other sources

clc
close all
tic

%% Set Simulation Parameters
% Define step size and simulation duration (seconds)
dt = 0.1;
tFinal = 1800;

% Define number of sources
numSources = 2;

% Set transmission rates for each source (packet/second)
lambda = zeros(numSources,1);
lambda(1) = 1/60;
lambda(2) = 1/45;

% Set priority on each source
priority = zeros(numSources, 1);
priority(1) = 1;
priority(2) = 2;

% Set average service rate (packet/seconds)
mu = 1/30;
%mu = mean(lambda);

% Set slot width
% Probability of packet arriving is P = 1 - e^(-lambda*t)
probability = 0.6;  % Desired probability that a packet is sent during a slot
slotDuration = -log(1-probability)./lambda;  % Calculate time from 
% Take the larger of the calculated durations
slotDuration = max(slotDuration);
slotDuration = round(slotDuration/dt) * dt;  % round to same order as time step
%mu*exp(-mu*t)


currentDir = pwd;
saveTo = [currentDir, '/../Data/TDMA_plots/'];

for i = 1:1
    [avgAge, avgWait] = TDMA(tFinal, dt, numSources, slotDuration, lambda, mu, priority, true);
    for j = 1:numSources
        filename = sprintf('(%d)_TDMA_source_%d-of-%d.png', i, j, numSources);
        saveas(figure(j), [saveTo, filename]);
    end
    close all
end


toc
