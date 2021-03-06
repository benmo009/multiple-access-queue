% RunFDMA.m
% Simulate the FDMA queue multiple times to collect data

%clc
%close all

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
b = 0.5;
muVec = zeros(numSources, 1);
muVec(1) = b * mu;
muVec(2) = (1 - b) * mu;

numSimulations = 500;
avgAge = zeros(numSources, numSimulations);
avgWait = zeros(numSources, numSimulations);

tic

for i = 1:numSimulations
    [avgAge(:, i), avgWait(:, i)] = FDMA(tFinal, dt, numSources, lambda, muVec);
end

toc

totalAvgAge = sum(avgAge, 2) ./ numSimulations;
stdDevAge = std(avgAge, 0, 2);

totalAvgWait = sum(avgWait, 2) / numSimulations;
stdDevWait = std(avgWait, 0, 2);

fprintf('\nRan %d simulations for FDMA with %d sources.\n', numSimulations, numSources);
fprintf('Simulation time was %d seconds with step size %s\n', tFinal, strtrim(num2str(dt)));

fprintf('\nlambda:\n');
for i = 1:numSources
    fprintf('\tSource %d: %.4f (%s)\n', i, lambda(i), strtrim(rats(lambda(i))));
end

fprintf('mu:\n');
for i = 1:numSources
    fprintf('\tSource %d: %.4f (%s)\n', i, muVec(i), strtrim(rats(muVec(i))));
end

fprintf('\nDATA\n');
fprintf('Average Age:\n');

for i = 1:numSources
    fprintf('\tSource %d: %.2f, std dev = %.2f\n', i, totalAvgAge(i), stdDevAge(i));
end

fprintf('Average Delay:\n');

for i = 1:numSources
    fprintf('\tSource %d: %.2f, std dev = %.2f\n', i, totalAvgWait(i), stdDevWait(i));
end

for i = 1:numSources
    subplot(numSources, 1, i)
    plot([1:numSimulations], avgAge(i,:), '.');
    hold on
    plot([1:numSimulations], totalAvgAge(i).*ones(1, numSimulations))
    legend('Average Age for each simulation', sprintf('Overall Average Age = %.2f', totalAvgAge(i)));
    xlabel('Simulation Number');
    ylabel('Average Age (s)')
    title(sprintf('FDMA %d simulations, source %d', numSimulations, i))
end
