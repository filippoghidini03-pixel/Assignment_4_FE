function params = initCertificateParams()
    % INITCERTIFICATEPARAMS initializes and returns a structure containing
    % all the market data and termsheet parameters required for pricing.
    %
    % Outputs:
    %   params - A struct containing spot prices, volatilities, yields,
    %            correlation, and certificate specifications.
 
    % Market Data for ENI and AXA
    params.S0_eni = 12.3;
    params.S0_axa = 22.1;
    params.sigma_eni = 0.201;
    params.sigma_axa = 0.183;
    params.rho = 0.49;
    params.d_eni = 0.032;
    params.d_axa = 0.029;
 
    % Weights for the equally weighted basket
    params.w_eni = 0.5;
    params.w_axa = 0.5;
 
    % Certificate Termsheet Parameters
    params.Principal = 1;
    params.P = 0.95;
    params.participation = 1.10;
    params.T = 5;
 
    % Bootstrap the discount curve from market data
    [dataSet, rateSet, ref_date] = getMarketDataStructs('MktData_CurveBootstrap.xls');
    [dates, discounts] = bootstrap(dataSet, rateSet);
 
    % Target date: 5-year maturity of the certificate (2008 is a leap year,
    % so the first year is 366 days; the remaining four are standard 365)
    target_date = ref_date + 366 + 4 * 365;
 
    % Interpolate the discount factor directly from the bootstrapped curve.
    % This is more accurate than interpolating zero rates, because discounts
    % are the primary output of the bootstrap and interpolating them avoids
    % the additional approximation introduced by converting to rates first.
    params.DF_T = interp1(dates, discounts, target_date, 'linear', 'extrap');
 
    % Derive the continuously compounded zero rate from the discount factor.
    % We use Act/365 (basis 3) consistent with the option expiry convention.
    yf = yearfrac(ref_date, target_date, 3);
    params.r = -log(params.DF_T) / yf;
end
 