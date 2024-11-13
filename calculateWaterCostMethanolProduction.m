function [water_cost, process1_water, process2_water, electrolyzer_water, byproduct_water] = calculateWaterCostMethanolProduction(annual_methanol_production, green_feed_percentage, water_price_per_ton)
    % Calculate the annual water cost for methanol production based on water
    % requirements and byproducts in the process.
    %
    % Inputs:
    % - annual_methanol_production: total methanol production per year (in tons)
    % - green_feed_percentage: percentage of methanol produced using green hydrogen and CO2 feed (0 to 1 scale)
    % - water_price_per_ton: price of water per ton in currency as input.
    %
    % Outputs:
    % - water_cost: annual cost of water required for methanol production (in currency of water price)
    % - process1_water: total water consumption for Process 1 (in tons per year)
    % - process2_water: total water consumption for Process 2 (in tons per year)
    % - electrolyzer_water: total water consumption for the electrolyzer (in tons per year)
    % - byproduct_water: total water produced as byproduct in methanol synthesis (in tons per year)
    
    % Constants based on methanol production water consumption/production factors
    process1_consumption_per_ton_methanol = 0.4217; % tons of water per ton of methanol (Process 1)
    process2_consumption_per_ton_methanol = 0.4217; % tons of water per ton of methanol (Process 2)
    byproduct_production_per_ton_methanol = 0.281; % tons of water produced per ton of methanol
    electrolyzer_consumption_per_ton_methanol = 1.689; % tons of water per ton of methanol from Electrolyzer
    
    % Water consumption and production calculations
    process1_water = annual_methanol_production * (1 - green_feed_percentage) * process1_consumption_per_ton_methanol;
    process2_water = annual_methanol_production * (1 - green_feed_percentage) * process2_consumption_per_ton_methanol;
    electrolyzer_water = annual_methanol_production*green_feed_percentage * electrolyzer_consumption_per_ton_methanol;
    byproduct_water = annual_methanol_production * byproduct_production_per_ton_methanol;
    
    % Net water requirement (considering byproduct)
    net_water_requirement = process1_water + process2_water + electrolyzer_water - byproduct_water;
    
    % Annual water cost
    water_cost = net_water_requirement * water_price_per_ton;
    
    % Display results for each component
    % fprintf('\n');
    % fprintf('For green hydrogen factor of %.2f and an annual methanol production of %.2f tons \n', green_feed_percentage, annual_methanol_production);
    % fprintf('Process 1 water consumption: %.2f tons per year\n', process1_water);
    % fprintf('Process 2 water consumption: %.2f tons per year\n', process2_water);
    % fprintf('Electrolyzer water consumption: %.2f tons per year\n', electrolyzer_water);
    % fprintf('Byproduct water production: %.2f tons per year\n', byproduct_water);
    % fprintf('Total annual water cost: %.2f', water_cost);
end

