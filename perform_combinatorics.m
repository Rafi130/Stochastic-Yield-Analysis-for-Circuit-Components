function assembled = perform_combinatorics(cfg, comp)
    % PERFORM_COMBINATORICS Assembles circuit components from available bins
    % Takes raw component populations 'comp' and configuration struct 'cfg'.
    % Supports both random assembly and smart combinatorial bin-pairing.

    N = cfg.N;

    if ~cfg.enable_smart_sorting
        %% 1. Unconstrained / Random Assembly
        % Randomly permute index vectors to simulate grabbing components 
        % off an unsorted assembly line conveyor belt.
        assembled.R1 = comp.R1(randperm(N));
        assembled.R2 = comp.R2(randperm(N));
        assembled.C1 = comp.C1(randperm(N));
        assembled.C2 = comp.C2(randperm(N));
    else
        %% 2. Constrained / Smart Combinatorial Pairing
        % Optimizes assembly by pairing high-resistance component pairs 
        % with low-capacitance component pairs to stabilize R*C time constants.

        % Calculate effective resistance metric R_eff = sqrt(R1 * R2)
        R_eff = sqrt(comp.R1 .* comp.R2);
        
        % Calculate effective capacitance metric C_eff = sqrt(C1 * C2)
        C_eff = sqrt(comp.C1 .* comp.C2);

        % Sort R_eff in ascending order (smallest to largest)
        [~, idx_R] = sort(R_eff, 'ascend');

        % Sort C_eff in descending order (largest to smallest)
        [~, idx_C] = sort(C_eff, 'descend');

        % Pair sorted indices so high R cancels out low C across the batch
        assembled.R1 = comp.R1(idx_R);
        assembled.R2 = comp.R2(idx_R);
        assembled.C1 = comp.C1(idx_C);
        assembled.C2 = comp.C2(idx_C);
    end
end