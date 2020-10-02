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

function [avgAge, avgWait] = TDMA(tFinal, dt, numSources, slotDuration, lambda, mu, priority, queueSize, plotResult)
    import java.util.LinkedList

    % If plotResult argument not given, set to false
    if nargin <= 8
        plotResult = false;
    end
    if nargin <= 7
        queueSize = Inf;
    end
    if nargin <= 6
        priority = [0, 0];
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
        
    end

    % Sort timeTransmit based on the times
    [~,idx] = sort(timeTransmit(2,:));
    timeTransmit = timeTransmit(:,idx);

    % Initialize variables
    % Count how many packets have been served
    packetsServed = zeros(numSources, 1);

    % Copy timeTransmit matrix to do work in
    toServe = timeTransmit;

    % Initialize age matrix
    age = ones(numSources, 1) * t;

    % Initialize queue and wait vectors. Store them in cell arrays
    queue = cell(numSources,1);
    W = cell(numSources, 1);
    % Vector to store service times, randomly generated from exponential
    % distribution, then rounded to the order of the time step
    S = cell(numSources, 1);
    for i = 1:numSources
        queue{i} = LinkedList();
        W{i} = zeros(1, numEvents(i));
        S{i} = exprnd(1 / mu, 1, numEvents(i));
        S{i} = round(S{i} ./ dt) .* dt;
    end

    %% Calculate Age
    % Step through important events, such as when the slot changes, when a packet
    % arrives, or when a packet finishes being served.
    currentTime = toServe(2,1);
    packet = toServe(:, 1);
    toServe(:, 1) = [];
    isPacket = true;

    
    % Timestamp of when the most recent packet was served. Initialized to
    % -1 to ensure loop starts with currentTime > lastPacketServed
    lastPacketServed = -1; 

    % Initialize first slot transition to 0
    slotTransition = 0;

    while true
        % Only need to calculate slot properties when entering a new slot
        if currentTime >= slotTransition
            % Check which source current slot is for
            [serveSource, slotNumber, slotTransition] = CheckSlot(currentTime, numSources, slotDuration, priority, timeTransmit);

        end

        % Check were the current time is in relation to lastPacketServed
        if currentTime > lastPacketServed
            % A new packet arrived or slot transitioned after the previous
            % packet has been served. Only gets here if the server has been idle
            % If it's a packet, either serve it or put it in the queue depending
            % on the slot type. If its a slot transition, pull a packet from the
            % queue if there is one

            % Current Time is a packet arrival
            if isPacket
                % Check if the time slot is correct
                source = packet(1);
                if serveSource ~= source
                    % Wrong slot, add to queue
                    queue{source}.add(packet(2));
                    % Make sure queue limit isn't exceeded
                    if queue{source}.size() > queueSize
                        queue{source}.remove();
                    end
                else
                    % slot matches the source, calculate when this packet will
                    % be done being served.

                    % Put it into the queue, then remove it. In some cases, a
                    % packet comes in at the same time the slot transitions, so
                    % theres an earlier packet in the queue. If this isn't done,
                    % the earlier packet might be served later, resulting in a
                    % negative change in age
                    queue{source}.add(packet(2));
                    if queue{source}.size() > queueSize
                        queue{source}.remove();
                    end
                    packet = [source; queue{source}.remove()];
                    
                    packetsServed(source) = packetsServed(source) + 1;
                    idx = packetsServed(source);
                    lastPacketServed = packet(2) + S{source}(idx) + W{source}(idx);
                    lastPacket = packet;
                end
            % Current Time is a slot transition
            else
                % Check queue if there is a packet that can be served
                if queue{serveSource}.size() ~= 0
                    % Take the packet from the queue
                    packet = [serveSource; queue{serveSource}.remove()];
                    source = packet(1);

                    % Serve the packet
                    packetsServed(source) = packetsServed(source) + 1;
                    idx = packetsServed(source);
                    % Calculate the time this packet waited in the queue
                    W{source}(idx) = currentTime - packet(2);
                    lastPacketServed = packet(2) + S{source}(idx) + W{source}(idx);
                    lastPacket = packet;
                end
            end

        elseif currentTime == lastPacketServed
            % Server just finished, update the age and then take another packet
            % from the queue that matches the slot, if there is one.

            % Update age
            packetAge = currentTime - lastPacket(2);
            ageIndex = uint32(currentTime / dt + 1);
            % Double the length of age and t vectors if needed
            if ageIndex > length(age)
                % Double the age and time vectors
                tFinal = 2 * tFinal;
                t = [0:dt:tFinal];
                ageEnd = age(:, end) + dt;
                ageAppend = ageEnd + [0:dt:tFinal / 2 - dt];
                age = [age, ageAppend];
            end
            reduceAge = age(lastPacket(1), ageIndex) - packetAge;
            age(lastPacket(1), ageIndex:end) = age(lastPacket(1), ageIndex:end) - reduceAge;

            % Add the packet to queue in the case a packet arrived at the same
            % time the server finished
            if isPacket
                queue{packet(1)}.add(packet(2));
                if queue{packet(1)}.size() > queueSize
                    queue{packet(1)}.remove();
                end
            end

            if queue{serveSource}.size() ~= 0
                % Remove a packet from the queue
                packet = [serveSource; queue{serveSource}.remove()];
                source = packet(1);
                
                % Serve the packet
                packetsServed(source) = packetsServed(source) + 1;
                idx = packetsServed(source);
                W{source}(idx) = currentTime - packet(2);
                lastPacketServed = packet(2) + S{source}(idx) + W{source}(idx);
                lastPacket = packet;
            end


        elseif currentTime < lastPacketServed
            % A packet arrives or slot transitions while the server is busy
            % If it was a packet, add it to the queue
            if isPacket
                queue{packet(1)}.add(packet(2));
                if queue{packet(1)}.size() > queueSize
                    queue{packet(1)}.remove();
                end
            end
            
            % Don't need to do anything for a slot transition
        end

        % Set the next time
        % Times of interest are packet arrivals, slot transitions, and when
        % packets are done being served. Set current time to the one that
        % happens first
        if isempty(toServe)
            % No more packet arrivals
            if currentTime >= lastPacketServed
                currentTime = slotTransition;
            else
                currentTime = lastPacketServed;
            end
            isPacket = false;
        else
            if currentTime >= lastPacketServed
                currentTime = min(slotTransition, toServe(2,1));
            else
                currentTime = min([lastPacketServed, toServe(2, 1)]); 
            end

            % Check if the next time is a packet arrival
            if currentTime == toServe(2, 1)
                isPacket = true;
                packet = toServe(:, 1);
                toServe(:, 1) = [];
            else
                isPacket = false;
            end
        end

        % Check to see if all packets have been served. Check if there are no
        % more packets to serve and the current time matches the time of the
        % last packet served
        stopLoop = isempty(toServe) && (currentTime > lastPacketServed);
        % Check if all queues are empty
        for i = 1:numSources
            % Queue isn't empty, so don't stop the loop
            if queue{i}.size() ~= 0
                stopLoop = false;
            end
        end
        % Break the loop if all packets are served
        if stopLoop
            break;
        end
    end

    % Cut off age at final packet served time
    cutoff = uint32(lastPacketServed / dt + 1) + 1;
    t(cutoff:end) = [];
    age(:,cutoff:end) = [];

    % Calculate averages to return
    avgAge = sum(age,2)/size(age,2);
    avgWait = zeros(numSources, 1);
    % Go through each wait vector and trim off any remaining zeros
    for i = 1:numSources
        W{i} = W{i}(1:packetsServed(i));
        avgWait(i) = sum(W{i}) / packetsServed(i);
    end

    % Plot the result
    if plotResult
        PlotAge(t, age, lambda);
    end
end