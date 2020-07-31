% arrival follows a poisson distribution
% here, we assume the arrival rate lambda is small
% with such a small lambda, only 1 packet arrives

clc
close all
tic

%% Setting up sources 

T_total = 1900;     % this is the total time user
                    % is allowed to communicate
source1 = source;   % define source 1
source1.source_title = "Source 1";
source1.lambda_rate = 1/20;
source1.arrival_timestamp = zeros(1, T_total);
source1.priority = 0;

source2 = source;   % define source 2
source2.source_title = "Source 2";
source2.lambda_rate = 1/20;
source2.arrival_timestamp = zeros(1, T_total);
source2.priority = 1;

%%  Looking at arrival for each user
%   Packet_Arrived       ->     an empty list
%   size(Packet_Arrived) ->     Provide the size of the array
Packet_Arrived = zeros(1, T_total); % initialize list

% Generate transmission time from the poisson distribution.
% User 1
R = poissrnd(source1.lambda_rate, size(Packet_Arrived));
source1.arrival_timestamp(R>=1) = 1;
% User 2
R = poissrnd(source2.lambda_rate, size(Packet_Arrived));
source2.arrival_timestamp(R>=1) = 1;

%%  Superimpose the 2 source into one time-line
%   Show all packets, from all users, from t=0 to t=T_total,
%   when they've arrived, in a color-coded format.
%   
%   timeTransmit[2 row, many column array]
%        first row:  user's name
%       second row:  time at which the user's packet was send
%   Eventually:
%           user:       1       1       2       1       2       ...      
%   time-arrived:       10     23      22      30      31       ...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%   Grab the time-instances of where packets arrived from different users.
count = 0;  % keeps track of how many packets have been inserted
source1.sum_of_arrival = sum(source1.arrival_timestamp);
source2.sum_of_arrival = sum(source2.arrival_timestamp);

timeTransmit(1, 1:source1.sum_of_arrival) = source1.source_title;
timeTransmit(2, 1:source1.sum_of_arrival) = find(source1.arrival_timestamp(1,:) == 1);

count = source1.sum_of_arrival; % keeps track of how many packets have been inserted

source1.sum_of_arrival = sum(source1.arrival_timestamp);
source2.sum_of_arrival = sum(source2.arrival_timestamp);

timeTransmit(1, 1+count:count+source2.sum_of_arrival) = source2.source_title;
timeTransmit(2, 1+count:count+source2.sum_of_arrival) = find(source2.arrival_timestamp(1,:) == 1);

% Sort timeTransmit based on the times
[~,idx] = sort(timeTransmit(2,:));
timeTransmit = timeTransmit(:,idx);

% convert the second row to numerical value so it can be graphed
V = str2double(timeTransmit(2,:));

% preparing superimposed data to be graphed
sup_x_ax = 1:1:T_total;
sup_y_ax_s1 = zeros(1, length(sup_x_ax));
sup_y_ax_s2 = zeros(1, length(sup_x_ax));

index_s1 = find(source1.arrival_timestamp(1,:) == 1);
index_s2 = find(source2.arrival_timestamp(1,:) == 1);

for i = 1:length(index_s1)
    sup_y_ax_s1( (index_s1(i)) ) = 1;
end
for i = 1:length(index_s2)
    sup_y_ax_s2( (index_s2(i)) ) = 1;
end
sup_y_ax = [sup_y_ax_s1, sup_y_ax_s2];

%% Graph
figure()
subplot(2,2,1);             % arrival of source 1
source1.plot_arrival_time;  
subplot(2,2,2);             % arrival of source 2
source2.plot_arrival_time;
subplot(2,2,3:4);           % arrival of both source on same timeline
% stem(sup_x_ax,sup_y_ax)
stem(sup_x_ax,sup_y_ax_s1)  
hold on 
stem(sup_x_ax,sup_y_ax_s2)
title('Source1 and Source2 combined');