% SplitSlotTDMA.m 
% Simulates 2 source TDMA with different slot duration splitting strategies. For
% slot duration T, where T = 1/mu, split T using factor b such that source 1 is
% only served during time b*T and source 2 is only served during time (1-b) * T.

% We're gonna have to edit TDMA.m and CheckSLot.m to get this to work

clc 
close all

% Set simulation parameters
% Define step size and simulation duration (seconds)
dt = 0.1;
tFinal = 1800;

% Define number of sources
numSources = 2;

% Set transmission rates for each source (packet/second)
lambda = zeros(numSources, 1);
lambda(1) = 1/60;
lambda(2) = 1/45;

% Set average service rate (packet/seconds)
mu = 1/30;

% Slot duration
T = 1/mu;
b = linspace(0.05, 0.95, 200);  % Splitting factor

% Infinite queue
queueSize = Inf;

numSimulations = 100;
avgAge = zeros(numSources, size(b, 2));
avgWait = zeros(numSources, size(b, 2));

simAvgAge = zeros(numSources, numSimulations);
simAvgWait = zeros(numSources, numSimulations);
