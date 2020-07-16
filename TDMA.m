% TDMA.m 
% Function for running the TDMA queue simulation multiple times more easily. For
% n sources, allocate n different slots that the server will cycle through. For
% each slot, the server will only serve one source and ignore all other sources.

% Input the total simulation time, number of sources, slot duration, average
% rate of packet arrivals (lambda), and average service rate (mu). Lambda should
% be in the form of a vector thats length matches the number of soures, and mu
% should a double. 

% Outputs the average age over the duration of the simulation and its
% standard deviation

function [avgAge, stdDevAge, avgWait] = TDMA(tFinal, dt, numSources, slotDuration, lambda, mu, plotResult)
    % If plotResult argument not given, set to false
    if nargin == 6
        plotResult = false;
    end

    % Create time vector
    t = [0:dt:tFinal];

    %% Tranmission Times for each Source
    % Generate vector of when transmissions occurred for each source
    % Represented as a vector of length(t) that is 1 when a packet is sent,
    % and 0 when there is no packet.
    event = zeros(numSources, length(t));
    numEvents = zeros(numSources, 1);

    % Matrix to record the time each packed arrives and from which source
    % Store the source in the top row, and the time in the second row.
    count = 0;  % keeps track of how many packets have been inserted
    for i = 1:numSources
        % Generate tranmission times for each source
        event(i, :) = GenerateTransmissions(lambda(i), t);

        % Count the number of transmissions for each source
        numEvents(i) = sum(event(i, :));

        % Add the times to timeTransmit
        % Find where a packet was sent and save the time
        timestamps = find(event(i,:) == 1);
        timestamps = (timestamps - 1) .* dt;

        % Calculate the beginning and ending indecies for the timeTransmit matrix
        first = count + 1;
        last = count + length(timestamps);

        % Put the packet information into timeTransmit
        timeTransmit(1, first:last) = i;
        timeTransmit(2, first:last) = timestamps;

        % Update count
        count = last;
        
        % Plot the packets arrivals
        if plotResult
            stem(t, event(i,:));
            hold on;
        end
    end

    % Sort timeTransmit based on the times
    [~,idx] = sort(timeTransmit(2,:));
    timeTransmit = timeTransmit(:,idx);

    % Record total number of events
    totalEvents = sum(numEvents);

    % Initialize variables
    % Matrix to store wait times. Top row is 1 if the corresponding packet hasn't
    % been served yet, and zero if it has been served
    W = [ones(1, totalEvents); zeros(1, totalEvents)];
    % Vector to store service times, randomly generated from exponential
    % distribution, then rounded to the order of the time step
    S = exprnd(1/mu, 1, totalEvents);
    S = round(S./dt) .* dt;
    % Count how many packets have been served
    packetsServed = 0;

    % Copy timeTransmit matrix to do work in
    packetsToServe = timeTransmit;

    % Initialize age matrix
    age = dt * (0:length(t) - 1);
    one = ones(numSources, 1);
    age = one * age;


    %% Calculate Age
    % Step through important events, such as when the slot changes, when a packet
    % arrives, or when a packet finishes being served.
    currentTime = timeTransmit(2,1);
    while(packetsServed ~= totalEvents) 
        % Check which source current slot is for
        [serveSource, slotNumber] = CheckSlot(currentTime, numSources, slotDuration);
        % Calculate when the next slot transition occurs
        slotTransition = (slotNumber + 1) * slotDuration;

        % Update the wait matrix
        % Calculate difference between current time and when each packet arrives at
        % the queue. If the packet hasn't arrived yet, keep it at 0. 
        % Multiply the timeDifference by the top row so if a packet was already
        % served, it's wait time won't change.
        timeDifference = max(0, currentTime*ones(size(W(2,:))) - timeTransmit(2,:) - W(2,:));
        W(2, :) = W(2, :) + (W(1, :) .* timeDifference);

        % Find the first packet that works for this slot
        i = 1;
        while (i <= size(packetsToServe, 2)) && (packetsToServe(1,i) ~= serveSource)
            i = i + 1;
        end

        % Check packetIndex
        if i > size(packetsToServe,2)
            % There were no sources sent by the source we want
            currentTime = slotTransition;
            continue;
        end

        packet = packetsToServe(:,i);
        % Check if this 
        if packet(2) >= slotTransition
            currentTime = slotTransition;
            continue;
        end

        % Serve the packet
        % Find the packet's index. Need to search for a match in both source and
        % time in case multiple sources sent a packet at the same time
        sameSource = find(timeTransmit(1,:) == packet(1));
        sameTime = find(timeTransmit(2,:) == packet(2));
        packetIndex = intersect(sameTime, sameSource);

        % Calculate the age of the packet when its done being served
        packetAge = S(packetIndex) + W(2,packetIndex);

        % Store the packet and the time it finished being served in prevPacket
        prevPacket = packet;
        prevPacket(2) = packet(2) + packetAge;

        % Update the age
        % Calculate the index for the time and age vectors
        tIndex = round((prevPacket(2) / dt) + 1);

        % Check if current time is outside of the time and age vectors
        while tIndex > length(t)
            % Double the time vector and the age vector
            tFinal = 2 * tFinal;
            t = [0:dt:tFinal];
            ageEnd = age(:,end) + dt;
            ageAppend = ageEnd + [0:dt:tFinal/2 - dt];
            age = [age, ageAppend];
        end

        % Decrease age such that at the current time, it is equal to packet age
        ageReduce = age(prevPacket(1), tIndex) - packetAge;
        age(prevPacket(1), tIndex:end) = age(prevPacket(1), tIndex:end) - ageReduce;

        % Set first row of wait matrix to 0 for the newly served packet
        W(1, packetIndex) = 0;

        % Remove served packet from packetsToServe matrix
        packetsToServe(:, i) = [];

        % Update the time and increment packet count
        currentTime = prevPacket(2);
        packetsServed = packetsServed + 1;
    end
    
    % Cut off age at final packet served time
    cutoff = round((currentTime / dt)) + 2;
    t(cutoff:end) = [];
    age(:,cutoff:end) = [];

    % Calculate averages and standard deviation to return
    avgAge = sum(age,2)/size(age,2);
    stdDevAge = std(age, 0, 2);
    avgWait = sum(W(2,:)) / totalEvents;

    % Plot the result
    if plotResult
        PlotAge(t, age, lambda);
    end
end