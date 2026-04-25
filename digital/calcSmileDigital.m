function price = calcSmileDigital(F0, K, DF, T, sigma, dSigma_dK)
    % CALCSMILEDIGITAL computes the price of a digital call option 
    % taking into account the slope of the implied volatility smile.
    %
    % Inputs:
    %   F0        - Forward price
    %   K         - Strike price
    %   DF        - Discount Factor for maturity T
    %   T         - Time to maturity in years
    %   sigma     - Implied volatility at strike K
    %   dSigma_dK - The partial derivative of volatility with respect to K
    %
    % Output:
    %   price     - The smile-adjusted digital price

    % First component is the standard Black digital price
    black_digital = calcBlackDigital(F0, K, DF, T, sigma);
    
    % We calculate d1 to compute the Vega of the call option
    d1 = (log(F0/K) + 0.5 * sigma^2 * T) / (sigma * sqrt(T));
    
    % Vega calculation for a Black call option. 
    % Note that we use the forward F0 and discount DF.
    vega = F0 * DF * normpdf(d1) * sqrt(T);
    
    % The smile price applies the chain rule correction
    price = black_digital - (vega * dSigma_dK);
end