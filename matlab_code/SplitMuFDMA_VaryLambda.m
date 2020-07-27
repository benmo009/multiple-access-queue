% SplitMuFDMA_VaryLambda.m
% Simulates FDMA with different splitting of mu, as well as with different
% combinations of arrival rates for 2 sources. Collect the value, b, that
% results in the smallest difference in average age between the two sources

clc
close all

% Set simulation parameters
% Define step size and simulation duration (seconds)
dt = 0.1;
tFinal = 1800;

% Define number of sources
numSources = 2;

% Set vector of transmission rates to simulate (packet/second)
lambdaVec = linspace(0.015, 0.04, 10);

% Set average service rate (packet/seconds)
mu = 1/30;
b = [0.05:0.05:0.95]; %linspace(0.05, 0.05, 30);

numSimulations = 50;

lambdaCombinations = size(lambdaVec,2) ^ 2;
possibleCombinations = lambdaCombinations * size(b,2);

avgAge = zeros(numSources, size(b,2));
simAvgAge = zeros(numSources, numSimulations);

bestB = zeros(1, lambdaCombinations);
minDiff = zeros(1, lambdaCombinations);

tic

muVec = zeros(numSources, 1);
count = 1;

% Go through each combination of lambda
for lambda1 = 1:size(lambdaVec,2)
    for lambda2 = 1:size(lambdaVec,2)
        % Set lambda values
        lambda = [lambdaVec(lambda1); lambdaVec(lambda2)];
        
        % Go through each b value
        for i = 1:size(b,2)
            % Set mu values based off b
            muVec(1) = b(i) * mu;
            muVec(2) = (1 - b(i)) * mu;
            % Simulate FDMA
            for j = 1:numSimulations
                [simAvgAge(:, j), avgWait, served] = FDMA(tFinal, dt, numSources, lambda, muVec, Inf);
            end
            % Calculate the average age for each b
            avgAge(:, i) = sum(simAvgAge,2) ./ numSimulations;
        end

        % Find best b value where difference in age is smallest
        diff = abs( avgAge(1,:) - avgAge(2,:) );
        idx = find(diff == min(diff));
        minDiff(count) = min(diff);
        bestB(count) = b(idx);
        count = count + 1;
    end
end

% Plot the best b values for each lambda
bSurf = reshape(bestB, [size(lambdaVec,2), size(lambdaVec,2)]);
surf(lambdaVec, lambdaVec, bSurf);
xlabel('\lambda_1');
ylabel('\lambda_2');
zlabel('Best b value');

save SplitMuFDMA_VaryLambda_results.mat lambdaVec bestB minDiff

toc
