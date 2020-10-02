% Single_Source_Arrival_Rates.m
% Simulate single source queue with varying arrival rates (lambda) to find the 
% rate that results in the best average age

clc 
close all

% Set Simulation Parameters
dt = 0.1;  % Simulation step size
tFinal = 1800;  % Simulation Duration
mu = 1/30;  % Service rate
numSimulations = 100;  % Number of simulations to run for each lambda

% Vector of lambdas
lambdaVec = [0.005:0.001:0.04];

% Vectors for storing data
avgAge = zeros(1, length(lambdaVec));
avgWait = zeros(1, length(lambdaVec));
stdDevAge = zeros(1, length(lambdaVec));
stdDevWait = zeros(1, length(lambdaVec));

simAvgAge = zeros(1, numSimulations);
simAvgWait = zeros(1, numSimulations);

tic

% Run simulation for each lambda
for i = 1:length(lambdaVec)
    lambda = lambdaVec(i);

    % Run the simulation numSimulations amount of times
    for j = 1:numSimulations
        [simAvgAge(j), simAvgWait(j)] = SimulateAoI(tFinal, dt, lambda, mu);
    end

    % Record the data collected
    avgAge(i) = sum(simAvgAge) / numSimulations;
    avgWait(i) = sum(simAvgWait) / numSimulations;
    stdDevAge(i) = std(simAvgAge);
    stdDevWait(i) = std(simAvgWait);
end

toc

% Shannon Capacity (mu * e^-1)
shannonCap = mu * (1/exp(1));

% Plot the average age vs lambda
figure
set(gcf, 'position', [369, 376, 935, 494])
err = stdDevAge ./ sqrt(numSimulations);
errorbar(lambdaVec, avgAge, err, '.', 'MarkerSize', 10);
hold on
xline(shannonCap, 'r');
xline(mu, 'g');
legend('Average Age', ['Shannon Capacity = ', num2str(shannonCap, 2)], ['\mu = ', num2str(mu, 2)]);
title('Average Age vs. Arrival Rate');
xlabel('Arrival Rate, \lambda (packet/second)');
ylabel('Average Age (s)');

% Plot the average delay vs lambda
figure
set(gcf, 'position', [369, 376, 935, 494])
err = stdDevWait ./ sqrt(numSimulations);
errorbar(lambdaVec, avgWait, err, '.', 'MarkerSize', 10);
hold on
xline(shannonCap, 'r');
xline(mu, 'g');
legend('Average Delay', ['Shannon Capacity = ', num2str(shannonCap, 2)], ['\mu = ', num2str(mu, 2)]);
title('Average Delay vs. Arrival Rate');
xlabel('Arrival Rate, \lambda (packet/second)');
ylabel('Average Delay (s)');
