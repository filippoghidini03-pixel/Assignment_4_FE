function [f_hat, x_grid, z_grid] = FFT_Engine(integrand, dz, x1, z1, M)

% N = 2^M
N = 2.^M;

% dx*dz = 2*pi/N  (enforced)
dx = 2 * pi / (N * dz);           

% Building grids
idx = (0 : N-1);
x_grid = x1 + idx .* dx;              
z_grid = z1 + idx .* dz;

% Evaluate the function passed in input (ideally, the integrand)
f_j = integrand(x_grid); 

% h_j = f_j * exp(-i * (j-1) * dx * z1), function whose FFT we actually
% compute
twist = exp(-1i .* idx .* dx .* z1); 
h_j = f_j(:).' .* twist;

% FFT NO PREFACTOR YET
raw_fft = fft(h_j, N);

% Final FFT Evaluation
prefactor = dx .* exp(-1i .* x1 .* z_grid);   
f_hat = prefactor .* raw_fft;  

end