function cfg = config_params()
    %% 1. Simulation Control Settings
    cfg.N = 100000;                     % Total circuit batch size
    cfg.seed = 42;                      % Random seed

    %% 2. Nominal Component Values (Sallen-Key Low-Pass Filter)
    cfg.R1_nom = 10e3;                  % 10 kΩ
    cfg.R2_nom = 10e3;                  % 10 kΩ
    cfg.C1_nom = 10e-9;                 % 10 nF
    cfg.C2_nom = 10e-9;                 % 10 nF

    %% 3. Component Manufacturing Distributions
    cfg.R1_tol = 0.01;                  % ±1%
    cfg.R2_tol = 0.01;                  % ±1%
    cfg.R_sigma_level = 3;              % 3-sigma level

    cfg.C1_tol = 0.06;                  % ±10%
    cfg.C2_tol = 0.06;                  % ±10%

    %% 4. Target Design Specifications & Yield Limits
    cfg.fc_target = 1 / (2 * pi * sqrt(cfg.R1_nom * cfg.R2_nom * cfg.C1_nom * cfg.C2_nom)); 
    cfg.spec_tolerance = 0.03;          % ±3% base tolerance
    
    cfg.fc_min = cfg.fc_target * (1 - cfg.spec_tolerance);
    cfg.fc_max = cfg.fc_target * (1 + cfg.spec_tolerance);

    % Quality Factor (Q) Specifications
    % Q = sqrt(R1 * R2 * C1 * C2) / (C2 * (R1 + R2))
    cfg.Q_target = sqrt(cfg.R1_nom * cfg.R2_nom * cfg.C1_nom * cfg.C2_nom) / ...
                   (cfg.C2_nom * (cfg.R1_nom + cfg.R2_nom)); % Nominal Q = 0.5
    cfg.Q_min = cfg.Q_target * (1 - cfg.spec_tolerance);
    cfg.Q_max = cfg.Q_target * (1 + cfg.spec_tolerance);

    %% 5. Assembly & Combinatorics Controls
    cfg.enable_smart_sorting = true;
end