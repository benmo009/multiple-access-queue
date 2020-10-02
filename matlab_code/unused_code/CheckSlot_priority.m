% Function that checks if the server will serve a given packet at the time
% is was sent based on the slot duration. The function will return true if
% the packet's source is recieved during a slot that matches the source.

function [serveSource, slotNumber, slotTransition] = CheckSlot_priority(time, numSources, slotDuration, priority, timeTransmit)


    totalSlot = sum(slotDuration);
    slotNumber = fix(time/totalSlot);
    relativeTime = mod(time, totalSlot);

    for i = 1:length(slotDuration)
        relativeTime = relativeTime - slotDuration(i);
        if abs(relativeTime) < 1e-9 || relativeTime == 0
            continue
        end
        
        if relativeTime < 0
            break;
        end
    end

    serveSource = i;

    % Added to remove floating point error bug where fix would return an
    % incorrect value
    difference = (time/totalSlot) - slotNumber;
    if abs(difference - 1) < 1e-9
        slotNumber = slotNumber + 1;
    end

    if serveSource == numSources
        slotTransition = (slotNumber+1) * totalSlot;
    else
        slotTransition = slotNumber * totalSlot;
        for i = 1:serveSource
            slotTransition = slotTransition + slotDuration(i);
        end
    end

    
    % Priority
    idx = find(timeTransmit(2,:) == time);
    if ~isempty(idx)
        currentSource = timeTransmit(1,idx);
        if serveSource ~= currentSource
            if priority(currentSource) > priority(serveSource)
                fprintf("At time: %d, priority take over serveSource slot!\n", time)
                serveSource = currentSource;
            end
        end
    end
end
