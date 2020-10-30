% Characteristics of each source

%% SIC Type Model
% each user's SNR
SNR_1_dB = db2mag(0);
SNR_2_dB = db2mag(10);
% each user's maximum achieveable transfer rate (individual)
user_1_max_rate = log2(1 + SNR_1_dB);
user_2_max_rate = log2(1 + SNR_2_dB);
% constraint 3: total throughput cannot exceed the capacity of P2P channel
% with the sum of the received powers of the 2 users. 
all_user_max_rate = log2(1 + SNR_1_dB + SNR_2_dB);

% equation1
condition1 = sprintf('x<%f', user_1_max_rate);
condition2 = sprintf('y<%f', user_2_max_rate);
condition3 = sprintf('x+y<%f', all_user_max_rate);

% plotting user 1 rate and user 2 rate
v = 0:0.01:max([user_1_max_rate, user_2_max_rate]);
[x, y] = meshgrid(v);
ineq1 = x < user_1_max_rate;
ineq2 = y < user_2_max_rate;
ineq3 = (x+y) < all_user_max_rate;
ineq = double(ineq1 & ineq2 & ineq3);
h = surf(x,y,ineq, 'FaceAlpha',0.5);

% plotting the rate of the user when the other user is transfering the
% maximum rate (note: it's not zero!)

% user 1 is max rate, now find user 2 at that moment:
user_2 = all_user_max_rate - user_1_max_rate;
yline(user_2, '--', 'LineWidth', 3);

% user 2 is max rate, now find user 1 at that moment:
user_1 = all_user_max_rate - user_2_max_rate;
xline(user_1, '--', 'LineWidth', 3);

% change property of the plot
view(0,90);
xlim([0 Inf]);
ylim([0 Inf]);
xlabel('R_1 Communication Rate (bits/s/Hz)');
ylabel('R_2 Communication Rate (bits/s/Hz)');
title('Capacity Region of Two-User Uplink');
set(h,'LineStyle','none');

%% Traditional/Conventional CDMA
hold on
user_1_max_rate = log2(1 + SNR_1_dB/ (SNR_2_dB+1));
user_2_max_rate = log2(1 + SNR_1_dB/ (SNR_2_dB+1));
all_user_max_rate = log2(1 + SNR_1_dB + SNR_2_dB);

% plotting user 1 rate and user 2 rate
v = 0:0.01:max([user_1_max_rate, user_2_max_rate]);
[x, y] = meshgrid(v);
ineq1 = x < user_1_max_rate;
ineq2 = y < user_2_max_rate;
ineq3 = (x+y) < all_user_max_rate;
ineq = double(ineq1 & ineq2 & ineq3);
h = surf(x,y,ineq, 'FaceAlpha',0.5);
view(0,90);

%% Orthogonal Multiple Access
hold on
a = 0:0.01:1 ;
B = 1 ;
% each user's maximum achieveable transfer rate (individual)
user_1_max_rate = @(a) a.*B.*log2(1 + SNR_1_dB./a);
user_2_max_rate = @(a) (1-a).*B.*log2(1 + SNR_2_dB./(1-a));
x_now = user_1_max_rate(a);
y_now = user_2_max_rate((a));
all_user_max_rate = log2(1 + SNR_1_dB + SNR_2_dB);
plot(x_now,y_now, 'linewidth', 3)