function plotPrices(x_grid, C_quad, C_MC, C_fft)

  figure;
  plot(x_grid, C_quad, '-o', 'LineWidth', 1.5, 'MarkerSize', 8);
  hold on;
  plot(x_grid, C_MC, '-x', 'LineWidth', 1.5, 'MarkerSize', 8);
  hold on
  plot(x_grid, C_fft, '-*', 'LineWidth', 1.5, 'MarkerSize', 8);
  hold off;
  grid on;
  xlabel('Log-Moneyness (x = ln(F_0 / K))');
  ylabel('Call Option Price');
  title('NIG Model Prices (Quadrature vs Monte Carlo vs FFT)');
  legend('Quadrature', 'Monte Carlo', 'FFT' );
end
