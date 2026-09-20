function [fc, Q] = calculate_cutoff(assembled)
    % CALCULATE_CUTOFF Computes cutoff frequency (fc) and Quality Factor (Q)
    
    num = sqrt(assembled.R1 .* assembled.R2 .* assembled.C1 .* assembled.C2);
    den = assembled.C2 .* (assembled.R1 + assembled.R2);

    fc = 1 ./ (2 * pi * num);
    Q  = num ./ den;
end