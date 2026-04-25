function spread_dates = spreadPaymentDates (startDate, Maturity, paymentsPerYear )
% spreadPaymentDates Generates an adjusted payment schedule backward from maturity.
%
% This function calculates the payment dates for a swap leg.
% It generates and adjusts the dates rolling backward from the maturity using
% the "Modified Following" business day convention.
%
% Inputs:
%   startDate           - The effective start date of the contract.
%   Maturity            - The total length of the contract in years.
%   paymentsPerYear     - The number of payments per year.
%
% Output:
%   spread_dates        - Array of adjusted payment dates.


% Define the unadjusted Maturity Date
numberOfMonths = Maturity * 12;
maturityDateUnadjusted = datemnth(startDate, numberOfMonths); 
numPayments = Maturity * paymentsPerYear ;

% Generate unadjusted dates backward
step = 12 / paymentsPerYear;
monthsGoingBack = (0:numPayments-1) * step;

% Generate backward dates and flip the array to restore chronological order
unadjustedDatesBackward = datemnth(maturityDateUnadjusted, -monthsGoingBack);
unadjustedDates = flip(unadjustedDatesBackward);

% Modified Following business day convention 
spread_dates = busdate(unadjustedDates, 'modifiedfollow');

end