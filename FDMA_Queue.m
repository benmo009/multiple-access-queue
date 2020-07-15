% Age of Information Simulation
% Simulate multi source, M/M/1 FCFS Queue
% using a FDMA service policy
% For n sources, use n separate queues and servers to serve each source at
% the same time

clc
close all

%% Set Simulation Parameters
% Define step size and simulation duration (seconds)
dt = 0.1;
tFinal = (1)*1800;
% Create time vector
t = [0:dt:tFinal];  

% Define number of sources
numSources = 2;

% Set transmission rates for each source (packet/second)
lambda = zeros(numSources,1);
lambda(1) = 1/60;
lambda(2) = 1/45;

% Set average service time (seconds)
% Make sure the mu's sum up to be equal to the mu in the TDMA simulation
mu = zeros(numSources,1);
mu(1) = 15;
mu(2) = 15;

%% Tranmission Times for each Source
% Generate vector of when transmissions occurred for each source
% Represented as a vector of length(t) that is 1 when a packet is sent, 
% and 0 when there is no packet.
event = zeros(numSources,length(t));
numEvents = zeros(numSources,1);
timeTransmit = cell(numSources,1);
S = cell(size(timeTransmit));
W = cell(size(timeTransmit));
timeRecieved = cell(size(timeTransmit));
packetAge = cell(size(timeTransmit));

lastRecieved = zeros(numSources,1);

for i=1:numSources
    % Generate tranmission times for each source
    event(i,:) = GenerateTransmissions(lambda(i), t);
    
    % Find when events happened and store the time stamps
    timeTransmit{i} = find(event(i,:) ==1);
    timeTransmit{i} = (timeTransmit{i} - 1) .* dt;
    
    % Generate Service Times
    S{i} = exprnd(mu(i), size(timeTransmit{i}));
    
    % initialize W and timeRecieved vectors
    W{i}(1) = 0;  % first wait time is 0 because the queue will always be empty
    timeRecieved{i}(1) = timeTransmit{i}(1) + W{i}(1) + S{i}(1); % calculate when the first packet is recieved
    
    % Count the number of transmissions for each source
    numEvents(i) = sum(event(i,:)); 
    
    % Calculate packet ages and recieved times
    for j=2:numEvents(i)
        if timeTransmit{i}(j) >= timeRecieved{i}(j-1)
            W{i}(j) = 0;
        elseif timeTransmit{i}(j) < timeRecieved{i}(j-1)  % The server is still serving packet i-1
            W{i}(j) = timeRecieved{i}(j-1) - timeTransmit{i}(j);
        end
    timeRecieved{i}(j) = timeTransmit{i}(j) + W{i}(j) + S{i}(j);
    end
    
    % Calculate age of a packet at time of recieved
    packetAge{i} = timeRecieved{i} - timeTransmit{i};
    
    % Update time vector
    lastRecieved(i) = max(timeRecieved{i});
    
    % Round the vectors
    timeRecieved{i} = round(timeRecieved{i}./dt) .* dt;
end

totalEvents = sum(numEvents);
eventPerSecond = numEvents./tFinal;  % check how close to lambda

% Update the length of the time vector in case a packet was recieved later
% than the max time point
if (max(lastRecieved) > tFinal) 
    tFinal = max(lastRecieved) + dt;
    t = [0:dt:tFinal];
end
t = round(t./dt) .* dt;

%% Calculate the Age of Information
initialAge = 0;
age = initialAge + dt*(0:length(t)-1);
one = ones(numSources, 1);
age = one*age;

figure
set(gcf,'position', [369,376,935,494]);

% Calculate age for each source
for i = 1:numSources
    % Iterate through each packet that was recieved
    for j = 1:length(timeRecieved{i})
        % Calculate how much to reduce the age based on the age of the
        % newly recieved packet
        ageIndex = uint32((timeRecieved{i}(j) / dt) + 1);
        diff = age(i, ageIndex) - packetAge{i}(j);
        % Decrease the age from the time the packet was recieved to the end
        % of the vector
        age(i,ageIndex:length(age)) = age(i,ageIndex:length(age)) - diff;
    end
    
    % Calculate Average Age
    avgAge = sum(age(i,:))/length(age(i,:));
    subplot(2,1,i)
    plot(t, age(i,:));
    hold on
    plot(t, avgAge.*ones(size(t)));
    xlabel('time (s)');
    ylabel('age (s)');
    title(['Source ', num2str(i), ', lambda = ', rats(lambda(i))]);
    legend('Location', 'northwest')
    legend('Age', ['Avg. Age = ', num2str(avgAge, 4)]);
end


