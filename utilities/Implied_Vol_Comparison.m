function [outputArg1,outputArg2] = Implied_Vol_Comparison(strikes, mkt_implied_vol, model_implied_vol)
% PLOT_VOLATILITY_CALIBRATION Visualizes the fit of a calibrated pricing model.
    %
    % Inputs:
    %   K_vec             - Array of strike prices
    %   mkt_implied_vol   - Array of market implied volatilities (decimals)
    %   model_implied_vol - Array of model implied volatilities (decimals)
    
    % Create a new figure with a clean white background
    figure('Color', 'w', 'Name', 'Calibration Results');
    
    % Plot Market Data (Blue circles, solid line)
    plot(strikes, mkt_implied_vol * 100, 'bo-', 'LineWidth', 1.5, 'MarkerSize', 6);
    hold on;
    
    % Plot Model Data (Red dashed line)
    plot(strikes, model_implied_vol * 100, 'r--', 'LineWidth', 1.5);
    hold off;
    
    % Formatting
    xlabel('Strike Price', 'FontWeight', 'bold');
    ylabel('Implied Volatility (%)', 'FontWeight', 'bold');
    title('Implied Volatility: Market vs Model');
    legend('Market IV', 'Model IV', 'Location', 'best');
    grid on;
end