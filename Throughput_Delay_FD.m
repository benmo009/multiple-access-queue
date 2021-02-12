% Delay vs. Throughput

% D = 1/ (1-n)

% n: throughput
% m = number of server
% p = utilization = arrival rate / service rate
% mu = mean service rate
% n = m * p * mu

m = 1;
mu = [1/30, 1/30];

% arrival rate for both user
%Need to make sure that the arrival rate will always be less than the service rate
lambda = [1/80; 1/50];
b=0.001;
n = [0:b:1; flip(0:b:1)];
% Delay
D_each  = @(lambda,n, mu) 1./(mu-lambda.*n);
D_total = @(lambda1, lambda2, n, mu) 1./(mu-(lambda1.*n + lambda2.*flip(n)));
figure;
subplot(2,1,1);
plot(n(1,:), D_each(lambda(1),n(1,:),mu(1)),'r');
hold on
plot(n(1,:), D_each(lambda(2),n(2,:),mu(2)),'blue');
heading = ['Throughput ', 'vs. Individual Delay for User 1 and User 2'];
key1 = ['$D_1(\lambda_1, \mu_1, b)=\frac{1}{\mu_1-b\lambda_1},\lambda_1=$'+string(lambda(1))+', $\mu_1 =$'+string(mu(1))];
key2 = ['$D_2(\lambda_2, \mu_2, b)=\frac{1}{\mu_2-(1-b)\lambda_2},\lambda_2=$'+string(lambda(2))+', $\mu_2 =$'+string(mu(2))];
legend([key1; key2], 'Interpreter','latex');
title(heading,'Interpreter','latex')
subplot(2,1,2);
DelayTotal = D_each(lambda(2),n(2,:),mu(2))+D_each(lambda(1),n(1,:),mu(1));
plot(n(1,:), DelayTotal,'green');
[M,I]= min(DelayTotal);
xline(n(1,I),'linewidth',2, 'color', 'blue');
heading = ['Throughput ', 'vs. Sum Delay for All User'];
title(heading, 'Interpreter','latex')

data_first_d1 = gradient(D_each(lambda(1),n(1,:),mu(1))) ./ gradient(n(1,:));
data_first_d2 = gradient(D_each(lambda(2),n(2,:),mu(2))) ./ gradient(n(2,:));
data_first_d3 = gradient(DelayTotal) ./ gradient(n(1,:));
% figure;
% plot(n(1,:), data_first_d1,'r');
% hold on
% plot(n(1,:), data_first_d2,'blue');
% plot(n(1,:), data_first_d3,'green');

