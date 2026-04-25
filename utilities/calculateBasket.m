function [F_basket, sigma_basket] = calculateBasket(params)
    % CALCULATEBASKET computes the normalized forward price and the 
    % combined volatility of the two-asset basket.
    %
    % Inputs:
    %   params - Struct containing market data and termsheet parameters
    %
    % Outputs:
    %   F_basket     - The normalized forward price of the basket at T
    %   sigma_basket - The calculated volatility of the basket

    % Extract variables for cleaner mathematical formulas
    T = params.T;
    r = params.r;
    
    % Calculate the individual forward prices adjusting for dividend yields
    F_eni = params.S0_eni * exp((r - params.d_eni) * T);
    F_axa = params.S0_axa * exp((r - params.d_axa) * T);
    
    % Calculate the normalized forward of the basket
    % We divide the forward by the spot to normalize the starting value to 1
    normalized_eni = F_eni / params.S0_eni;
    normalized_axa = F_axa / params.S0_axa;
    F_basket = params.w_eni * normalized_eni + params.w_axa * normalized_axa;
    
    % Calculate the variance of the basket using the covariance formula
    var_eni = (params.w_eni * params.sigma_eni)^2;
    var_axa = (params.w_axa * params.sigma_axa)^2;
    covar = 2 * params.w_eni * params.w_axa * params.sigma_eni * params.sigma_axa * params.rho;
    
    % The basket volatility is the square root of the total variance
    sigma_basket = sqrt(var_eni + var_axa + covar);
end