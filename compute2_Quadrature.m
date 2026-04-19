function C = compute2_Quadrature(x, F0, DF, phi_u)
    % COMPUTE2_QUADRATURE Prices the call option using numerical integration.
    % IMPUTS:
    %   F0         - Forward price
    %   DF         - Discount factor
    %   x          - Log-moneyness
    %   phi_u      - Characteristic function
    % OUTPUT:
    %   C          - Call option price

    % We integrate from 0 to infinity and take the real part multiplied by 1/pi
    % Evaluate phi_u at the Lewis contour shift: (-u - 1i/2)
    f = @(u) real(exp(-1i .* u .* x) .* phi_u(-u - 1i/2) ./ (u.^2 + 0.25));
    
    integral_val = (1/pi) * integral(f, 0, inf, 'RelTol', 1e-8, 'AbsTol', 1e-12);

    C = F0 * DF * (1 - exp(-x/2) * integral_val);
end