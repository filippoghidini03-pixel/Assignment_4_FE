function price = calcBlackDigital(F0, K, DF, T, sigma)
    % CALCBLACKDIGITAL computes the price of a digital call option 
    % paying 1 unit using the standard Black model formula.
    %
    % Inputs:
    %   F0    - Forward price
    %   K     - Strike price
    %   DF    - Discount Factor for maturity T
    %   T     - Time to maturity in years
    %   sigma - Implied volatility at strike K
    %
    % Output:
    %   price - The discounted Black digital price

    % Calculate the d2 parameter of the Black model
    d1 = (log(F0/K) + 0.5 * sigma^2 * T) / (sigma * sqrt(T));
    d2 = d1 - sigma * sqrt(T);
    
    % The price is the discount factor multiplied by the normal CDF of d2
    price = DF * normcdf(d2);
end