function C = computeI_Quadrature(x, F0, DF, p_plus, p_minus, mu)
    % COMPUTEI_QUADRATURE Prices the call option using numerical integration.
    
    % We integrate from 0 to infinity and take the real part multiplied by 1/pi 
    % which is mathematically equivalent to 1/(2*pi) from -inf to inf for this symmetric case.
    integrand_fn = @(u) real(integrand_lewis(u, x, p_plus, p_minus, mu));
    
    % Use MATLAB adaptive quadrature
    integral_val = (1/pi) * integral(integrand_fn, 0, inf, 'RelTol', 1e-8, 'AbsTol', 1e-12);
    
    % Apply the Lewis transformation to get the final Call price
    C = F0 * DF * (1 - exp(-x/2) * integral_val);
end