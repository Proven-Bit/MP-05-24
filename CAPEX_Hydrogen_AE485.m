% Function to use the Model for CAPEX prediction based on chosen reference
function estimated_capex = CAPEX_Hydrogen_AE485(production, ref_cost_per_kw)
    A484_KW = 2200; % kW value of one A484 series unit. 
    estimated_cost_per_unit = ref_cost_per_kw*A484_KW;
    % Calculate estimated CAPEX for X-units + 1 (for redundancy)
    N = (0.0004953 * production) + 1;
    estimated_capex = N * estimated_cost_per_unit ;
end
