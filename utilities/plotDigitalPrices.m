function plotDigitalPrices(K_vec, Price_Black, Price_Smile, Difference)
    % PLOTDIGITALPRICES visualizes the comparison between the Black model
    % and the Smile-adjusted model for digital option prices. It generates
    % two separate figures: one for the absolute prices and one for the
    % price difference (digital risk impact).
    %
    % Inputs:
    %   K_vec       - Array of strike prices
    %   Price_Black - Array of digital option prices calculated via Black model
    %   Price_Smile - Array of digital option prices adjusted for the volatility smile
    %   Difference  - Array representing the difference between the two models

    % Create the first figure to compare the absolute prices of both models
    figure;
    plot(K_vec, Price_Black, 'b--', 'LineWidth', 1.5); 
    hold on;
    plot(K_vec, Price_Smile, 'r-', 'LineWidth', 1.5);
    
    % Add formatting to make the chart readable and professional
    title('Digital Option Price: Black vs Smile Adjusted');
    xlabel('Strike (K)');
    ylabel('Price (EUR)');
    legend('Black Model', 'Smile Adjusted');
    grid on;
    hold off;

    % Create the second figure to highlight the isolated impact of digital risk
    figure;
    plot(K_vec, Difference, 'k-', 'LineWidth', 1.5);
    
    % Add formatting for the difference chart
    title('Impact of Digital Risk (Smile - Black)');
    xlabel('Strike (K)');
    ylabel('Difference in Price (EUR)');
    grid on;
end