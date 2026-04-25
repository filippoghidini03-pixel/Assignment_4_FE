function plotError(x_grid, C_quad, C)
    figure
    plot(x_grid, abs(C_quad - C)./C_quad, '-o', 'LineWidth', 1.5, 'MarkerSize', 8);
    grid on;
    xlabel('Log-Moneyness (x = ln(F_0 / K))');
    ylabel('Relative Error');
    title('Relative Error');
end