% capex_vs_methanol_production_reference_model_dense.m
% This script plots CAPEX vs Methanol production data
% and applies the six-tenth rule based on each reference data point.
% It uses a dense range of production points to visualize non-linearity.

% Clear the workspace and command window
clear;
clc;

% Manually collected data for Methanol production and CAPEX
% Replace these with your actual data

% DATA SOURCES
% First two data points are from the article "Renewable methanol synthesis
% from renewable H2 and Captured CO2: how can power-to-liquid technology be
% economically feasible"

MeOH_produced = [0.27*365, 100*365];  % Methanol production in tons per year
capex_costs = [562932, 32256428];     % CAPEX costs in USD

% Define the scaling factor for the six-tenth rule (can adjust as needed)
scaling_factor = 0.6;

% Generate a dense range of production values for smoother curves
dense_production = linspace(min(MeOH_produced), max(MeOH_produced), 100);

% Plotting setup for CAPEX vs Methanol Production with each reference
figure;
plot(MeOH_produced, capex_costs, 'o', 'MarkerSize', 8, 'DisplayName', 'Manual Data (CAPEX)');
hold on;

% Loop through each data point to use it as a reference
for ref_idx = 1:length(MeOH_produced)
    % Reference values
    ref_production = MeOH_produced(ref_idx);
    ref_cost = capex_costs(ref_idx);
    
    % Calculate predicted CAPEX costs based on the reference point using six-tenth rule
    predicted_costs = ref_cost * (dense_production / ref_production) .^ scaling_factor;
    
    % Plot the model for the current reference point with a dense range
    plot(dense_production, predicted_costs, '-', 'LineWidth', 2, ...
         'DisplayName', sprintf('Model (Ref: %.1f tons, $%.1f, Factor: %.1f)', ref_production, ref_cost, scaling_factor));
end

hold off;

% Adding labels, title, and legend for the plot
xlabel('Methanol Production Each Year (tons)');
ylabel('CAPEX (USD)');
title(sprintf('CAPEX vs Methanol Production with %.1f-Tenth Rule Models from Different References', scaling_factor));
legend('show');
grid on;

% Choose a specific reference point for the function to use
ref_production = MeOH_produced(2);
ref_cost = capex_costs(2);

% Calculate CAPEX for a new production level, e.g., 500 tons per year
new_production_level = 500;
estimated_capex_example = calculate_capex(new_production_level, ref_production, ref_cost, scaling_factor);

% Display the result in the terminal
fprintf('Estimated CAPEX for %d tons/year based on reference (%.2f tons/year, $%.2f, Factor: %.1f): $%.2f\n', ...
    new_production_level, ref_production, ref_cost, scaling_factor, estimated_capex_example);

% Function to use the Model for CAPEX prediction based on chosen reference
function estimated_capex = calculate_capex(production, ref_production, ref_cost, scaling_factor)
    % This function estimates CAPEX for a given production level based on a
    % reference production and CAPEX cost using the six-tenth rule.
    
    % Calculate estimated CAPEX using the six-tenth rule
    estimated_capex = ref_cost * (production / ref_production) ^ scaling_factor;
end