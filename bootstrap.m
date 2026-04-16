function [dates, discounts] = bootstrap(dataSet, rateSet)
    % BOOTSTRAP Computes discount factors directly from raw data.
    % 
    % INPUTS:
    % - dataSet: Struct with fields depos, futures, swaps
    % - rateSet: Struct with fields depos, futures, swaps (col 1=Bid, col 2=Ask)
    % =========================================================================
    % 1. DATA PREPARATION & FILTERING
    % =========================================================================
    
    % --- Extract Reference Date (Settlement Date) ---
    % Based on the script comment, t0 is the first entry in the depos array.
    ref_date = dataSet.depos(1); 
    
    % --- Extract Dates ---
    % We start depos from index 2 to skip the settlement date we just extracted
    depo_dates = dataSet.depos(2:end);
    fut_settle = dataSet.futures(:, 1);
    fut_expiry = dataSet.futures(:, 2);
    swap_dates = dataSet.swaps;
    
    % --- Compute Mid-Rates (No Shock) ---
    % Depos: (Bid + Ask)/2 (Start from index 2 to match the dates)
    depo_rates = mean(rateSet.depos(2:end, 1:2), 2);
    
    % Futures: (Bid + Ask)/2 for mid-price, then convert to forward rate
    fut_rates = mean(rateSet.futures(:, 1:2), 2);
    
    % Swaps: (Bid + Ask)/2 
    swap_rates = mean(rateSet.swaps(:, 1:2), 2);
    
    % --- Apply Market Rules (Filtering) ---
    % Market rule: Depos are used until the first future settlement date
    valid_depo_idx = depo_dates <= fut_settle(1);
    clean_depo_dates = depo_dates(valid_depo_idx);
    clean_depo_rates = depo_rates(valid_depo_idx);
    
    % Market rule: Futures are used until the secodn swap date
    valid_fut_idx = fut_expiry <= swap_dates(2);
    clean_fut_settle = fut_settle(valid_fut_idx);
    clean_fut_expiry = fut_expiry(valid_fut_idx);
    clean_fut_rates = fut_rates(valid_fut_idx);
    % =========================================================================
    % 2. BOOTSTRAPPING ALGORITHM
    % =========================================================================
    
    termDates = ref_date;
    curveDiscounts = 1.0;
    
    %% DEPOS
    for i = 1:length(clean_depo_dates)
        d_date = clean_depo_dates(i);
        yf = yearfrac(ref_date, d_date, 2); % Act/360
        df = 1.0 / (1.0 + clean_depo_rates(i) * yf);
        
        termDates = [termDates; d_date];
        curveDiscounts = [curveDiscounts; df];
    end
    
    %% FUTURES
    for i = 1:length(clean_fut_settle)
        t_i = clean_fut_settle(i);
        t_i_plus_1 = clean_fut_expiry(i);
        fwd_rate = clean_fut_rates(i);
        
        yf_fut = yearfrac(t_i, t_i_plus_1, 2); % Act/360
        fwd_disc = 1.0 / (1.0 + fwd_rate * yf_fut);
        
        % Interpolate discount factor for settlement date
        discount_t_i = get_df_linear_interp(ref_date, t_i, termDates, curveDiscounts);
        discount_t_i_plus_1 = discount_t_i * fwd_disc;
        
        termDates = [termDates; t_i_plus_1];
        curveDiscounts = [curveDiscounts; discount_t_i_plus_1];
    end
    
%% SWAPS
first_s_date = swap_dates(1);
yf_1 = yearfrac(ref_date, first_s_date, 6); % 30E/360
df_1 = get_df_linear_interp(ref_date, first_s_date, termDates, curveDiscounts);

% Add the 1Y swap node to your results if not already there
%if ~any(termDates == first_s_date)
    %termDates = [termDates; first_s_date];
    %curveDiscounts = [curveDiscounts; df_1];
%end

% Initialize the BPV as the discounted cash flow of the 1st year
BPV = df_1 * yf_1; 

% 2. Loop through the remaining swaps (2Y, 3Y, etc.)
for idx = 2:length(swap_dates)
    s_date = swap_dates(idx);
    rate = swap_rates(idx);
    
    % Year fraction for the CURRENT period (e.g., from 1Y to 2Y)
    yf_current = yearfrac(swap_dates(idx-1), s_date, 6);
    
    % FORMULA: Solve for the terminal DF
    % Swap Rate = (1 - DF_n) / BPV_total 
    % => DF_n = (1 - Rate * BPV_previous_steps) / (1 + Rate * yf_current)
    df = (1.0 - rate * BPV) / (1.0 + rate * yf_current);
    
    % Append the new node
    termDates = [termDates; s_date];
    curveDiscounts = [curveDiscounts; df];
    
    % UPDATE BPV: Add the current year's discounted fraction to the total
    % This is what makes the 3Y swap "know" about the 1Y and 2Y payments
    BPV = BPV + df * yf_current;
end
    
    %% FINAL OUTPUTS
    % Return the names expected by the function signature
    dates = termDates;
    discounts = curveDiscounts;
    
end
% =========================================================================
% LOCAL HELPER FUNCTION
% =========================================================================
function discount = get_df_linear_interp(ref_date, interp_date, dates, discount_factors)
    yf_array = zeros(length(dates), 1);
    for i = 1:length(dates)
        yf_array(i) = yearfrac(ref_date, dates(i), 2); % Act/360
    end
    
    zero_rates = zeros(length(discount_factors), 1);
    valid = yf_array > 0; 
    
    zero_rates(valid) = -log(discount_factors(valid)) ./ yf_array(valid);
    if ~valid(1) && length(zero_rates) > 1
        zero_rates(1) = zero_rates(2);
    end
    
    target_yf = yearfrac(ref_date, interp_date, 2); % Act/360
    
    % extrap to prevent NaN in the curve
    interp_zero_rate = interp1(yf_array, zero_rates, target_yf, 'linear', 'extrap');
    discount = exp(-interp_zero_rate * target_yf);
end