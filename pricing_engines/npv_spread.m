function spread_part = npv_spread( startDate, spread , spreadPaymentDates, dates, zero_rates, ref_date )
% npv_spread Calculates the Net Present Value of the spread leg of a swap.
%
% This function computes the present value of a series of spread payments.
% It uses the Act/360 convention (parameter = 2) to calculate the accrual period 
% for each payment, and the Act/365 convention (parameter = 3) to calculate the 
% discount time from the reference date.
%
% Inputs:
%   startDate          - The effective start date of the contract.
%   spread             - The spread rate
%   spreadPaymentDates - Array of adjusted payment dates.
%   dates              - Array of curve nodes for interpolation.
%   zero_rates         - Continuously compounded zero rates corresponding to the curve nodes.
%   ref_date           - The valuation date used for discounting.
%
% Output:
%   spread_part        - The total Net Present Value of the spread leg.


NPV_Spread = 0;
prevDate = startDate;

for i = 1:length(spreadPaymentDates)
    
    yf_discount = yearfrac(ref_date, spreadPaymentDates(i), 3 );

    r = interp1(dates, zero_rates, spreadPaymentDates(i), 'linear', 'extrap'); 

    DF_i = exp( -r * yf_discount );

    yf_spreadPayment = yearfrac(prevDate, spreadPaymentDates(i), 2);
    
    % Sum NPV
    NPV_Spread = NPV_Spread + (spread * yf_spreadPayment * DF_i);

    prevDate = spreadPaymentDates(i);

end


spread_part = NPV_Spread;

end




