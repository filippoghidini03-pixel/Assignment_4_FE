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
    params.spread = 0.013;
    params.paymentsPerYear = 4;
    params.T = 5;
    params.startDate = datenum('19-Feb-2008');
 
    % Bootstrap the discount curve from market data
    [dataSet, rateSet, ref_date] = getMarketDataStructs('MktData_CurveBootstrap.xls');
    [dates, discounts] = bootstrap(dataSet, rateSet);
 
    % Target date: 5-year maturity of the certificate (2008 is a leap year,
    % so the first year is 366 days; the remaining four are standard 365)
    target_date = ref_date + 366 + 4 * 365;
 
    % Interpolate the zero rates
    yf = yearfrac(ref_date, dates, 3);
    zero_rates = -log(discounts) ./ yf;
    params.r = interp1(dates, zero_rates, target_date, 'linear', 'extrap');

    % Derive the Discount Factor
    yf_targetDate =  yearfrac(ref_date, target_date, 3);
    params.DF_T = exp (- yf_targetDate * params.r);

    % Saving parameters for next functions
    params.zero_rates = zero_rates;
    params.dates = dates;
    params.ref_date = ref_date;

end
 