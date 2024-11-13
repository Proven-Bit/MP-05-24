% Function to use the Model for CAPEX prediction based on chosen reference
function estimated_capex = CAPEX_SMR(production, ref_production, ref_cost, scaling_factor)
    % This function estimates CAPEX for a given production level based on a
    % reference production and CAPEX cost using the six-tenth rule.
    
    % Calculate estimated CAPEX using the six-tenth rule
    estimated_capex = ref_cost * (production / ref_production) ^ scaling_factor;
end
