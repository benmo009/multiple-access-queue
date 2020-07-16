% TDMA_Vary_Time_Slot.m 
% Runs multiple iterations of the TDMA simulation, varying the slot duration as
% a function of probability

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

% Define various probabilities to try
probability = [0.1:0.05:0.9];
numSimulations = 100;

% Vectors to store the averages of each probability
avgAge = zeros(numSources, length(probability));
avgWait = zeros(size(probability));
stdDevAge = zeros(numSources, length(probability));
stdDevWait = zeros(size(probability));

% Vectors to store all of the simulation averages
simAvgAge = zeros(numSources, numSimulations);
simAvgWait = zeros(1, numSimulations);
simStdDevAge = zeros(numSources, numSimulations);
simStdDevWait = zeros(1, numSimulations);


for p = 1:length(probability)
    % Set slot width
    % Probability of packet arriving is P = 1 - e^(-lambda*t)
    slotDuration = -log(1 - probability(p)) ./ lambda; % Calculate time from
    % Take the larger of the calculated durations
    slotDuration = max(slotDuration);
    slotDuration = round(slotDuration / dt) * dt; % round to same order as time step

    for i = 1:numSimulations
        [simAvgAge(:,i), simAvgWait(i)] = TDMA(tFinal, dt, numSources, slotDuration, lambda, mu);
    end

    avgAge(:,p) = sum(simAvgAge,2) ./ numSimulations;
    stdDevAge(:,p) = std(simAvgAge, 0, 2);
    avgWait(p) = sum(simAvgWait) ./ numSimulations;
    stdDevWait(p) = std(simAvgWait);

end

% Plot Avg Age
for i = 1:numSources
    figure
    %plot(probability, avgAge(i,:));
    err = stdDevAge(i,:) ./ sqrt(numSimulations);
    errorbar(probability, avgAge(i,:), err);

    title(['Avg Age vs. Slot Duration Probability for Source ', num2str(i)]);
    xlabel('Probability');
    ylabel('Avg Age');
end

% Plot Avg Wait
figure
%plot(probability, avgWait);
stdDevWait
err = stdDevWait ./ sqrt(numSimulations)
errorbar(probability, avgWait, err);

title('Avg Wait vs. Slot Duration Probability');
xlabel('Probability');
ylabel('Avg Wait Time');

