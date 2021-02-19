% Delay vs. Throughput

% D = 1/ (1-n)

% n: throughput
% m = number of server
% p = utilization = arrival rate / service rate
% mu = mean service rate
% n = m * p * mu

m = 1;
%mu = [1/30, 1/30];
mu = 1/30;
% arrival rate for both user
%Need to make sure that the arrival rate will always be less than the service rate
lambda = [0.003; 0.003];
bmin = min(lambda)/mu;
bmax = 0.9;

b=0.01;
n = [bmin:b:bmax; flip(bmin:b:bmax)];
% Delay
D_each  = @(lambda,n, mu) 1./(mu.*n-lambda);
figure;
subplot(2,1,1);
semilogy(n(1,:), D_each(min(lambda),n(1,:),mu),'r');
hold on
semilogy(n(1,:), D_each(max(lambda),n(2,:),mu),'blue');
heading = ['Throughput ', 'vs. Individual Delay for User 1 and User 2'];
key1 = ['$D_1(\lambda_1, \mu, b)=\frac{1}{b\mu-\lambda_1},\lambda_1=$'+string(min(lambda))+', $\mu =$'+string(mu)];
key2 = ['$D_2(\lambda_2, \mu, b)=\frac{1}{(1-b)\mu-\lambda_2},\lambda_2=$'+string(max(lambda))+', $\mu =$'+string(mu)];
legend([key1; key2], 'Interpreter','latex');
title(heading,'Interpreter','latex')
xlim([bmin bmax]);
ylabel('Delay (D)','Interpreter','latex')
xlabel('Split factor applied to service rate (b)', 'Interpreter','latex')
subplot(2,1,2);
DelayTotal = D_each(min(lambda),n(1,:),mu)+D_each(max(lambda),n(2,:),mu);
DelayTotal(DelayTotal<0)=nan;
semilogy(n(1,:), DelayTotal,'green');
xlim([bmin bmax]);
[M,I]= min(DelayTotal);
xline(n(1,I),'linewidth',2, 'color', 'blue');
heading = ['Throughput ', 'vs. Sum Delay for All User'];
title(heading, 'Interpreter','latex')
ylabel('Delay (D1+D2)', 'Interpreter','latex')
xlabel('Split factor applied to service rate (b)', 'Interpreter','latex')
%data_first_d1 = gradient(D_each(lambda(1),n(1,:),mu(1))) ./ gradient(n(1,:));
%data_first_d2 = gradient(D_each(lambda(2),n(2,:),mu(2))) ./ gradient(n(2,:));
%data_first_d3 = gradient(DelayTotal) ./ gradient(n(1,:));
% figure;
% plot(n(1,:), data_first_d1,'r');
% hold on
% plot(n(1,:), data_first_d2,'blue');
% plot(n(1,:), data_first_d3,'green');

