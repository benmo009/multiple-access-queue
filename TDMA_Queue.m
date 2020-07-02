% Age of Information Simulation
% Simulate multi source, M/M/1 FCFS Queue
% using a TDMA service policy
% For n sources, allocate n different slots that the server will cycle
% through. For each slot, the server will only serve one source and ignore
% all other sources

clc
clear all
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
mu = 30;

%% Tranmission Times for each Source
% Generate vector of when transmissions occurred for each source
% Represented as a vector of length(t) that is 1 when a packet is sent, 
% and 0 when there is no packet.
event = zeros(numSources,length(t));
numEvents = zeros(numSources,1);
figure
hold on

for i=1:numSources
    % Generate tranmission times for each source
    event(i,:) = GenerateTransmissions(lambda(i), t, true);
    
    % Count the number of transmissions for each source
    numEvents(i) = sum(event(i,:)); 
end

totalEvents = sum(numEvents);

% Record the time each packet was sent
% Stores the source number in the top row, and the time sent in the second
% row.
timeTransmit = zeros(2, totalEvents); 
count = 0;
% Iterate through each time step and each source
for i=1:length(event)
    for j=1:numSources
        % A packet was sent
        if event(j,i) == 1
            count = count + 1;
            timeTransmit(1, count) = j;  % record which source it came from
            timeTransmit(2,count) = t(i);  % record the time it arrived
        end
    end
end

eventPerSecond = numEvents./tFinal;  % check how close to lambda

%% Create Vector of Service Slots
% Set slot width
% Probability of packet arriving is P = 1 - e^(-lambda*t)
probability = 0.5;  % Desired probability that a packet is sent during a slot
slotDuration = -log(1-probability)./lambda;  % Calculate time from 
% Take the larger of the calculated durations
slotDuration = max(slotDuration);
slotDuration = round(slotDuration/dt) * dt;  % round to same order as time step
%mu*exp(-mu*t)

%% Calculate when each packet is served
%{
serverBusy = false
S = 0;
W = 0;
prevPacket = 0;
timeRecieve = [];
for i=1:totalEvents
    packet = timeTransmit(:,i);
    % Check if the packet arrived during the correct slot
    if CheckSlot(packet, numSources, slotDuration)
        if packet(2) > S + W + prevPacket  % the server is idle
            % Generate value for S
            S = exprnd(mu);
            % Add the source and the total time to timeRecieve
            recievedPacket = [packet(1); packet(2) + S + W];
            timeRecieve = [timeRecieve, recievedPacket];
            % Save the previous packets transmit time
            prevPacket = packet(2);
        else  % The server is busy
            % Set the wait timer
            W = timeRecieve(2,i-1) - packet(2);
            S = exprnd(mu);
            if (S + W + packet(2)
        
%}    
%% Age of Information

initialAge = 0;  % Initial age. (2 seconds)
age = initialAge + dt*(0:length(t)-1);
one = ones(numSources, 1);
age = one*age;
figure(2)
for i=1:numSources
    subplot(numSources,1,i);
    plot(t, age(i,:));
end

% Round t and timeRecieve
t = round(t./dt).*dt;
timeTransmit = round(timeTransmit./dt).*dt;

% Preallocate queue
queue = zeros(numSources, max(numEvents));
queueSize = zeros(numSources,1);
queueLocation =zeros(numSources,1);

prevPacket = 0;
prevSource = 1;
S = 0;
W = 0;
% loop through each time step
for i = 1:length(t)
    % Update the age if server just finished
    if ( abs( t(i) - (prevPacket + S + W) ) <= 1e-9 )
        % Update Age
        packetAge = S + W;
        diff = max(0, age(prevSource,i) - packetAge);
        age(prevSource,i:length(age)) = age(prevSource,i:length(age)) - diff;
        figure(2)
        subplot(numSources,1,prevSource);
        plot(t,age(prevSource,:));
    end
    % A packet arrives at the queue at current time step
    if(ismember(t(i), timeTransmit(2,:)))
        % Check if the source matches the slot
        packetIndex = find(timeTransmit(2,:) == t(i));
        packet = timeTransmit(:,packetIndex);
        source = packet(1);
        timestamp = packet(2);
        if (CheckSlot(packet, numSources, slotDuration))
            % Packet arrived at correct slot
            % check if the server is busy
            if timestamp >= (prevPacket + S + W)
                % server is idle
                % Serve the packet
                S = round(exprnd(mu)/dt) * dt;
                prevPacket = timestamp;
                prevSource = source;
            elseif timestamp == (prevPacket + S + W)
                % Server just finished a packet
                % Put this packet into the queue
                queueIndex = queueLocation(source) + 1;
                queue(source, queueIndex) = timestamp;
                queueLocation(source) = queueLocation(source) + 1;
                queueSize(source) = queueSize(source) + 1;
                % Get the first packet from the queue
                [packet,queue] = RemoveFromQueue(queue, serveSource);
                queueSize(serveSource) = queueSize(serveSource) - 1;
                S = round(exprnd(mu)/dt) * dt;
                W = t(i) - packet(2);
                prevPacket = timestamp;
                prevSource = source;
                    
            else
                % server is busy
                % add the packet to the queue
                queueIndex = queueLocation(source) + 1;
                queue(source, queueIndex) = timestamp;
                queueLocation(source) = queueLocation(source) + 1;
                queueSize(source) = queueSize(source) + 1;
            end
        else
            % Packet arrived at wrong slot
            % Store the packet into the queue
            queueIndex = queueLocation(source) + 1;
            queue(source, queueIndex) = timestamp;
            queueLocation(source) = queueLocation(source) + 1;
            queueSize(source) = queueSize(source) + 1;
        end
    else
        % No new packet
        % Find which source is being served at the current time
        slotNumber = fix(t(i)/slotDuration);
        serveSource = mod(slotNumber, numSources) + 1;
        % Check if the queue is empty
        if ( queueSize(serveSource) == 0 )
            % its empty
            continue;
        else  % its not empty                
            if (t(i) >= prevPacket + S + W)
                % server is idle
                % Get the first packet in the queue
                [packet,queue] = RemoveFromQueue(queue, serveSource);
                queueSize(serveSource) = queueSize(serveSource) - 1;
                % Start serving that packet
                S = round(exprnd(mu)/dt) * dt;
                W = t(i) - packet(2);
                prevPacket = packet(2);
                prevSource = packet(1);
            else
                % Server is still busy
                continue;
            end
        end
    end
end

avgAge = sum(age,2)./length(age);
figure(2)

for i=1:numSources
    subplot(numSources,1,i)
    hold on
    plot(t,avgAge(i).*ones(size(t)));
    legend('Age', ['Avg. Age = ', num2str(avgAge(i), 4)]);
end
