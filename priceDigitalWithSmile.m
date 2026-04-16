function [Price_Black, Price_Smile] = priceDigitalWithSmile(F0, K_vec, sigma_vec, DF, T, Notional, Payoff_Pct)
% PRICEDIGITALWITHSMILE Calculates digital option prices using Black and Smile models.
%
% This function computes the monetary value of a digital option by accounting
% for the volatility smile. It uses the Carr-Madan approach where the digital
% price is the negative derivative of the call price with respect to the strike.
%
% USAGE:
%   [Price_Black, Price_Smile] = priceDigitalWithSmile(F0, K_vec, sigma_vec, DF, T, Notional, Payoff_Pct)
%
% INPUTS:
%   F0         : ATM Forward price
%   K_vec      : Vector of strike prices
%   sigma_vec  : Vector of implied volatilities corresponding to K_vec
%   DF         : Discount Factor to maturity
%   T          : Time to maturity in years
%   Notional   : Total nominal value of the contract
%   Payoff_Pct : The percentage of the notional paid by the digital (e.g., 0.05)
%
% OUTPUTS:
%   Price_Black : Digital price vector assuming local constant volatility
%   Price_Smile : Digital price vector accounting for the volatility skew

% We start by calculating the slope of the volatility surface. 
% The gradient function finds the change in sigma relative to the change in K.
dSigma_dK = gradient(sigma_vec, K_vec);

% We calculate d1 and d2 which are the standard components of Black-Scholes.
% d1 is used for Vega and d2 is used for the digital probability.
d1 = (log(F0 ./ K_vec) + 0.5 * sigma_vec.^2 * T) ./ (sigma_vec * sqrt(T));
d2 = d1 - sigma_vec * sqrt(T);

% The Black digital price (unit) is simply the discounted probability N(d2).
digital_black_unit = DF * normcdf(d2);

% Vega represents the sensitivity of the call price to changes in volatility.
% We need this to apply the chain rule for the total strike derivative.
vega = F0 * DF * normpdf(d1) * sqrt(T);

% The Smile-Adjusted digital price subtracts the Vega-Skew product.
% This captures the impact of the volatility slope on the digital payoff.
digital_smile_unit = digital_black_unit - (vega .* dSigma_dK);

% Finally we scale the unit prices by the actual monetary payoff amount.
% This converts the percentage-based price into a currency value.
Payout_Amount = Notional * Payoff_Pct;
Price_Black = Payout_Amount * digital_black_unit;
Price_Smile = Payout_Amount * digital_smile_unit;

end