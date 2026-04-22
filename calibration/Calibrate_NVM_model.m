function [opt_params, SSE, model_implied_vol] = Calibrate_NVM_model(mkt_strikes, mkt_implied_vol, F0, B, dt, alpha, M, dz)
% CALIBRATE_NVM_MODEL Calibrates the NVM model to market prices using fmincon.
%
% Returns:
%   opt_params : Array containing the optimal [sigma, k, eta]
%   SSE        : The final Sum of Squared Errors

% Pre-compute Grid & Market Variables
mkt_log_mon = log(F0 ./ mkt_strikes);

% Optimization Setup
p0 = [0.20, 1.0, -0.1];  % Initial guess: [sigma, k, eta]
lb = [1e-4, 1e-4, -Inf]; % Lower bounds
ub = [5.0, 10.0, Inf];   % Upper bounds

options = optimoptions('fmincon', ...
        'Algorithm', 'sqp', ... 
        'Display', 'off', ...
        'MaxFunctionEvaluations', 2000, ...   
        'MaxIterations', 1000, ...
        'StepTolerance', 1e-6);

% Run Optimization
disp('Starting Constrained Calibration (fmincon)...');

% COMMENT: the [] empty is because they are the input for linear
% inequalitites/equalities (linear constraints), which here are not present
% due to the nature of the problem
[opt_params, SSE] = fmincon(@objective_fn, p0, [], [], [], [], lb, ub, @constraint_fn, options);

% --- Recompute model implied vols at optimal parameters ---
phi_opt = Levy_Model_Char_Func(alpha, opt_params(1), opt_params(2), opt_params(3), dt);
[fft_prices_opt, fft_x_grid_opt, ~] = Lewis_FFT_pricer(phi_opt, F0, B, M, dz);
model_prices_opt = interp1(fft_x_grid_opt, fft_prices_opt, mkt_log_mon, 'spline');
model_implied_vol = blkimpv(F0, mkt_strikes, 0, dt, model_prices_opt / B);

% Helper Functions

function error_val = objective_fn(p)
% Extract guesses
sigma_guess = p(1);
k_guess     = p(2);
eta_guess   = p(3);

% Build Characteristic Function
phi = Levy_Model_Char_Func(alpha, sigma_guess, k_guess, eta_guess, dt);

% Price via FFT
[fft_prices, fft_x_grid, ~] = Lewis_FFT_pricer(phi, F0, B, M, dz);

% Interpolate and compute error
% COMMENT: we built a fft pricing, but not every computed vaues will be
% computed on existing strike prices K!!! So we need to interpolate to
% then calibrate the model on real mrk data!
model_prices = interp1(fft_x_grid, fft_prices, mkt_log_mon, 'spline');

% COMMENT: weird inputs, but it is just because of how is coded the MATLAB
% function
model_implied_vol = blkimpv(F0, mkt_strikes, 0, dt, model_prices / B);
error_val = sum((model_implied_vol - mkt_implied_vol).^2);
end

function [c, ceq] = constraint_fn(p)
sigma_guess = p(1);
k_guess     = p(2);
eta_guess   = p(3);

% Dynamic boundary condition: eta >= -(1-alpha)/(k*sigma^2)
omega_bar = (1 - alpha) / (k_guess * sigma_guess^2);

% Inequality constraint: c(p) <= 0
% COMMENT: not that deep, it is just how to implement the dynamic (in
% the sense that it depends on the other tested params) constraint on
% eta to have a well defined integral (analytic strip, ...)
c = -eta_guess - omega_bar;
ceq = []; 
end
end