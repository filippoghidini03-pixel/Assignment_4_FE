clear all
close all
clc

addpath("data")
addpath("digital")
addpath("pricing_engines")
addpath("utilities")
addpath("char_func")
addpath("plot")
addpath("calibration")
%% Part 1
% Initialize parameters
params = initCertificateParams();

% Calculate the synthetic forward price and volatility of the basket
[F_basket, sigma_basket] = calculateBasket(params);

DF_T = params.DF_T ;
BondPart = (1 - params.P) * DF_T;

[callPrice, ~] = blkprice(F_basket, params.P, params.r, params.T, sigma_basket);

% The option component is the participation multiplied by the call price
OptionPart = params.participation * callPrice;
Upfront_X = (1 - BondPart - OptionPart) * 100;

fprintf('The calculated Upfront X is: %.4f%%\n', Upfront_X);
%% Part 2
% Load the data and obtain the reference date
load('eurostoxx_Poli.mat');
[Dataset, ~, ref_date] = getMarketDataStructs('MktData_CurveBootstrap.xls');

% 2008 is a leap year, so T=1 year is 366 days forward
target_date = ref_date + 366; 
yf_discount = yearfrac(ref_date, target_date, 3); 
DF = exp(-params.r * yf_discount);

fprintf('Bootstrapped 1-Year Zero Rate: %.4f%%\n', params.r * 100);
fprintf('Calculated 1-Year Discount Factor: %.6f\n\n', DF);

% Parameters
F0 = cSelect.reference;
K_vec = cSelect.strikes; sigma_vec = cSelect.surface;
Notional = 10000000; Payoff_Pct = 0.05; T = 1.0;

% Smile
[P_Black, P_Smile] = priceDigitalWithSmile(F0, K_vec, sigma_vec, DF, T, Notional, Payoff_Pct);
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
M = 15; dz = 0.00628280825805664; 

phi = ChFuncEx3( p_plus, p_minus, mu);

[C_fft, x_fft, ~] = Lewis_FFT_pricer(phi, F0, DF, M, dz);
C_fft_interp = interp1(x_fft, C_fft, x_grid, 'spline');

printPrices(x_grid, C_quad, C_mc, C_fft_interp);
%% Part 4
%Model parameters
x_grid = -0.25:0.01:0.25;
alpha = 1/2; sigma = 0.2; k = 1; eta = 3; dt = 1;
parameters = [alpha, sigma, k, eta, dt];
[C_quad, C_mc] = executePricingMethods2(x_grid, F0, DF, parameters);

phi= Levy_Model_Char_Func(alpha,sigma,k,eta,dt);

[C_fft, x_fft, z_grid] = Lewis_FFT_pricer(phi, F0, DF, M, dz);
C_fft_interp = interp1(x_fft, C_fft, x_grid, 'spline');
plotError(x_grid, C_quad, C_fft_interp)

%plotPrices(x_grid, C_quad, C_mc, C_fft_interp)
%% Part 5
%Loading Data
load('eurostoxx_Poli.mat');
F0 = cSelect.reference;
K_vec = cSelect.strikes; sigma_vec = cSelect.surface; T = 1.0;
alpha = 2/3;

% FFT param
M = 15; dz = 0.006282808;

[optimal_param, SSE, model_implied_vol] = Calibrate_NVM_model(K_vec, ...
    sigma_vec, F0, DF, T, alpha, M, dz);

Implied_Vol_Comparison(K_vec, sigma_vec, model_implied_vol);