% Delay vs. Throughput

mu = 1/20;

% arrival rate
%Need to make sure that the arrival rate will always be less than the service rate
lambda = [0; 0];
bLength = 1000;
b = linspace(0.3, 0.7, bLength);
lambda(1) = mu * min(b) * 0.9;
lambda(2) = mu * (1- max(b)) * 0.9;

n = [b; 1-b];
% Delay per user formula
D_each  = @(lambda,n, mu) 1./(mu.*n-lambda);

%% Plotting delay vs throughput (n)
% Delay = 1/(1-n)

% Delay per user
figure;
subplot(2,1,1);
semilogy(n(1,:), D_each(min(lambda),n(1,:),mu),'r');
hold on
semilogy(n(1,:), D_each(max(lambda),1-n(1,:),mu),'blue');
heading = ['Throughput ', 'vs. Individual Delay for User 1 and User 2'];
key1 = ['$D_1(\lambda_1, \mu, b)=\frac{1}{b\mu-\lambda_1},\lambda_1=$'+string(min(lambda))+', $\mu =$'+string(mu)];
key2 = ['$D_2(\lambda_2, \mu, b)=\frac{1}{(1-b)\mu-\lambda_2},\lambda_2=$'+string(max(lambda))+', $\mu =$'+string(mu)];
legend([key1; key2], 'Interpreter','latex');
title(heading,'Interpreter','latex')
ylabel('Delay (D)','Interpreter','latex')
xlabel('Split factor applied to service rate (b)', 'Interpreter','latex')
xlim([0 1]);

% Sum Delay
subplot(2,1,2);
DelayTotal = D_each(min(lambda),n(1,:),mu)+D_each(max(lambda),1-n(1,:),mu);
DelayTotal(DelayTotal<0)=nan;
semilogy(n(1,:), DelayTotal,'green');
[M,I]= min(DelayTotal);
xline(n(1,I),'linewidth',2, 'color', 'blue');
heading = ['Throughput ', 'vs. Sum Delay for All User'];
title(heading, 'Interpreter','latex')
ylabel('Delay (D1+D2)', 'Interpreter','latex')
xlabel('Split factor applied to service rate (b)', 'Interpreter','latex')
xlim([0 1]);

%% Now Delay vs Throughput
% Throughput = Max # of bits that can be transmitted in the system
%       n    = The capacity given value of arrival rate and service rate
% 
% Delay      = How many time slots will need to skip to service new packet for the user
%       D    = 1/(1-n)

% Calculate throughput for each new service rate
n_each = @(lambda, mu, b) lambda*log2(mu.*b/lambda);
tp = [n_each(min(lambda), mu, b); n_each(max(lambda), mu, 1-b)];
% Calculate Delay for each throughput value
figure;
subplot(2,1,1);
loglog(tp(1,:), D_each(min(lambda),n(1,:),mu), 'r');
hold on
loglog(tp(1,:), D_each(max(lambda),n(2,:),mu),'blue');
heading = ['Delay for i-th User ', 'vs. Throughput'];
key1 = ['$D_1=\frac{1}{b\mu-\lambda_1},\lambda_1=$'+string(min(lambda))+', $\mu =$'+string(mu)+newline+"$n_1=\lambda_1 log_2(b\mu\backslash\lambda_1)$"];
key2 = ['$D_2=\frac{1}{(1-b)\mu-\lambda_2},\lambda_2=$'+string(max(lambda))+', $\mu =$'+string(mu)+newline+"$n_2=\lambda_2 log_2((1-b)\mu\backslash\lambda_2)$"];
legend([key1; key2], 'Interpreter','latex');
title(heading,'Interpreter','latex')
ylabel('Delay','Interpreter','latex')
xlabel('Throughput', 'Interpreter','latex')


subplot(2,1,2);
DelayTotal = D_each(min(lambda),n(1,:),mu)+D_each(max(lambda),n(2,:),mu);
DelayTotal(DelayTotal<0)=nan;
loglog(tp(1,:), DelayTotal, 'green');
[M,I]= min(DelayTotal);
heading = ['Sum Delay ', 'vs. Throughput'];
title(heading, 'Interpreter','latex')
ylabel('Delay', 'Interpreter','latex')
xlabel('Throughput', 'Interpreter','latex')