function [packet, queue] = RemoveFromQueue(queue, source)
    % Go through queue until first non nan value
    queueIndex = 1;
    while (isnan(queue(source,queueIndex)))
        queueIndex = queueIndex + 1;
    end
    
    % Remove the packet from the queue
    packet = [source; queue(source, queueIndex)];
    queue(source, queueIndex) = nan;