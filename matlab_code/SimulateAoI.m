% SimulateAoI.m
% Function to simulate a single source, first come first serve M/M/1 queue and
% returns the average age of information and wait time in queue.

function [avgAge, avgWait] = SimulateAoI(tFinal, dt, lambda, mu, plotResult, source)
    % If plotResult and source aren't given, set them to default values
    if nargin == 4
        plotResult = false;
        source = 0;
    end

    % Make time vector
    t = [0:dt:tFinal];

    % Generate vector of transmission times
    event = GenerateTransmissions(lambda, t);

    % Find timestamps of each event and store them
    timeTransmit = find(event == 1);
    timeTransmit = (timeTransmit - 1) .* dt;

    % Generate service times
    S = exprnd(1/mu, size(timeTransmit));
    S = round(S ./ dt) .* dt;

    % Initialize wait and timeRecieved vectors
    W = zeros(size(S));
    timeRecieved = zeros(size(S));
    timeRecieved(1) = timeTransmit(1) + W(1) + S(1);

    % Calculate wait times and when packets are done served
    numEvents = sum(event);
    for i = 2:numEvents
        % Packet i arrives after packet i-1 has been served
        if timeTransmit(i) >= timeRecieved(i-1)
            % Packet i doesn't have to wait
            W(i) = 0;
        % Packet i arrived before packet i-1 is done being served
        elseif timeTransmit(i) < timeRecieved(i-1)
            % Packet i has to wait until packet i-1 is done
            W(i) = timeRecieved(i-1) - timeTransmit(i);
        end

        % Time packet is done being served
        timeRecieved(i) = timeTransmit(i) + W(i) + S(i);
    end

    % Round the vectors to same order as dt
    timeTransmit = round(timeTransmit ./ dt) .* dt;
    timeRecieved = round(timeRecieved ./ dt) .* dt;

    % Calculate age of each packet when it gets served
    packetAge = timeRecieved - timeTransmit;

    % Update length of time vector if needed
    lastRecieved = max(timeRecieved);
    if lastRecieved > tFinal
        tFinal = lastRecieved + dt;
        t = [0:dt:tFinal];
    end
    t = round(t ./ dt) .* dt;

    % Calculate Age of Information
    initialAge = 0;
    age = initialAge + dt * [0:length(t)-1];
    
    % Iterate through each packet
    for i = 1:numEvents
        % Reduce age to match the age of the packet at the time it finished serving
        ageIndex = uint32((timeRecieved(i) /dt) + 1);
        reduceAge = age(ageIndex) - packetAge(i);
        age(ageIndex:end) = age(ageIndex:end) - reduceAge;
    end

    % Calculate Averages
    avgAge = sum(age) / length(age);
    avgWait = sum(W) / length(W);

    if plotResult
        PlotAge(t, age, lambda);
    end    

    