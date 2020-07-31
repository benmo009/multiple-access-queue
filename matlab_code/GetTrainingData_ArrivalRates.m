clc
close all


tFinal = 1800;
dt = 0.01;

muVec = [0.015:0.0025:0.05];
lambdaVec = [0.005:0.005:0.06];

numSimulations = 100;

possibleCombinations = size(muVec,2) * size(lambdaVec,2);
totalExamples = possibleCombinations * numSimulations;

X = zeros(totalExamples, 2);
y = zeros(totalExamples, 1);

tic

count = 1;
for i = 1:size(muVec,2)
    for j = 1:size(lambdaVec,2)
        for k = 1:numSimulations
            X(count, 1) = muVec(i);  % First column is mu value
            X(count, 2) = lambdaVec(j);  % Second column is lambda value
            [y(count), avgWait] = SimulateAoI(tFinal, dt, lambda, mu);
            count = count + 1;
        end
    end
end

toc

save SingleSource_TrainingData.mat X y
