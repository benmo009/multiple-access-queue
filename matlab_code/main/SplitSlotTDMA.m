% SplitSlotTDMA.m 
% Simulates 2 source TDMA with different slot duration splitting strategies. For
% slot duration T, where T = 1/mu, split T using factor b such that source 1 is
% only served during time b*T and source 2 is only served during time (1-b) * T.

% We're gonna have to edit TDMA.m and CheckSLot.m to get this to work

clc 
%close all

% Set simulation parameters
% Define step size and simulation duration (seconds)
dt = 0.1;
tFinal = 1800;

% Define number of sources
numSources = 2;

% Set transmission rates for each source (packet/second)
lambda = zeros(numSources, 1);

lambda(1) = 1/45;
lambda(2) = 1/45;

% Set average service rate (packet/seconds)
mu = 1/30;

% Slot duration
T = 5/mu;
b = linspace(0.25, 0.75, 100);

numSimulations = 1000;
avgAge = zeros(numSources, size(b, 2));
avgWait = zeros(numSources, size(b, 2));

simAvgAge = zeros(numSources, numSimulations);
simAvgWait = zeros(numSources, numSimulations);

tic
slotDuration = zeros(numSources, 1);
for i = 1:length(b)
    slotDuration(1) = b(i) * T;
    slotDuration(2) = (1 - b(i)) * T;
    for j = 1:numSimulations

		fprintf("%d out of %d\r", [j, i])
        [simAvgAge(:,j), simAvgWait(:,j)] = TDMA(tFinal, dt, numSources, slotDuration, lambda, mu);
        %[simAvgAge(:,j), simAvgWait(:,j)] = TDMA_with_slot_end_correction(tFinal, dt, numSources, slotDuration, lambda, mu);
    end
    avgAge(:,i) = sum(simAvgAge,2) ./ numSimulations;
    avgWait(:,i) = sum(simAvgWait,2) ./ numSimulations;
end
toc

figure
plot(b, avgAge(1,:), '.')
hold on
plot(b, avgAge(2,:), '.')
legend("Source 1, \lambda = 1/45", "Source 2, \lambda = 1/45")

xlabel('Slot splitting factor, b');
ylabel('Average Age (s)');

annotationStr = ['\mu = ', strtrim(rats(1/30))];
annotationStr = [annotationStr, ', Slot (T) = 5/\mu'];
annotationStr = {annotationStr, 'T_1 = b * T', 'T_2 = (1 - b) * T'};
annotation('textbox', [0.15 0.7, 0.2, 0.2], 'String', annotationStr, 'FitBoxToText', 'on', 'BackgroundColor', 'w')

figure
plot(b, avgWait(1,:), '.')
hold on
plot(b, avgWait(2,:), '.')
legend("Source 1, \lambda = 1/45", "Source 2, \lambda = 1/45")

xlabel("Slot Splitting Factor, b")
ylabel("Average Delay (s)")

annotation('textbox', [0.15 0.7, 0.2, 0.2], 'String', annotationStr, 'FitBoxToText', 'on', 'BackgroundColor', 'w')