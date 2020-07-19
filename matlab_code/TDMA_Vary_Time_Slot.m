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

% Calculate Slot Durations to try
invLambda = 1./lambda;
slotDuration = invLambda * (-log(1 - probability));
slotDuration = round(slotDuration ./ dt) .* dt;
slotSource = 1;

<<<<<<< HEAD
numSimulations = 10;
=======
numSimulations = 200;
>>>>>>> dev

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

tic

for p = 1:length(probability)

    for i = 1:numSimulations
        [simAvgAge(:,i), simAvgWait(i)] = TDMA(tFinal, dt, numSources, slotDuration(slotSource, p), lambda, mu);
    end

    avgAge(:,p) = sum(simAvgAge,2) ./ numSimulations;
    stdDevAge(:,p) = std(simAvgAge, 0, 2);
    avgWait(p) = sum(simAvgWait) ./ numSimulations;
    stdDevWait(p) = std(simAvgWait);

end

toc

% Add information about the simulation in a text box on the plot
str = sprintf('%d sources\n', numSources);
str = [str, '\lambda = [ '];
for i = 1:numSources
    str = [str, strtrim(rats(lambda(i))), ' '];
end
str = [str, ']'];
str = [str, sprintf('\n')];
str = [str, '\mu = ', strtrim(rats(mu))];

% Set Directory to save the plots to
currentDir = pwd;
newFolder = sprintf('../Data/Time_Slot_Simulations/%d_Simulations/', numSimulations);
if ~exist(newFolder, 'dir')
    mkdir(newFolder);
end
saveTo = [currentDir, '/' , newFolder];

% Make plots for each source
for i = 1:numSources
    % Plot the average age vs. the probability 
    figure
    set(gcf, 'position', [369, 376, 935, 494]);
    err = stdDevAge(i,:) ./ sqrt(numSimulations);
    errorbar(probability, avgAge(i,:), err, '.', 'MarkerSize', 10);
    % Add labels and annotation
    title(['Avg Age vs. Slot Duration Probability for Source ', num2str(i)]);
    xlabel(['Probability, (calculated from source ', num2str(slotSource), ' arrival rate)']);
    ylabel('Avgerage Age (s)');
    annotation('textbox', [0.15 0.75, 0.18, 0.12], 'String', str, 'FitBoxToText', 'on')
    % Save the figure
    filename = sprintf('%d_TDMA_Age_vs_Prob_source%d.png', slotSource, i);
    saveas(figure(1), [saveTo, filename]);
    close all

    % Plot the average age vs. the slot duration
    figure
    set(gcf, 'position', [369, 376, 935, 494]);
    errorbar(slotDuration(slotSource,:), avgAge(i,:), err, '.', 'MarkerSize', 10);
    % Add labels and annotation
    title(['Avg Age vs. Slot Duration for Source ', num2str(i)]);
    xlabel(['Slot Duration (s), (calculated from source ', num2str(slotSource), ' arrival rate)']);
    ylabel('Avgerage Age (s)');
    annotation('textbox', [0.15 0.75, 0.18, 0.12], 'String', str, 'FitBoxToText', 'on')
    % Save the figure
    filename = sprintf('%d_TDMA_Age_vs_Slot_source%d.png', slotSource, i);
    saveas(figure(1), [saveTo, filename]);
    close all
end


% Plot Avg Wait vs. probability
figure
set(gcf, 'position', [369, 376, 935, 494])
errorbar(probability, avgWait, err, '.', 'MarkerSize', 10);
% Add labels and annotation
title('Avg Delay vs. Slot Duration Probability');
xlabel(['Probability, (calculated from source ', num2str(slotSource), ' arrival rate)']);
ylabel('Avgerage Delay (s)');
annotation('textbox', [0.15 0.75, 0.18, 0.12], 'String', str, 'FitBoxToText', 'on')
% Save the plot
filename = sprintf('%d_TDMA_Delay_vs_Prob.png', slotSource);
saveas(figure(1), [saveTo, filename]);
close all

% Plot Avg Wait vs. Slot Duration
figure
set(gcf, 'position', [369, 376, 935, 494])
errorbar(probability, slotDuration(slotSource,:), err, '.', 'MarkerSize', 10);
% Add labels and annotations
title('Avg Delay vs. Slot Duration');
xlabel(['Slot Duration (s), (calculated from source ', num2str(slotSource), ' arrival rate)']);
ylabel('Avgerage Delay (s)');
annotation('textbox', [0.15 0.75, 0.18, 0.12], 'String', str, 'FitBoxToText', 'on')
% Save the plot
filename = sprintf('%d_TDMA_Delay_vs_SLot.png', slotSource);
saveas(figure(1), [saveTo, filename]);
close all
