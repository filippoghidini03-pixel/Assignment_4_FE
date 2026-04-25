function npv_coupon = compute_npv_coupon( S_t, P, sigma, T, DF_T )
% compute_npv_coupon computes the net present value of the coupon defined as
% the positive difference (S_t - P).
%
% The coupon's npv is computed as:
%   C_npv = DF_T * ( S_t * N(d1) - P * N(d2) )
% where:
%   d1 = [ln(S_t / P) + 0.5 * sigma^2 * T] / (sigma * sqrt(T))
%   d2 = d1 - sigma * sqrt(T)
%   N(.) denotes the cumulative distribution function of a standard normal.
%
% INPUTS:
%   S_t     - Value (performance) of the equally weighted basket at
%             maturity date t. It is calculated as the weighted sum of the 
%             normalized performances of the individual underlyings: 
%             S(t) = sum( (E_t / E_0) * W_n ).
%   P       - Protection
%   sigma   - Volatility of the basket, derived from the volatilities of 
%             the individual assets and their correlation
%   T       - Time to maturity (in years)
%   DF_T    - Discount factor to maturity T
%
% OUTPUT:
%   npv_coupon - Net present value of the coupon

d1 = (log(S_t / P) + 0.5 * (sigma^2) * T) / (sigma * sqrt(T));
d2 = d1 - sigma * sqrt(T);

Nd1 = normcdf(d1);
Nd2 = normcdf(d2);

% Price of the coupon's NPV
npv_coupon = DF_T * (S_t * Nd1 - P * Nd2);

end