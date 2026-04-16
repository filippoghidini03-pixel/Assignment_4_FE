function C = computeI_Residuals(x, F0, DF, p_plus, p_minus, mu)
    % COMPUTEI_RESIDUALS Evaluates the Lewis integral analytically via the Residue Theorem.
    
    % The integrand has exactly 4 simple poles in the complex plane.
    % Roots from the Lewis denominator:
    z1 = 1i / 2;
    z3 = -1i / 2;
    
    % Roots from the characteristic function denominators:
    % 1 - 1i(-z - 1i/2)/p_plus = 0
    z2 = 1i * (p_plus - 0.5);
    % 1 + 1i(-z - 1i/2)/p_minus = 0
    z4 = -1i * (p_minus + 0.5);
    
    % Define the full unshifted denominator function to compute the complex derivative
    denom = @(z) ((1 - 1i*(-z - 1i/2)/p_plus) .* (1 + 1i*(-z - 1i/2)/p_minus) .* (z.^2 + 0.25));
    num = @(z) exp(-1i * z * x) .* exp(1i * mu * (-z - 1i/2));
    
    % Helper function to calculate residue using numerical complex derivative
    eps = 1e-8;
    calc_res = @(pole) num(pole) / ((denom(pole + eps) - denom(pole - eps)) / (2*eps));
    
    % We close the contour based on the decay of the exponential e^(-i*z*(x+mu))
    % If (x + mu) > 0, we close in the Lower Half Plane (LHP). 
    % If (x + mu) < 0, we close in the Upper Half Plane (UHP).
    if (x + mu) >= 0
        % Close in LHP: multiply by -2*pi*1i, sum residues of poles with Im(z) < 0
        % Poles z3 and z4 are in the LHP
        sum_res = calc_res(z3) + calc_res(z4);
        integral_val = -2 * pi * 1i * sum_res;
    else
        % Close in UHP: multiply by 2*pi*1i, sum residues of poles with Im(z) > 0
        % Poles z1 and z2 are in the UHP
        sum_res = calc_res(z1) + calc_res(z2);
        integral_val = 2 * pi * 1i * sum_res;
    end
    
    % Ensure we take the real part (residual sum contains negligible imaginary float noise)
    integral_val = real(integral_val) / (2*pi);
    
    % Apply Lewis transformation
    C = F0 * DF * (1 - exp(-x/2) * integral_val);
end