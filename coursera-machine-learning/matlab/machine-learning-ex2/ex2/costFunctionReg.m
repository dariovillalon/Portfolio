function [J, grad] = costFunctionReg(theta, X, y, lambda)
%COSTFUNCTIONREG Compute cost and gradient for logistic regression with regularization
%   J = COSTFUNCTIONREG(theta, X, y, lambda) computes the cost of using
%   theta as the parameter for regularized logistic regression and the
%   gradient of the cost w.r.t. to the parameters. 

% Initialize some useful values
m = length(y); % number of training examples

% You need to return the following variables correctly 
J = 0;
grad = zeros(size(theta));

% ====================== YOUR CODE HERE ======================
% Instructions: Compute the cost of a particular choice of theta.
%               You should set J to the cost.
%               Compute the partial derivatives and set grad to the partial
%               derivatives of the cost w.r.t. each parameter in theta


%hyp = sigmoid(X * theta);
%[J, grad] = costFunction(theta, X, y);
%theta(1) = 0;
%J =  J + lambda / (2 * m) * sum(theta .^ 2);
%grad = (X' * (hyp - y) + lambda * theta) / m;


hyp = sigmoid(X * theta);

J_noreg = ((-y' * log(hyp)) - ((1 - y)' * log(1 - hyp))) / m; 
grad_noreg = (1/m) .* (X' * (hyp - y));

theta(1) = 0;

J_reg = J_noreg + (lambda / (2*m)) * sum(theta .^2); 
grad_reg = grad_noreg + ((lambda/m) * theta);

J = J_reg;
grad = grad_reg;


% =============================================================

end
