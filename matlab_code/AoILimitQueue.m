% AoILimitQueue.m
% Function to simulate single source, M/M/1 Queue with a limited queue size

function avgAge = AoILimitQueue(tFinal, dt, lambda, mu, queueSizeplotResult, source)
    % If plotResult and source aren't given, set them to default values
    if nargin <= 5
        plotResult = false;
        source = 0;
    end
    if nargin <= 4
        queueSize = Inf;
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

    % Initialize empty queue
    queue = [];
    packetsInQueue = 0;

    numEvents = sum(event);

    toServe = timeTransmit(2:end);

    lastPacketServed = timeRecieved(1);
    packetsServed = 1;
    currentTime = timeTransmit(i);           
    
    for i = 2:numEvents
        currentTime = timeTransmit(i);
        % Packet i arrives after packet i-1 has been served
        if timeTransmit(i) >= lastPacketServed
            queue = [queue, timeTransmit(i)];

            toServe = queue(1);
            queue(1) = [];

            % Keep going through the queue until it is empty, or timeTransmit(i) is reached
            while ~isempty(queue) && lastPacketServed <= timeTransmit(i)
                W(packetsServed+1) = lastPacketServed - toServe;
                timeRecieved(packetsServed+1) = toServe + W(packetsServed+1) + S(packetsServed+1);
                lastPacketServed = timeRecieved(packetsServed+1);
                packetsServed = packetsServed+1;

                toServe = queue(1);
                queue(1) = [];
                packetsInQueue = size(queue, 2);

            end


            % Serve the first packet in queue

            % Set lastPacketServed to newest packet


        % Packet i arrived before packet i-1 is done being served
        elseif timeTransmit(i) < lastPacketServed
            % Serving packet i-1, put packet i in the queue
            queue = [queue, timeTransmit(i)];
            packetsInQueue = size(queue, 2);
            if packetsInQueue > queueSize
                queue(1) = [];
                packetsInQueue = size(queue, 2);
            end
            
        end

        % Time packet is done being served
        %timeRecieved(i) = timeTransmit(i) + W(i) + S(i);
    end


