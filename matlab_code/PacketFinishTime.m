function [lastPacketServed] = PacketFinishTime(initial_packet_end_time, slotDuration, packet)
	canLeave = true;
    
    % total period
    total_period = sum(slotDuration);
    % source origin of this packet (1: user 1, 2: user 2)
    pack_origin = packet(1);
    if pack_origin == 1
        % if this packet come from source 1, it will be (0,
        % slotduration(1))
        slot_begin = 0;
        slot_end = slot_begin+slotDuration(1);
    else
        % if this packet come from source 2, it will be (slotduration(1)+0.1,
        % slotduration(1)+0.1+slotduration(2))
        slot_begin = slotDuration(1)+0.1;
        slot_end = slot_begin+slotDuration(2);
    end
    
	t1 = initial_packet_end_time;
	t2 = 0;
	p = floor(t1/total_period);
	t1 = mod(t1, total_period);
	
	% user 1
	while true
		t1 = t1 + 0.1;
        if(t1 > total_period)
			t1 = 1;
			p = p + 1;
        end
        
		if(t1 >= slot_begin && t1<= slot_end)
			canLeave = true;
		else
			canLeave = false;
		end
		
		if canLeave
			t2 = t1 + total_period*p;
			lastPacketServed = t2;
            break;
        end
    end
end
	
