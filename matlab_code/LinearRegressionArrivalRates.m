

load('SingleSource_TrainingData.mat');

X = [ones(m, 1), X];
X = [X, X(:,2).^2];

m = size(X, 1);
n = size(X, 2);

theta = ones(n,1);

h = X * theta;
diff = (h - y) .^ 2;
J = (1/(2*m)) * sum(diff);