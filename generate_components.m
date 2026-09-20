function comp = generate_components(cfg)
    % GENERATE_COMPONENTS Generates stochastic component batches
    % Takes configuration struct 'cfg' and outputs a struct 'comp' containing
    % vectors of continuous random variables for R1, R2 (Gaussian) and C1, C2 (Uniform).

    % Set random generator seed for exact reproducibility across runs
    rng(cfg.seed);

    %% 1. Resistors: Gaussian (Normal) Distribution
    % Standard deviation derived so tolerance equals the specified sigma level
    sigma_R1 = (cfg.R1_nom * cfg.R1_tol) / cfg.R_sigma_level;
    sigma_R2 = (cfg.R2_nom * cfg.R2_tol) / cfg.R_sigma_level;

    % Generate N continuous random variables following N(mu, sigma^2)
    comp.R1 = cfg.R1_nom + sigma_R1 * randn(cfg.N, 1);
    comp.R2 = cfg.R2_nom + sigma_R2 * randn(cfg.N, 1);

    %% 2. Capacitors: Uniform Distribution
    % Define lower and upper tolerance bounds [a, b]
    C1_min = cfg.C1_nom * (1 - cfg.C1_tol);
    C1_max = cfg.C1_nom * (1 + cfg.C1_tol);

    C2_min = cfg.C2_nom * (1 - cfg.C2_tol);
    C2_max = cfg.C2_nom * (1 + cfg.C2_tol);

    % Generate N continuous random variables following U(a, b)
    comp.C1 = C1_min + (C1_max - C1_min) * rand(cfg.N, 1);
    comp.C2 = C2_min + (C2_max - C2_min) * rand(cfg.N, 1);
end