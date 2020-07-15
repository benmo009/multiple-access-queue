% Function that checks if the server will serve a given packet at the time
% is was sent based on the slot duration. The function will return true if
% the packet's source is recieved during a slot that matches the source.

function [serveSource, slotNumber] = CheckSlot(time, numSources, slotDuration)

    slotNumber = fix(time/slotDuration);
    
    serveSource = mod(slotNumber, numSources) + 1;
    
end