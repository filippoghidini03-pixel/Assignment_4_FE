function printPrices(x_grid, C_quad, C_MC, C_fft)

for i = 1:length(x_grid)
    fprintf('--- Pricing for Moneyness x = %.2f%% ---\n', x_grid(i)*100);
    fprintf('Quadrature Price:  %.4f\n', C_quad(i));
    fprintf('Monte Carlo Price: %.4f\n', C_MC(i));
    fprintf('FFT Price:         %.4f\n', C_fft(i));
    fprintf('\n');
end
end