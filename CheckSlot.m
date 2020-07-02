% Function that checks if the server will serve a given packet at the time
% is was sent based on the slot duration. The function will return true if
% the packet's source is recieved during a slot that matches the source.

function serve = CheckSlot(packet, numSources, slotDuration)
    source = packet(1);
    timestamp = packet(2);
    
    slotNumber = fix(timestamp/slotDuration);
    
    serveSource = mod(slotNumber, numSources) + 1;
    
    serve = (source == serveSource);
end