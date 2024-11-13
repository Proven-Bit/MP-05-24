function [Energy_cost, CO2_consumption, CO2_cost] = calculateGreenHydrogenMethanolSynthesis(xi, M_methanol_production, eta, Energy_price_PPA, CO2_price, V)
    % Function to calculate the cost of energy consumed for green hydrogen production,
    % the CO2 consumption, and the cost of CO2 in the methanol synthesis process.
    %
    % Inputs:
    % - xi: Electrolyzer factor (unitless)
    % - M_methanol_production: Amount of methanol produced (in tonnes)
    % - eta: Electrolyzer efficiency (fraction between 0 and 1)
    % - Energy_price_PPA: Price of energy per kWh (in currency units per kWh)
    % - CO2_price: Price of CO2 per tonne (in currency units per tonne)
    %
    % Outputs:
    % - Energy_cost: Total cost of energy consumed (in currency units)
    % - CO2_consumption: CO2 consumption (in tonnes)
    % - CO2_cost: Total cost of CO2 (in currency units)

    % Calculate electricity consumption of the electrolyzer in kWh
    E_electrolyzer = 5019 * (xi * M_methanol_production * V / eta);

    % Calculate the cost of energy consumed
    Energy_cost = E_electrolyzer * Energy_price_PPA;

    % Calculate CO2 consumption based on methanol production
    CO2_consumption = 1.3736 * M_methanol_production * xi;

    % Calculate CO2 cost based on CO2 consumption and price
    CO2_cost = CO2_consumption * CO2_price;
end

