clc, close all

% Version 1.0.0

% Define parameters
% This will be saved in a CSV file where the columns are the different 
% parameters and assumptions as well as the LCOM for the different options.

years = 20;
contributors = 5;        % Different Options Calculated
interest_rate = 0.05;    % Annual discount rate (5%)

EUR_USD = 1/0.92; % [EUR/USD] Updated: 5.11.2024
NOK_USD = 1/10.97; % [NOK/USD] Updated: 5.11.2024

% Define annual production target 
annual_production = 2000;  % Target annual production of methanol

% OPEX related
%   feedstocks prices
bio_methane_feed_price = 96.82; % [USD/tonn]
fossil_methane_feed_price = 60.58; % [USD/tonn]
CO2_feed_price = 50; % [USD/ton]
PPA_price = 75; % [Eur/MWh]
PPA_price_USD = PPA_price*EUR_USD; % [USD/MWh]
water_price_per_ton = 18.94*NOK_USD; % [USD/ton]

Energy_price_PPA = PPA_price_USD/1000;            % Energy price per kWh [USD/kWh]

% Electrolyzer specifics
xi = 0.5;                           % Electrolyzer factor
eta = 0.9;                          % Electrolyzer efficiency (80%)


%% Calcuale the Cost of the blended feed on annual production rate
Cost_blended_feed = calculateCostBlendedFeed(annual_production, fossil_methane_feed_price, bio_methane_feed_price, 50);
Cost_fossil_feed = calculateCostBlendedFeed(annual_production, fossil_methane_feed_price, bio_methane_feed_price, 0);
Cost_bio_feed = calculateCostBlendedFeed(annual_production, fossil_methane_feed_price, bio_methane_feed_price, 100);
[water_cost_0, process1_water_0, process2_water_0, electrolyzer_water_0, byproduct_water_0] = calculateWaterCostMethanolProduction(annual_production, 0, water_price_per_ton);

% 50 % green hydrogen (electrolyzer) + CO2 direct feedstock, 50 % bio methane feedstock
[Energy_cost_50, CO2_consumption_50, CO2_cost_50] = calculateGreenHydrogenMethanolSynthesis(xi, annual_production, eta, Energy_price_PPA, CO2_feed_price);
Cost_bio_feed_with_green_hydrogen = calculateCostBlendedFeed((1-xi)*annual_production, fossil_methane_feed_price, bio_methane_feed_price, 100);
[water_cost_50, process1_water_50, process2_water_50, electrolyzer_water_50, byproduct_water_50] = calculateWaterCostMethanolProduction(annual_production, 0.5, water_price_per_ton);


% 100 % green hydrogen (electrolyzer) + CO2 direct feedstock
[Energy_cost_100, CO2_consumption_100, CO2_cost_100] = calculateGreenHydrogenMethanolSynthesis(1, annual_production, eta, Energy_price_PPA, CO2_feed_price);
[water_cost_100, process1_water_100, process2_water_100, electrolyzer_water_100, byproduct_water_100] = calculateWaterCostMethanolProduction(annual_production, 1, water_price_per_ton);


% Initialize Capex and Opex matrices 
capex = [zeros(1, years); ... % Capex for the blended feed (50 % bio, 50 % fossil)
        zeros(1, years); ... % Capex for the fossil feed
        zeros(1, years); ... % Capex for the bio feed
        zeros(1, years); ... % Capex for the 50 % green hydrogen with CO2 feed
        zeros(1, years)];   % Capex for the 100 % green hydrogen with CO2 feed

% Capex for spesific years
capex(1,1) = 10000*(bio_methane_feed_beta/100); % Capex in year 1 for blended feed [USD]
capex(2,1) = 1000; % Capex in year 1 for fossil feed [USD]
capex(3,1) = 10000; % Capex in year 1 for bio feed [USD]

opex = [(Cost_blended_feed + water_cost_0) * ones(1, years); ... % Opex for the blended feed); ...
        (Cost_fossil_feed + water_cost_0) * ones(1, years); ...
        (Cost_bio_feed + water_cost_0) * ones(1, years); ...
        (Energy_cost_50 + CO2_cost_50 + Cost_bio_feed_with_green_hydrogen + water_cost_50) * ones(1, years); ...
        (Energy_cost_100 + CO2_cost_100 + water_cost_100) * ones(1, years)];    % Example base Opex per contributor

