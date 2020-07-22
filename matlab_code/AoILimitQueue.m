% AoILimitQueue.m
% Function to simulate single source, M/M/1 Queue with a limited queue size

function [avgAge, avgWait] = AoILimitQueue(tFinal, dt, lambda, mu, queueSize, plotResult, source)
    import java.util.LinkedList

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
    numEvents = sum(event);

    % Find timestamps of each event and store them
    timeTransmit = find(event == 1);
    timeTransmit = (timeTransmit - 1) .* dt;

    % Generate service times
    S = exprnd(1/mu, size(timeTransmit));
    S = round(S ./ dt) .* dt;

    % Initialize wait and timeReceived vectors
    W = zeros(size(S));
    timeReceived = zeros(size(S));
    timeReceived(1) = timeTransmit(1) + W(1) + S(1);
    packet = timeTransmit(1);

    % Vector of upcomming packets
    toServe = timeTransmit(2:end);

    % Initialize empty queue
    queue = LinkedList();

    % Variable to keep track of time
    lastPacketServed = timeReceived(1);
    currentTime = min(toServe(1), lastPacketServed);
    packetsServed = 1;
    
    age = t;

    while (true)
        if currentTime > lastPacketServed 
            packetsServed = packetsServed + 1;
            timeReceived(packetsServed) = currentTime + S(packetsServed) + W(packetsServed);
            lastPacketServed = timeReceived(packetsServed);

            if isempty(toServe)
                currentTime = lastPacketServed;
            else
                currentTime = min(toServe(1), lastPacketServed);
            end
            

        elseif currentTime == lastPacketServed
            % Packet just finished being served. Take next packet from the queue
            % If the queue is empty, skip to when the next packet arrives
            
            % Update the age
            packetAge = currentTime - packet;
            ageIndex = uint32(currentTime/dt + 1);

            if ageIndex > length(age)
                % Double the age and time vectors
                tFinal = 2 * tFinal;
                t = [0:dt:tFinal];
                ageEnd = age(:, end) + dt;
                ageAppend = ageEnd + [0:dt:tFinal / 2 - dt];
                age = [age, ageAppend];
            end

            reduceAge = age(ageIndex) - packetAge;
            age(ageIndex:end) = age(ageIndex:end) - reduceAge;

            if queue.size() == 0
                % queue is empty
                if isempty(toServe)
                    break;
                end
                currentTime = toServe(1);
                packet = currentTime;
                toServe(1) = [];

            else
                packet = queue.remove();
                packetsServed = packetsServed + 1;
                W(packetsServed) = currentTime - packet;
                timeReceived(packetsServed) = currentTime + S(packetsServed);

                lastPacketServed = timeReceived(packetsServed);

                if isempty(toServe)
                    currentTime = lastPacketServed;
                else
                    currentTime = min(toServe(1), lastPacketServed);
                end
                
            end


        elseif currentTime < lastPacketServed
            % Newest packet arrived when the server is still working on a packet
            % Add newly arrived packet to queue

            queue.add(currentTime);
            if queue.size() > queueSize
                queue.remove();
            end

            toServe(1) = [];
            if isempty(toServe)
                currentTime = lastPacketServed;
            else
                currentTime = min(toServe(1), lastPacketServed);
            end
            
        end

        % Break the loop if there are no more packets to serve
        if isempty(toServe) && (queue.size() == 0) && (currentTime == lastPacketServed)
            break;
        end
    end
    
    % Trim any trailing 0's
    timeReceived = timeReceived(1:packetsServed);
    W = W(1:packetsServed);

    % Trim off extra age and t
    ageIndex = uint32(lastPacketServed / dt + 1) + 1;
    age(ageIndex:end) = [];
    t(ageIndex:end) = [];

    % Calculate Average Age and delay
    avgAge = sum(age)/ length(age);
    avgWait = sum(W) / length(W);

    if plotResult
        PlotAge(t, age, lambda, source);
    end
    
end
