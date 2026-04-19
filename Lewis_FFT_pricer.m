function [call_prices, x_grid, z_grid] = Lewis_FFT_pricer(phi, F0, B, M, dz, x1, z1)

%  Define the Lewis integrand as a function handle
integrand = @(xi) phi(-xi - 0.5i) ./ (2 * pi .* (xi.^2 + 0.25));

% Actual Pricing
[vals, x_grid, z_grid] = FFT_Engine(integrand, dz, x1, z1, M);

% COMMENT: real part taken just to avoid rounding errors made by the pc
% which could give in output an imaginary part
call_prices = B .* F0 .* (1 - exp(-z_grid ./ 2) .* real(vals));

end