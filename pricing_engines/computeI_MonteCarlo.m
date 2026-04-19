function C = computeI_MonteCarlo(x, F0, DF, K, p_plus, p_minus, mu)
    % COMPUTEI_MONTECARLO Prices the call option by simulating the specific 
    % probability distribution encoded in the characteristic function.
    
    N_sim = 1000000; 
    
    % The characteristic function represents a random variable X = mu + E1
    % - E2, because we may decompose it into the product of three
    % characteristic functions
    
    U1 = rand(N_sim, 1);
    U2 = rand(N_sim, 1);
    
    % Inverse transform sampling to generate Exponential random variables
    E1 = -log(U1) / p_plus;
    E2 = -log(U2) / p_minus;
    
    % Simulate the final log-returns
    X_T = mu + E1 - E2;
    
    % Calculate the asset prices at maturity
    % Error
    S_T = F0 * exp(X_T);
    
    % Calculate payoffs and take the discounted average
    payoffs = max(S_T - K, 0);
    C = DF * mean(payoffs);
end