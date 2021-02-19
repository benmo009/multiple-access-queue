
clear all;clc


mu = 1;
C = @(lambda,mu) lambda.*log2(mu./lambda); 

eps = 0.01;
lambda = linspace(0,mu-eps,100);


plot(lambda/mu, C(lambda,mu)) %capacity of ./M/1 queue


%FDMA

s = 0.4; %needs to be optimized
mu1 = s*mu;
mu2 = mu-mu1;


%The ratios of lambda1/mu1 and lambda2/mu2 are the same.
C_sum = @(lambda1,lambda2,mu1,mu2) lambda1.*log2(mu1./lambda1)+lambda2.*log2(mu2./lambda2); 
lambda1 = linspace(0,mu1-eps,100);
lambda2 = linspace(0,mu2-eps,100);


figure
plot(lambda1/mu1, C(lambda1,mu1))
hold on
plot(lambda2/mu2, C(lambda2,mu2))
hold on
plot(s*lambda1/mu1+(1-s)*lambda2/mu2, C_sum(lambda1,lambda2,mu1,mu2))
legend('User 1','User 2', 'Sum capacity')