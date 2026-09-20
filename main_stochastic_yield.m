%% MAIN_STOCHASTIC_YIELD 5-Graph Dashboard Driver Script
clear; clc; close all;

%% 1. Execute Simulation Pipeline
cfg = config_params();
comp = generate_components(cfg);
assembled = perform_combinatorics(cfg, comp);
[fc, Q] = calculate_cutoff(assembled);

%% 2. Joint Specification Yield Check (fc AND Q)
pass_mask = (fc >= cfg.fc_min & fc <= cfg.fc_max) & ...
            (Q  >= cfg.Q_min  & Q  <= cfg.Q_max);
passed_units = sum(pass_mask);
yield_pct = (passed_units / cfg.N) * 100;

%% 3. Print Summary Report
fprintf('=====================================================\n');
fprintf('     STOCHASTIC MULTI-VARIABLE YIELD ANALYSIS REPORT \n');
fprintf('=====================================================\n');
fprintf('Total Units Simulated    : %d\n', cfg.N);
fprintf('Target fc (Hz)           : %.2f (Limits: %.2f to %.2f)\n', cfg.fc_target, cfg.fc_min, cfg.fc_max);
fprintf('Target Q Factor          : %.4f (Limits: %.4f to %.4f)\n', cfg.Q_target, cfg.Q_min, cfg.Q_max);
fprintf('Joint Yield Success Rate : %.2f%% (%d / %d passed)\n', yield_pct, passed_units, cfg.N);
fprintf('=====================================================\n');

%% 4. Visualizations (2x3 Grid Dashboard)
figure('Name', 'Stochastic Yield Analysis Dashboard', 'NumberTitle', 'off', 'Position', [50, 50, 1400, 800], 'Color', [0.1 0.1 0.1]);

% --- Graph 1: Marginal PDF of fc ---
subplot(2, 3, 1);
histogram(fc, 80, 'Normalization', 'pdf', 'FaceColor', [0.2, 0.6, 0.8], 'EdgeColor', 'none', 'FaceAlpha', 0.5);
hold on;
[pdf_y, pdf_x] = ksdensity(fc);
plot(pdf_x, pdf_y, 'b-', 'LineWidth', 2);
xline(cfg.fc_target, 'w--', 'Target', 'Color', [0.8 0.8 0.8]);
xline(cfg.fc_min, 'r--'); xline(cfg.fc_max, 'r--');
grid on; xlabel('f_c (Hz)'); ylabel('PDF');
title(sprintf('1. Marginal PDF of f_c (Yield: %.2f%%)', yield_pct), 'Color', 'w');

% --- Graph 2: Pass/Fail Component Mapping (R1 vs C1) ---
subplot(2, 3, 2);
scatter(assembled.R1(pass_mask), assembled.C1(pass_mask)*1e9, 3, [0.2, 0.8, 0.2], 'filled', 'MarkerFaceAlpha', 0.2);
hold on;
scatter(assembled.R1(~pass_mask), assembled.C1(~pass_mask)*1e9, 3, [0.9, 0.2, 0.2], 'filled', 'MarkerFaceAlpha', 0.2);
grid on; xlabel('R_1 (\Omega)'); ylabel('C_1 (nF)');
title('2. Component Pass/Fail Mapping', 'Color', 'w');
legend('Pass', 'Fail', 'Location', 'northeast');

% --- Graph 3: Joint PDF of fc vs Q ---
subplot(2, 3, 3);
scatter(fc(pass_mask), Q(pass_mask), 3, [0.2, 0.8, 0.2], 'filled', 'MarkerFaceAlpha', 0.15);
hold on;
scatter(fc(~pass_mask), Q(~pass_mask), 3, [0.9, 0.2, 0.2], 'filled', 'MarkerFaceAlpha', 0.15);
rectangle('Position', [cfg.fc_min, cfg.Q_min, (cfg.fc_max - cfg.fc_min), (cfg.Q_max - cfg.Q_min)], ...
          'EdgeColor', 'w', 'LineWidth', 2, 'LineStyle', '--');
grid on; xlabel('Cutoff Frequency f_c (Hz)'); ylabel('Quality Factor Q');
title('3. Joint PDF Space: f_c vs Q', 'Color', 'w');

% --- Graph 4: Yield Sensitivity Curve ---
subplot(2, 3, 4);
tol_range = linspace(0.005, 0.10, 50);
yield_curve = zeros(size(tol_range));
for i = 1:length(tol_range)
    f_l = cfg.fc_target * (1 - tol_range(i));
    f_h = cfg.fc_target * (1 + tol_range(i));
    q_l = cfg.Q_target * (1 - tol_range(i));
    q_h = cfg.Q_target * (1 + tol_range(i));
    yield_curve(i) = mean((fc >= f_l & fc <= f_h) & (Q >= q_l & Q <= q_h)) * 100;
end
plot(tol_range * 100, yield_curve, 'm-', 'LineWidth', 2);
hold on;
xline(cfg.spec_tolerance * 100, 'w--', 'Current Spec (±3%)', 'Color', [0.8 0.8 0.8], 'LabelOrientation', 'aligned');
yline(yield_pct, 'g--', sprintf('Current Yield (%.1f%%)', yield_pct), 'LabelHorizontalAlignment', 'right');
grid on; xlabel('Spec Window Tolerance (±%)'); ylabel('Yield (%)');
title('4. Yield Sensitivity vs Spec Window', 'Color', 'w');

% --- Graph 5: Component Sensitivity Analysis ---
subplot(2, 3, 5);
corr_matrix = corr([assembled.R1, assembled.R2, assembled.C1, assembled.C2], fc);
bar(corr_matrix, 'FaceColor', [0.5, 0.3, 0.8]);
set(gca, 'XTickLabel', {'R_1', 'R_2', 'C_1', 'C_2'});
grid on; ylabel('Pearson Correlation with f_c');
title('5. Component Sensitivity to f_c Shift', 'Color', 'w');

% --- Graph 6: Box Plot of Normalized Component & Output Variances ---
subplot(2, 3, 6);

% Normalize all variations to percentage deviation from nominal (%)
dev_R1 = ((assembled.R1 - cfg.R1_nom) / cfg.R1_nom) * 100;
dev_R2 = ((assembled.R2 - cfg.R2_nom) / cfg.R2_nom) * 100;
dev_C1 = ((assembled.C1 - cfg.C1_nom) / cfg.C1_nom) * 100;
dev_C2 = ((assembled.C2 - cfg.C2_nom) / cfg.C2_nom) * 100;
dev_fc = ((fc - cfg.fc_target) / cfg.fc_target) * 100;

% Group data into a matrix for boxplot
box_data = [dev_R1, dev_R2, dev_C1, dev_C2, dev_fc];

% Draw box plot
boxplot(box_data, 'Labels', {'R_1', 'R_2', 'C_1', 'C_2', 'f_c'});
hold on;

% Draw ±3% Spec Limit lines across the boxplot
yline(cfg.spec_tolerance * 100, 'r--', 'Upper Spec');
yline(-cfg.spec_tolerance * 100, 'r--', 'Lower Spec');

grid on;
ylabel('Deviation from Nominal (%)');
title('6. Component vs Output Spread (Box Plot)', 'Color', 'w');