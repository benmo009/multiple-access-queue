% SplitSlotTDMA_VaryLambda.m 
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
lambda_1 = linspace(0.01, 0.06, 10);
lambda_2 = 1/45;

% Set average service rate (packet/seconds)
mu = 1/30;

% Slot duration
T = 1/mu;
b = linspace(0.15, 0.85, 50);  % Splitting factor
bestB = zeros(1, length(lambda_1));

% Infinite queue
queueSize = Inf;

numSimulations = 100;
avgAge = zeros(numSources, size(b, 2));
avgWait = zeros(numSources, size(b, 2));

simAvgAge = zeros(numSources, numSimulations);
simAvgWait = zeros(numSources, numSimulations);

tic
slotDuration = zeros(numSources, 1);
for k = 1:length(lambda_1)
    lambda(1) = lambda_1(k);
    lambda(2) = lambda_2;
    for i = 1:length(b)
        slotDuration(1) = b(i) * T;
        slotDuration(2) = (1 - b(i)) * T;
        for j = 1:numSimulations
            [simAvgAge(:,j), simAvgWait(:,j)] = TDMA(tFinal, dt, numSources, slotDuration, lambda, mu);
        end
        avgAge(:,i) = sum(simAvgAge,2) ./ numSimulations;
        avgWait(:,i) = sum(simAvgWait,2) ./ numSimulations;
    end

    diffAge = abs(avgAge(1, :) - avgAge(2, :));
    idx = find(diffAge == min(diffAge));
    bestB(k) = b(idx);
end
toc

figure
plot(lambda_1, bestB)