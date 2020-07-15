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
tFinal = (1)*60;

% Define number of sources
numSources = 2;

% Set transmission rates for each source (packet/second)
lambda = zeros(numSources,1);
lambda(1) = 1/20;
lambda(2) = 1/15;

% Set average service time (seconds)
mu = 1/20;

% Set slot width
% Probability of packet arriving is P = 1 - e^(-lambda*t)
probability = 0.6;  % Desired probability that a packet is sent during a slot
slotDuration = -log(1-probability)./lambda;  % Calculate time from 
% Take the larger of the calculated durations
slotDuration = max(slotDuration);
slotDuration = round(slotDuration/dt) * dt;  % round to same order as time step
%mu*exp(-mu*t)

[avgAge, stdDevAge, avgWait] = TDMA(tFinal, dt, numSources, slotDuration, lambda, mu, true);

toc
