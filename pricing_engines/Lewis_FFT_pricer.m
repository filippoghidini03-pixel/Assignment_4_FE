function [call_prices, x_grid, z_grid] = Lewis_FFT_pricer(phi, F0, B, M, dz)

%  Define the Lewis integrand as a function handle
integrand = @(xi) phi(-xi - 0.5i) ./ (2 * pi .* (xi.^2 + 0.25));

% Actual Pricing
[vals, x_grid, z_grid] = FFT_Engine(integrand, dz, M);

% COMMENT: real part taken just to avoid rounding errors made by the pc
% which could give in output an imaginary part MODIFIED: x_grid instead of z_grid
call_prices = B .* F0 .* (1 - exp(-x_grid ./ 2) .* real(vals));

end