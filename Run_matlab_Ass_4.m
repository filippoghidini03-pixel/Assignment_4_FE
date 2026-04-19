clear all
close all
clc

%% Part 1
% Initialize parameters
params = initCertificateParams();

% Calculate the synthetic forward price and volatility of the basket
[F_basket, sigma_basket] = calculateBasket(params);

% Calculate the Upfront X% using the bond component and blkprice
%DF_T = exp(-params.r * params.T);
%manca un pezzo
DF_T = params.DF_T ;
BondPart = (1 - params.P) * DF_T;
% Call
[callPrice, ~] = blkprice(F_basket, params.P, params.r, params.T, sigma_basket);

% The option component is the participation multiplied by the call price
OptionPart = params.participation * callPrice;

% The Upfront X is the remainder of the 100% principal after hedging costs
%da modificare 1 e bond part positiva
Upfront_X = (1 - BondPart - OptionPart) * 100;

fprintf('The calculated Upfront X is: %.4f%%\n', Upfront_X);
%% Part 2
% Load the data and obtain the reference date
[Dataset, ~, ref_date] = getMarketDataStructs('MktData_CurveBootstrap.xls');

% 2008 is a leap year, so T=1 year is 366 days forward
target_date = ref_date + 366; 

% Compute the discount factor 
yf_discount = yearfrac(ref_date, target_date, 3); 
DF = exp(-params.r * yf_discount);

fprintf('Bootstrapped 1-Year Zero Rate: %.4f%%\n', params.r * 100);
fprintf('Calculated 1-Year Discount Factor: %.6f\n\n', DF);

% Option Pricing
load('eurostoxx_Poli.mat');

% Parameters
F0 = cSelect.reference;
K_vec = cSelect.strikes;
sigma_vec = cSelect.surface;
Notional = 10000000; Payoff_Pct = 0.05; T = 1.0;

% Smile
[P_Black, P_Smile] = priceDigitalWithSmile(F0, K_vec, sigma_vec, DF, T, Notional, Payoff_Pct);

% Plotting
plotDigitalPrices(K_vec, P_Black, P_Smile, P_Smile - P_Black);
%% Part 3

% Model Parameters
p_plus = 1.5;
p_minus = 0.9;
x_grid = [-0.05223, 0, 0.15]; 

% Martingale condition: Calculate drift mu analytically to avoid rounding
mu = log((1 - 1/p_plus) * (1 + 1/p_minus));

fprintf('--- Model Parameters ---\n');
fprintf('p+ = %.1f, p- = %.1f, mu = %.6f\n\n', p_plus, p_minus, mu);
parameters = [p_plus, p_minus, mu];
% Execute Methodologies
[C_quad, C_mc] = executePricingMethods2(x_grid, F0, DF, parameters);

% FFT (Computed globally for a grid of log-moneyness x)
 M = 12;
 dz = 0.1; 
%[C_fft_interp, x_fft, C_fft] = executeFFTMethod(x_grid, F0, DF, p_plus, p_minus, mu, M, dz);
z1= -(2^M-1)*dz/2;
dx=2*pi/(2^M*dz);
x1= -(2^M-1)*dx/2;
phi = ChFuncEx3( p_plus, p_minus, mu);
[C_fft, x_fft, z_grid] = Lewis_FFT_pricer(phi, F0, DF, M, dz, x1, z1);
C_fft_interp = interp1(x_fft, C_fft, x_grid, 'spline');
for i = 1:length(x_grid)
    fprintf('FFT Price at x = %7.2f%%: %8.4f\n', x_grid(i)*100, C_fft_interp(i));
end
%% Part 4
%Model parameters
x_grid = -0.25:0.01:0.25;
alpha = 1/2;
sigma = 0.2;
k = 1;
eta = 3;
dt = 1;
parameters = [alpha, sigma, k, eta, dt];
[C_quad, C_mc] = executePricingMethods2(x_grid, F0, DF, parameters)

[C_fft, x_grid, z_grid] = Lewis_FFT_pricer(phi, F0, B, M, dz, x1, z1)
%% Part 5

%COMMENT:
% 1) Compute Call Prices using FFT, which requires:
%    i) Computing the characteristic function of the model
%    ii) Computing the integrand of Lewis formula
%    iii) FFT to compute the final price
%
% 2) OLS: we calibrate the model param (k, sigma, n)
%
% 3) Model Implied Vol via OLS on Black formula
%
% 4) Compare it with Market Data implied vol

%Loading Data
load('eurostoxx_Poli.mat');
F0 = cSelect.reference;
K_vec = cSelect.strikes; sigma_vec = cSelect.surface; T = 1.0;
alpha = 2/3;