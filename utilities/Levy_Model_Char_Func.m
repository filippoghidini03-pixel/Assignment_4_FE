function nvm_char_func = Levy_Model_Char_Func(alpha, sigma, k, eta, dt)
% LEVY_MODEL_CHAR_FUNC Computes the characteristic function for a generalized Normal Variance-Mean (NVM) model.
%
% Parameters:
% -----------
%   alpha : The stability parameter of the tempered stable mixing variable.
%           0 < alpha <= 1. 
%
%   sigma : double
%       The base average volatility scale parameter.
%
%   k     : "vol to vol", k>0
%
%   eta    : The skewness parameter 
%
% Returns:
% --------
%   char_func_computed : (array) The evaluated characteristic function 

%Safety Check:
% Check scalars
assert(alpha > 0 && alpha <= 1, 'Input Error: Alpha must be in (0, 1].');
assert(sigma > 0, 'Input Error: Sigma must be strictly positive.');
assert(k > 0, 'Input Error: Vol-of-vol (k) must be strictly positive.');

% Helper Function
function val = log_laplace(w)
base = 1 + (w .* k .* sigma^2) ./ (1 - alpha);
val  = (dt / k) .* ((1 - alpha) / alpha) .* (1 - base .^ alpha);
end

% Actual Computation (or better, function definiton)
lnL_eta = log_laplace(eta);
nvm_char_func = @(xi) exp( -1i .* xi .* lnL_eta ) .* ...
            exp( log_laplace(( xi.^2 + 1i .* (1 + 2*eta) .* xi) ./ 2 ));

end