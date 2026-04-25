function [C_quad, C_MC] = executePricingMethods2(x_grid, F0, DF, parameters)
%Compute Call Prices using Quadrature and Monte Carlo for exercises 3 and 4
%IMPUTS:
% x_grid: grid of log-moneyness values
% F0: forward price
% DF: discount factor
% parameters: vectors of parameters [p_plus/alpha, p_minus/sigma, mu/k, eta, dt]
%OUTPUTS:
% C_quad: call prices using quadrature
% C_MC: call prices using Monte Carlo
N      = length(x_grid);
C_quad = zeros(1, N);
C_MC   = zeros(1, N);

if length(parameters) == 3
    p_plus = parameters(1);
    p_minus = parameters(2);
    mu = parameters(3);
    phi = ChFuncEx3( p_plus, p_minus, mu);
     for i = 1:N
        x = x_grid(i);
        K = F0 * exp(-x);
        
        %fprintf('--- Pricing for Moneyness x = %.2f%% (Strike K = %.2f) ---\n', x*100, K);
        
        % a. Quadrature
        C_quad(i) = compute2_Quadrature(x, F0, DF, phi);
        %fprintf('a. Quadrature Price:  %.4f\n', C_quad(i));
        
        % b. Monte Carlo Simulation
        C_MC(i) = computeI_MonteCarlo(x, F0, DF, K, p_plus, p_minus, mu);
        %fprintf('c. Monte Carlo Price: %.4f\n', C_MC(i));
        
        %fprintf('\n');
    end
end
if length(parameters) == 5
    alpha = parameters(1);
    sigma = parameters(2);
    k = parameters(3);
    eta = parameters(4);
    dt = parameters(5);
    phi = Levy_Model_Char_Func(alpha, sigma, k, eta, dt);
    for i = 1:N
        x = x_grid(i);
        C_quad(i) = compute2_Quadrature(x, F0, DF, phi);
        C_MC(i) = compute2_MonteCarlo(x, F0, DF, alpha, sigma, k, eta, dt);
    end
    
    %{
     Plot the prices
    figure;
    plot(x_grid, C_quad, '-o', 'LineWidth', 1.5, 'MarkerSize', 8);
    hold on;
    plot(x_grid, C_MC, '-x', 'LineWidth', 1.5, 'MarkerSize', 8);
    hold off;
    grid on;
    xlabel('Log-Moneyness (x = ln(F_0 / K))');
    ylabel('Call Option Price');
    title('NIG Model Prices (Quadrature vs Monte Carlo)');
    legend('Quadrature', 'Monte Carlo', 'Location', 'best');
    %}
end


    
    