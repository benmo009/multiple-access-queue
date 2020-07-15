% Matlab function to add a packet to the queue.

function [queue, queueSize, queueLocation] = AddToQueue(packet, queue, queueSize, queueLocation)
    % Store the packet information
    source = packet(1);
    time = packet(2);

    % Get location of next empty slot in the queue
    queueIndex = queueLocation(source) + 1;

    % Store the time of arrival into the queue
    queue(source, queueIndex) = time;

    % Update the location and size variables
    queueLocation(source) = queueIndex;
    queueSize(source) = queueSize(source) + 1;
end