% Initialize matrices for discounted Capex and Opex (contributors x years)
discounted_capex = zeros(contributors, years);
discounted_opex = zeros(contributors, years);
discounted_production = zeros(1, years);

% Loop over each year to calculate discounted values for Capex, Opex, and production
for t = 1:years
    discount_factor = 1 / (1 + interest_rate)^t;  % Discount factor for year t
    
    % Apply discount factor to each contributor's Capex and Opex for year t
    for c = 1:contributors
        discounted_capex(c, t) = capex(c, t) * discount_factor;
        discounted_opex(c, t) = opex(c, t) * discount_factor;
    end
    
    % Apply discount factor to production for year t
    discounted_production(t) = annual_production * discount_factor;
end

% Total discounted Capex and Opex across all years for each contributor
npv_capex_contributor = sum(discounted_capex, 2);  % Sum across years for each contributor
npv_opex_contributor = sum(discounted_opex, 2);    % Sum across years for each contributor
total_npv_production = sum(discounted_production);  % Total NPV of production
LCOM = zeros(contributors, 1);

% Calculation of the LCOM for options calculated
for c =1:contributors
   LCOM(c) = (npv_capex_contributor(c)+npv_opex_contributor(c))/total_npv_production;
end

%% Save the values in CSV-file
%% Prepare column names and data values
columnNames = {'Years', 'Contributors', 'InterestRate', 'AnnualProduction', ...
               'BioMethaneFeedBeta', 'BioMethaneFeedPrice', 'FossilMethaneFeedPrice', ...
               'CO2FeedPrice', 'PPA_Price_EUR_MWh', 'WaterPriceNOK', ...
               'ElectrolyzerFactor', 'ElectrolyzerEfficiency', 'LCOM'};
           
dataValues = {years, contributors, interest_rate, annual_production, ...
              bio_methane_feed_beta, bio_methane_feed_price, fossil_methane_feed_price, ...
              CO2_feed_price, PPA_price, water_price_per_ton, ...
              xi, eta, LCOM};

%% Save the values in CSV file, for data analytics.
saveDataToCSV(columnNames, dataValues, 'test_data4.csv');

%% Prints for troubleshooting
LCOM

%% Plots for troubleshooting
plotDiscountedCapexOpex(discounted_capex, discounted_opex, interest_rate, years)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Cost_blended_feed = calculateCostBlendedFeed(annual_production, fossil_methane_feed_price, bio_methane_feed_price, bio_methane_feed_beta)
    % Calculate the cost of the blended feed based on the annual production rate
    % and prices of fossil and bio methane feeds.
    %
    % Inputs:
    % - annual_production: Annual production rate
    % - fossil_methane_feed_price: Price of fossil methane feed
    % - bio_methane_feed_price: Price of bio methane feed
    % - bio_methane_feed_beta: Percentage of bio methane feed (as a percentage, e.g., 50 for 50%)
    %
    % Output:
    % - Cost_blended_feed: Calculated cost of the blended feed

    % Formula for calculating the cost of blended feed
    Cost_blended_feed = (0.3838 * annual_production * fossil_methane_feed_price) - ...
        (0.3838 * annual_production * (bio_methane_feed_beta / 100) * ...
        (fossil_methane_feed_price - bio_methane_feed_price));
end

function [Energy_cost, CO2_consumption, CO2_cost] = calculateGreenHydrogenMethanolSynthesis(xi, M_methanol_production, eta, Energy_price_PPA, CO2_price)
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
    E_electrolyzer = 5019 * (xi * M_methanol_production / eta);

    % Calculate the cost of energy consumed
    Energy_cost = E_electrolyzer * Energy_price_PPA;

    % Calculate CO2 consumption based on methanol production
    CO2_consumption = 1.3736 * M_methanol_production * xi;

    % Calculate CO2 cost based on CO2 consumption and price
    CO2_cost = CO2_consumption * CO2_price;
end

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
    fprintf('\n');
    fprintf('For green hydrogen factor of %.2f and an annual methanol production of %.2f tons \n', green_feed_percentage, annual_methanol_production);
    fprintf('Process 1 water consumption: %.2f tons per year\n', process1_water);
    fprintf('Process 2 water consumption: %.2f tons per year\n', process2_water);
    fprintf('Electrolyzer water consumption: %.2f tons per year\n', electrolyzer_water);
    fprintf('Byproduct water production: %.2f tons per year\n', byproduct_water);
    fprintf('Total annual water cost: %.2f', water_cost);
