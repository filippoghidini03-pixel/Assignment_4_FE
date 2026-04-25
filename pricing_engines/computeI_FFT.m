function [x_vec, C_vec] = computeI_FFT(F0, DF, p_plus, p_minus, mu, M, dz)
    % COMPUTEI_FFT Prices call options using the FFT applied directly to the 
    % Lewis (2001) formula
    
    N = 2^M;
    dx = 2*pi / (N * dz);
    
    % 1. Integration Grid for z (equivalent to \xi in the Lewis integral)
    z1 = -N/2 * dz;
    z = z1 + (0:N-1)' * dz;
    
    % 2. Log-moneyness Grid for x = ln(F0/K)
    % This guarantees our grid is centered around x = 0 (the ATM point)
    x1 = -N/2 * dx;
    x_vec = x1 + (0:N-1)' * dx;
    
    % 3. Evaluate the Lewis Integrand H(z)
    u = -z - 1i/2;
    phi = exp(1i * mu * u) ./ ((1 - 1i * u / p_plus) .* (1 + 1i * u / p_minus));
    
    % The H(z) function (incorporating the 1/(2*pi) factor from the Lewis integral)
    H = phi ./ (2*pi * (z.^2 + 0.25));
    
    % 4. Apply Simpson's rule weights for numerical accuracy
    weights = (3 + (-1).^(1:N)') / 3;
    weights(1) = 1/3; weights(N) = 1/3;
    
    % 5. Construct the FFT input array
    % We are numerically approximating I(x) = \int H(z) exp(-i z x) dz
    X = H .* exp(-1i * x1 * z) .* weights * dz;
    
    % Execute the built-in FFT
    Y = fft(X);
    
    % Shift the output to account for the symmetric negative-to-positive grid limits
    I_val = exp(-1i * z1 * (x_vec - x1)) .* Y;
    
    % 6. Apply the final Lewis transformation to get Call Prices
    C_vec = F0 * DF * (1 - exp(-x_vec / 2) .* real(I_val));
end