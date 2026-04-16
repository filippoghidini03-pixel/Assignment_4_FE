function f = integrand_lewis(u, x, p_plus, p_minus, mu)
    % INTEGRAND_LEWIS Computes the complex integrand for the Lewis (2001) formula.
    %
    % Inputs:
    %   u       - Integration variable (array or scalar)
    %   x       - Log-moneyness ln(F0/K)
    %   p_plus  - Positive jump parameter
    %   p_minus - Negative jump parameter
    %   mu      - Martingale drift
    %
    % Output:
    %   f       - Evaluated complex integrand
    
    % The Lewis shift mapping
    z = -u - 1i/2;
    
    % Evaluate the characteristic function at z
    phi = exp(1i * mu * z) ./ ((1 - 1i * z / p_plus) .* (1 + 1i * z / p_minus));
    
    % Assemble the full integrand
    f = exp(-1i * u * x) .* phi ./ (u.^2 + 0.25);
end