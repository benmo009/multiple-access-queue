% SplitSlotTDMA.m 
% Simulates 2 source TDMA with different slot duration splitting strategies. For
% slot duration T, where T = 1/mu, split T using factor b such that source 1 is
% only served during time b*T and source 2 is only served during time (1-b) * T.

% We're gonna have to edit TDMA.m and CheckSLot.m to get this to work