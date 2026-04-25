function [dataSet, rateSet, ref_date] = getMarketDataStructs(filename)
    % GETMARKETDATASTRUCTS Safely reads Excel data with Dynamic Anchoring
    % to prevent readcell from shifting coordinates.
    
    % Read the Excel data
    rawData = readcell(filename); 
    
    % =========================================================================
    % DYNAMIC ANCHORING
    % Find 'Settlement' to anchor the grid and avoid readcell shifting errors
    % =========================================================================
    mask = cellfun(@(x) ischar(x) || isstring(x), rawData);
    [r_matches, c_matches] = find(mask);
    
    r_set = []; c_set = [];
    for i = 1:length(r_matches)
        if strcmp(strtrim(string(rawData{r_matches(i), c_matches(i)})), "Settlement")
            r_set = r_matches(i);
            c_set = c_matches(i);
            break;
        end
    end
    
    if isempty(r_set)
        error('Could not find "Settlement" anchor in the Excel file.');
    end
    
    % Calculate offsets assuming standard position is C8 (Row 8, Col 3)
    offset_r = r_set - 8;
    offset_c = c_set - 3;
    
    % =========================================================================
    % DATA EXTRACTION (Dynamically Offset)
    % =========================================================================
    % --- Extract Settlement Date ---
    ref_date = safeExtractDate(rawData, 8+offset_r, 5+offset_c); 

    % --- 1. Depos ---
    depo_dates = safeExtractDate(rawData, 11+offset_r:18+offset_r, 4+offset_c);
    depo_rates = cleanRates(safeExtractRate(rawData, 11+offset_r:18+offset_r, 5+offset_c:6+offset_c)) / 100;
    
    % Filter valid rows
    valid_depos = ~isnan(depo_dates) & ~isnan(depo_rates(:,1));
    dataSet.depos = [ref_date; depo_dates(valid_depos)]; 
    rateSet.depos = [NaN, NaN; depo_rates(valid_depos, :)]; 

    % --- 2. Futures ---
    % Extract Dates and Rates
    fut_dates = safeExtractDate(rawData, 12+offset_r:20+offset_r, 17+offset_c:18+offset_c);
    fut_rates = cleanRates(safeExtractRate(rawData, 28+offset_r:36+offset_r, 8+offset_c:9+offset_c)) / 100;

    % Check for valid data in both date columns and the rate column
    valid_futs = ~isnan(fut_dates(:,1)) & ~isnan(fut_dates(:,2)) & ~isnan(fut_rates(:,1));

    dataSet.futures = fut_dates(valid_futs, :);
    rateSet.futures = fut_rates(valid_futs, :);

    % --- 3. Swaps ---
    lastRow = size(rawData, 1);
    startSwap = 39 + offset_r;
    if lastRow >= startSwap
        swap_dates = safeExtractDate(rawData, startSwap:lastRow, 4+offset_c);
        swap_rates = cleanRates(safeExtractRate(rawData, startSwap:lastRow, 5+offset_c:6+offset_c)) / 100;
        
        valid_swaps = ~isnan(swap_dates) & ~isnan(swap_rates(:,1));
        dataSet.swaps = swap_dates(valid_swaps);
        rateSet.swaps = swap_rates(valid_swaps, :);
    else
        dataSet.swaps = [];
        rateSet.swaps = [];
    end
end

% =========================================================================
% LOCAL HELPER FUNCTIONS
% =========================================================================

function numArr = safeExtractDate(rawData, rows, cols)
    % Safely extracts dates and guarantees they are proper MATLAB datenums
    numArr = NaN(length(rows), length(cols));
    for r_idx = 1:length(rows)
        for c_idx = 1:length(cols)
            r = rows(r_idx);
            c = cols(c_idx);
            if r > size(rawData, 1) || c > size(rawData, 2) || r < 1 || c < 1
                continue;
            end
            val = rawData{r, c};
            if isempty(val) || (numel(val) == 1 && ismissing(val))
                numArr(r_idx, c_idx) = NaN;
            elseif isdatetime(val)
                numArr(r_idx, c_idx) = datenum(val);
            elseif isnumeric(val)
                % Shift Excel Serial Date to MATLAB Datenum (+693960 days)
                numArr(r_idx, c_idx) = double(val) + 693960;
            elseif ischar(val) || isstring(val)
                try
                    numArr(r_idx, c_idx) = datenum(val);
                catch
                    numArr(r_idx, c_idx) = NaN;
                end
            end
        end
    end
end

function numArr = safeExtractRate(rawData, rows, cols)
    % Safely extracts financial rates without altering their values
    numArr = NaN(length(rows), length(cols));
    for r_idx = 1:length(rows)
        for c_idx = 1:length(cols)
            r = rows(r_idx);
            c = cols(c_idx);
            if r > size(rawData, 1) || c > size(rawData, 2) || r < 1 || c < 1
                continue;
            end
            val = rawData{r, c};
            if isempty(val) || (numel(val) == 1 && ismissing(val))
                numArr(r_idx, c_idx) = NaN;
            elseif isnumeric(val)
                numArr(r_idx, c_idx) = double(val);
            elseif ischar(val) || isstring(val)
                numArr(r_idx, c_idx) = str2double(val);
            end
        end
    end
end

function rates = cleanRates(rates)
    % Replaces missing bid/ask spreads with the valid side of the quote
    for i = 1:size(rates, 1)
        if isnan(rates(i, 1)) && ~isnan(rates(i, 2))
            rates(i, 1) = rates(i, 2);
        elseif isnan(rates(i, 2)) && ~isnan(rates(i, 1))
            rates(i, 2) = rates(i, 1);
        end
    end
end