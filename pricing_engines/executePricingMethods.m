function [C_quad_vec, C_res_vec, C_mc_vec] = executePricingMethods(x_grid, F0, DF, p_plus, p_minus, mu)
    % EXECUTEPRICINGMETHODS Iterates through a grid of moneyness values and 
    % computes European Call prices using Quadrature, Residuals, and Monte Carlo.
    %
    % Inputs:
    %   x_grid  - Array of log-moneyness values (x = ln(F0/K))
    %   F0      - Forward price
    %   DF      - Discount Factor
    %   p_plus  - Positive jump parameter for the characteristic function
    %   p_minus - Negative jump parameter for the characteristic function
    %   mu      - Martingale drift
    %
    % Outputs:
    %   C_quad_vec - Array of prices computed via Quadrature
    %   C_res_vec  - Array of prices computed via Residuals
    %   C_mc_vec   - Array of prices computed via Monte Carlo

    % Initialize output arrays with zeros for memory efficiency
    N = length(x_grid);
    C_quad_vec = zeros(1, N);
    C_res_vec  = zeros(1, N);
    C_mc_vec   = zeros(1, N);

    % Loop through each moneyness point
    for i = 1:N
        x = x_grid(i);
        K = F0 * exp(-x);
        
        fprintf('--- Pricing for Moneyness x = %.2f%% (Strike K = %.2f) ---\n', x*100, K);
        
        % a. Quadrature
        C_quad_vec(i) = computeI_Quadrature(x, F0, DF, p_plus, p_minus, mu);
        fprintf('a. Quadrature Price:  %.4f\n', C_quad_vec(i));
        
        % b. Residuals Technique
        C_res_vec(i) = computeI_Residuals(x, F0, DF, p_plus, p_minus, mu);
        fprintf('b. Residuals Price:   %.4f\n', C_res_vec(i));
        
        % c. Monte Carlo Simulation
        C_mc_vec(i) = computeI_MonteCarlo(x, F0, DF, K, p_plus, p_minus, mu);
        fprintf('c. Monte Carlo Price: %.4f\n', C_mc_vec(i));
        
        fprintf('\n');
    end
end