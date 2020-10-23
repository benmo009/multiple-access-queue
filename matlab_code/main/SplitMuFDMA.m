% SplitMuFDMA.m
% Simulates 2 source FDMA using different splitting strategies for mu, using a 
% factor b where mu_1 = b*mu and mu_2 = (1-b)*mu so that mu_1 + mu_2 = mu.

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
lambda(1) = 0.0167;
lambda(2) = 0.025;

% Set average service rate (packet/seconds)
mu = 1/30;
b = linspace(0.25, 0.75, 100);

numSimulations = 1000;
avgAge = zeros(numSources, size(b,2));
avgWait = zeros(numSources, size(b,2));

simAvgAge = zeros(numSources, numSimulations);
simAvgWait = zeros(numSources, numSimulations);

tic
muVec = zeros(numSources, 1);
for i = 1
    muVec(1) = b(i) * mu;
    muVec(2) = (1 - b(i)) * mu;
    for j = 1:numSimulations
		fprintf("%d out of %d\r", [j, i])
        [simAvgAge(:,j), simAvgWait(:,j)] = FDMA(tFinal, dt, numSources, lambda, muVec);
    end
    avgAge(:,i) = sum(simAvgAge,2) ./ numSimulations;
    avgWait(:,i) = sum(simAvgWait,2) ./ numSimulations;
end
toc

save SplitMuFDMA_Results.mat avgAge b
plot(b, avgAge, '.');
xlabel('\mu splitting factor, b')
ylabel('Avgerage Age (s)')
legend('Source 1', 'Source 2');


annotationStr = ['\mu = ', strtrim(rats(mu))];
annotationStr = {annotationStr, '\mu_1 = b * \mu', '\mu_2 = (1 - b) * \mu'};

annotation('textbox', [0.15 0.7, 0.2, 0.2], 'String', annotationStr, 'FitBoxToText', 'on')

diffAge = abs( avgAge(1,:) - avgAge(2,:) );
idx = find(diffAge == min(diffAge));
bestB = b(idx);
