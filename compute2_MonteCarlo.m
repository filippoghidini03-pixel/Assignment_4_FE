function C = compute2_MonteCarlo(TTM, nu, sigma, s, DF, F0, moneyness)
    % COMPUTE2_MONTECARLO Prices a European call option via Monte Carlo
    % simulation assuming log-returns driven by a Normal Inverse Gaussian
    % (NIG)-like model.
    %
    % The log-return has the form:
    %   x = sqrt(TTM)*sigma*sqrt(G)*g - (1/2 + nu)*TTM*(sigma^2)*G - lnL(nu)
    % where:
    %   g ~ N(0,1)          standard normal r.v.
    %   G ~ IG(mean=1, var=s/TTM)  Inverse Gaussian r.v.
    %   lnL(nu) = (TTM/s) * (1 - sqrt(1 + 2*s*nu*sigma^2))
    %
    % INPUTS:
    %   TTM        - Time to maturity (in years)
    %   nu         - Model parameter (controls skewness/kurtosis)
    %   sigma      - Volatility parameter
    %   s          - IG variance scaling parameter (parameter "k" on the slides)
    %   DF         - Discount factor
    %   F0         - Forward price
    %   moneyness  - ln(F0/K), i.e. log-moneyness
    %
    % OUTPUT:
    %   C          - Call option price

    N_sim = 1e6;

    % --- Derive S0 and K from inputs ---
    S0 = F0 * (1/DF);
    K  = F0 * exp(-moneyness);      % from moneyness = ln(F0/K)

    % --- Compute the log-Laplace correction term ---
    lnL = (TTM / s) * (1 - sqrt(1 + 2 * s * nu * sigma^2));

    % --- Sample G ~ IG(mu_ig=1, lambda=TTM/s) ---
    % Using the Michael-Schucany-Haas algorithm for Inverse Gaussian sampling.
    % For IG(mu, lambda): mean = mu, variance = mu^3/lambda.
    % Here: mean = 1, variance = s/TTM  =>  lambda = TTM/s.
    mu_ig     = 1;
    lambda_ig = TTM / s;

    nu_ig = randn(N_sim, 1);           % standard normal draws
    y     = nu_ig .^ 2;                % chi-squared(1) variates

    x_ig = mu_ig + (mu_ig^2 * y) / (2 * lambda_ig) ...
         - (mu_ig / (2 * lambda_ig)) .* sqrt(4 * mu_ig * lambda_ig * y + mu_ig^2 * y.^2);

    % Accept-reject step to select the correct root
    U = rand(N_sim, 1);
    accept = U <= mu_ig ./ (mu_ig + x_ig);
    G = x_ig .* accept + (mu_ig^2 ./ x_ig) .* (~accept);

    % --- Sample g ~ N(0,1) ---
    g = randn(N_sim, 1);

    % --- Simulate log-returns ---
    X = sqrt(TTM) .* sigma .* sqrt(G) .* g ...
        - (0.5 + nu) .* TTM .* (sigma^2) .* G ...
        - lnL;

    % --- Derive terminal stock prices ---
    ST = S0 * exp(X);

    % --- Compute discounted call payoff ---
    payoffs = max(ST - K, 0);
    C = DF * mean(payoffs);

end