end

function plotDiscountedCapexOpex(discounted_capex, discounted_opex, interest_rate, years)
    % Function to plot discounted Capex as scatter points and Opex as line plots 
    % for various feed types with Y-axis scaled to 1000 USD.
    %
    % Inputs:
    % - discounted_capex: Matrix (5 x years) containing discounted Capex for each feed type
    % - discounted_opex: Matrix (5 x years) containing discounted Opex for each feed type
    % - interest_rate: The discount rate used for discounting
    % - years: The number of years in the time series

    % Scale values to represent in thousands (kUSD)
    discounted_capex = discounted_capex / 1000;
    discounted_opex = discounted_opex / 1000;

    % Define x-axis for years
    x = 1:years;

    % Create a figure and hold on for overlaying plots
    figure;
    hold on;

    % Plot Capex as scatter points for each feed type, ignoring zeros
    % Mixed Feed Capex (Beta)
    non_zero_indices = discounted_capex(1, :) ~= 0;
    scatter(x(non_zero_indices), discounted_capex(1, non_zero_indices), 'filled', ...
        'MarkerFaceColor', [0.7 0.7 1], 'DisplayName', 'Mixed Feed Capex (Beta)');

    % Fossil Feed Capex
    non_zero_indices = discounted_capex(2, :) ~= 0;
    scatter(x(non_zero_indices), discounted_capex(2, non_zero_indices), 'filled', ...
        'MarkerFaceColor', [1 0.7 0.7], 'DisplayName', 'Fossil Feed Capex');

    % Bio Feed Capex
    non_zero_indices = discounted_capex(3, :) ~= 0;
    scatter(x(non_zero_indices), discounted_capex(3, non_zero_indices), 'filled', ...
        'MarkerFaceColor', [0.7 1 0.7], 'DisplayName', 'Bio Feed Capex');
    
    % Green Hydrogen and Bio Feedstock Mix Capex (/xi)
    non_zero_indices = discounted_capex(4, :) ~= 0;
    scatter(x(non_zero_indices), discounted_capex(4, non_zero_indices), 'filled', ...
        'MarkerFaceColor', [0.6 0.4 1], 'DisplayName', 'Green H2/Bio Feedstock Capex (/xi)');
    
    % Full Green Hydrogen and Direct CO2 Feed Capex
    non_zero_indices = discounted_capex(5, :) ~= 0;
    scatter(x(non_zero_indices), discounted_capex(5, non_zero_indices), 'filled', ...
        'MarkerFaceColor', [0.4 0.8 0.6], 'DisplayName', 'Full Green H2/CO2 Feed Capex');

    % Plot Opex as line charts for each feed type
    plot(x, discounted_opex(1, :), '-o', 'LineWidth', 1.5, 'Color', [0 0 1], 'DisplayName', 'Mixed Feed Opex (Beta)');
    plot(x, discounted_opex(2, :), '-s', 'LineWidth', 1.5, 'Color', [1 0 0], 'DisplayName', 'Fossil Feed Opex');
    plot(x, discounted_opex(3, :), '-^', 'LineWidth', 1.5, 'Color', [0 1 0], 'DisplayName', 'Bio Feed Opex');
    
    % Green Hydrogen and Bio Feedstock Mix Opex (/xi)
    plot(x, discounted_opex(4, :), '-d', 'LineWidth', 1.5, 'Color', [0.6 0.4 1], 'DisplayName', 'Green H2/Bio Feedstock Opex (/xi)');
    
    % Full Green Hydrogen and Direct CO2 Feed Opex
    plot(x, discounted_opex(5, :), '-p', 'LineWidth', 1.5, 'Color', [0.4 0.8 0.6], 'DisplayName', 'Full Green H2/CO2 Feed Opex');

    % Add title with interest rate
    title(sprintf('Discounted Capex and Opex over %d Years (Interest Rate: %.2f%%)', years, interest_rate * 100));

    % Add labels
    xlabel('Years');
    ylabel('Cost (kUSD)');

    % Add legend
    legend('show', 'Location', 'best');
    
    % Turn on grid for better readability
    grid on;
    hold off;
end