clc, close all

% Version 2.0.0
file_name_write = 'test_data13.csv';
years = 20;
contributors = 5;

% Define base case parameters
annual_discount_rate = 0.08;
eur_to_usd = 1 / 0.92; 
nok_to_usd = 1 / 10.97;
annual_production = 2000;
bio_methane_price = 96.82;
fossil_methane_price = 60.58;
co2_price = 50;
ppa_price_eur_mwh = 75;
ppa_price_usd_mwh = ppa_price_eur_mwh * eur_to_usd;
water_price_usd_ton = 18.94 * nok_to_usd;
energy_cost_per_kwh = ppa_price_usd_mwh / 1000;
smr_misc_opex_fraction = 0.30;
electrolyzer_misc_opex_fraction = 0.30;
electrolyzer_factor = 0.5;
electrolyzer_efficiency = 0.7;
electrolyzer_voltage = 1.9;
electrolyzer_capex_per_kw = 1112;
electrolyzer_lifetime_years = 20;
smr_ref_production = 36500;
smr_ref_capex = 32256428;
smr_scaling_factor = 0.7;
smr_lifetime_years = 10;

% Methanol Markets Parameters
methanol_price = 450;

% Sensitivity Analysis Spected from -% - +% of base case parameters
Sensitivity_Analysis_limits = 0.15; % uper and lower limits away from base case params.
% Define a range of sensitivity values (5 lower and 5 higher than baseline)
baseline_value = 1;
num_variations = 5;
variation_factor = 0.15/num_variations;  % %-variation per step

annual_methanol_production = annual_production;

% Create sensitivity range
sensitivity_range = baseline_value * (1 - variation_factor * (num_variations:-1:1));
sensitivity_range = [sensitivity_range, baseline_value, baseline_value * (1 + variation_factor * (1:num_variations))];



%% Calcuale the Cost of the blended feed on annual production rate for the base case parameters
% 50 % bio and 50 % fossil feed
Cost_blended_feed = calculateCostBlendedFeed(annual_production, fossil_methane_price, bio_methane_price, 50);
% 100 % fossil
Cost_fossil_feed = calculateCostBlendedFeed(annual_production, fossil_methane_price, bio_methane_price, 0);
% 100 % bio feed
Cost_bio_feed = calculateCostBlendedFeed(annual_production, fossil_methane_price, bio_methane_price, 100);
[water_cost_0, process1_water_0, process2_water_0, electrolyzer_water_0, byproduct_water_0] = ...
    calculateWaterCostMethanolProduction(annual_production, 0, water_price_usd_ton);
    
% 50 % green hydrogen (electrolyzer) + CO2 direct feedstock, 50 % bio methane feedstock
[Energy_cost_50, CO2_consumption_50, CO2_cost_50] = calculateGreenHydrogenMethanolSynthesis(electrolyzer_factor, ...
    annual_production, electrolyzer_efficiency, energy_cost_per_kwh, co2_price, electrolyzer_voltage);
Cost_bio_feed_with_green_hydrogen = calculateCostBlendedFeed((1-electrolyzer_factor)*annual_production, ...
    fossil_methane_price, bio_methane_price, 100);
[water_cost_50, process1_water_50, process2_water_50, electrolyzer_water_50, byproduct_water_50] = ...
    calculateWaterCostMethanolProduction(annual_production, 0.5, water_price_usd_ton);
    
% 100 % green hydrogen (electrolyzer) + CO2 direct feedstock
[Energy_cost_100, CO2_consumption_100, CO2_cost_100] = calculateGreenHydrogenMethanolSynthesis(1, annual_production, ...
    electrolyzer_efficiency, energy_cost_per_kwh, co2_price, electrolyzer_voltage);
[water_cost_100, process1_water_100, process2_water_100, electrolyzer_water_100, byproduct_water_100] = ...
    calculateWaterCostMethanolProduction(annual_production, 1, water_price_usd_ton);
    
% calculation of CAPEX'es
SMR_100_CAPEX_10_year = CAPEX_SMR(annual_production, smr_ref_production, smr_ref_capex, smr_scaling_factor);
SMR_50_CAPEX_10_year = CAPEX_SMR(annual_production/2, smr_ref_production, smr_ref_capex, smr_scaling_factor);
% Hydrogen_50_Capex_20_year
Green_hydrogen_50_CAPEX_20_year = CAPEX_Hydrogen_AE485(annual_production/2, electrolyzer_capex_per_kw);
Green_hydrogen_100_CAPEX_20_year = CAPEX_Hydrogen_AE485(annual_production, electrolyzer_capex_per_kw);
% Initialize Capex and Opex matrices 
capex = [zeros(1, years); ... % Capex for the blended feed (50 % bio, 50 % fossil)
        zeros(1, years); ... % Capex for the fossil feed
        zeros(1, years); ... % Capex for the bio feed
        zeros(1, years); ... % Capex for the 50 % green hydrogen with CO2 feed
        zeros(1, years)];   % Capex for the 100 % green hydrogen with CO2 feed
    
% Capex for spesific years
capex(1,1) = SMR_100_CAPEX_10_year; % Capex in year 1 for blended feed [USD]
capex(1,10) = SMR_100_CAPEX_10_year; % Capex in year 1 for blended feed [USD]
capex(2,1) = SMR_100_CAPEX_10_year; % Capex in year 1 for fossil feed [USD]
capex(2,10) = SMR_100_CAPEX_10_year; % Capex in year 1 for fossil feed [USD]
capex(3,1) = SMR_100_CAPEX_10_year; % Capex in year 1 for bio feed [USD]
capex(3,10) = SMR_100_CAPEX_10_year; % Capex in year 1 for bio feed [USD]
capex(4,1) = SMR_50_CAPEX_10_year + Green_hydrogen_50_CAPEX_20_year; % Capex in year 1 for bio feed [USD]
capex(4,10) = SMR_50_CAPEX_10_year; % Capex in year 1 for bio feed [USD]
capex(5,1) = SMR_50_CAPEX_10_year + Green_hydrogen_100_CAPEX_20_year; % Capex in year 1 for bio feed [USD]
    
opex = [(Cost_blended_feed + water_cost_0 +(smr_misc_opex_fraction*(Cost_blended_feed + water_cost_0)/...
    (1-smr_misc_opex_fraction))) * ones(1, years); ... % Opex for the blended feed); ...
  (Cost_fossil_feed + water_cost_0 + (smr_misc_opex_fraction*(Cost_fossil_feed + water_cost_0)/(1-smr_misc_opex_fraction))) ...
  * ones(1, years);
  (Cost_bio_feed + water_cost_0 + (smr_misc_opex_fraction*(Cost_bio_feed + water_cost_0)/ ...
  (1-smr_misc_opex_fraction))) * ones(1, years); ...
  (Energy_cost_50 + CO2_cost_50 + Cost_bio_feed_with_green_hydrogen + water_cost_50 + ...
  (smr_misc_opex_fraction*Green_hydrogen_50_CAPEX_20_year) + ...
  (smr_misc_opex_fraction*(Cost_bio_feed_with_green_hydrogen + ...
  water_cost_0)/(1-smr_misc_opex_fraction))) * ones(1, years); ...
  (Energy_cost_100 + CO2_cost_100 + water_cost_100 + (electrolyzer_misc_opex_fraction*Green_hydrogen_100_CAPEX_20_year))...
  * ones(1, years)];    % Example base Opex per contributor
    
% Initialize matrices for discounted Capex and Opex (contributors x years)
discounted_capex = zeros(contributors, years);
discounted_opex = zeros(contributors, years);
discounted_production = zeros(1, years);
discounted_income = zeros(1, years);
% Loop over each year to calculate discounted values for Capex, Opex, and production
for t = 1:years
    discount_factor = 1 / (1 + annual_discount_rate)^t;  % Discount factor for year t
    
    % Apply discount factor to each contributor's Capex and Opex for year t
    for c = 1:contributors
        discounted_capex(c, t) = capex(c, t) * discount_factor;
        discounted_opex(c, t) = opex(c, t) * discount_factor;
    end
    
    % Apply discount factor to production for year t
    discounted_production(t) = annual_production * discount_factor;
    discounted_income(t) = annual_production * methanol_price * discount_factor;
end
% Total discounted Capex and Opex across all years for each contributor
npv_capex_contributor = sum(discounted_capex, 2);  % Sum across years for each contributor
npv_opex_contributor = sum(discounted_opex, 2);    % Sum across years for each contributor
total_npv_production = sum(discounted_production);  % Total NPV of production
npv_income = sum(discounted_income); % Total NPV of Income from Sales
LCOM = zeros(contributors, 1);
NPV = zeros(contributors, 1);
NPV_premium = zeros(contributors, 1);
    
% Calculation of the LCOM for options calculated
for c = 1:contributors
    LCOM(c) = (npv_capex_contributor(c)+npv_opex_contributor(c))/total_npv_production;
    NPV(c) = npv_income - (npv_opex_contributor(c) + npv_capex_contributor(c));
end
   

% Print base case parameters and results to command window
fprintf('\n--- Base Case Parameters ---\n');
fprintf('Annual Discount Rate: %.2f%%\n', annual_discount_rate * 100);
fprintf('EUR to USD Conversion: %.4f\n', eur_to_usd);
fprintf('NOK to USD Conversion: %.4f\n', nok_to_usd);
fprintf('Annual Methanol Production (tons): %d\n', annual_methanol_production);
fprintf('Bio Methane Price (USD): %.2f\n', bio_methane_price);
fprintf('Fossil Methane Price (USD): %.2f\n', fossil_methane_price);
fprintf('CO2 Price (USD): %.2f\n', co2_price);
fprintf('PPA Price (EUR/MWh): %.2f\n', ppa_price_eur_mwh);
fprintf('PPA Price (USD/MWh): %.2f\n', ppa_price_usd_mwh);
fprintf('Water Price (USD/ton): %.2f\n', water_price_usd_ton);
fprintf('Energy Cost (USD/kWh): %.4f\n', energy_cost_per_kwh);
fprintf('SMR Misc. OPEX Fraction: %.2f\n', smr_misc_opex_fraction);
fprintf('Electrolyzer Misc. OPEX Fraction: %.2f\n', electrolyzer_misc_opex_fraction);
fprintf('Electrolyzer Factor: %.2f\n', electrolyzer_factor);
fprintf('Electrolyzer Efficiency: %.2f\n', electrolyzer_efficiency);
fprintf('Electrolyzer Voltage (V): %.2f\n', electrolyzer_voltage);
fprintf('Electrolyzer CAPEX (USD/kW): %.2f\n', electrolyzer_capex_per_kw);
fprintf('Electrolyzer Lifetime (years): %d\n', electrolyzer_lifetime_years);
fprintf('SMR Reference Production (tons): %d\n', smr_ref_production);
fprintf('SMR Reference CAPEX (USD): %.2f\n', smr_ref_capex);
fprintf('SMR Scaling Factor: %.2f\n', smr_scaling_factor);
fprintf('SMR Lifetime (years): %d\n', smr_lifetime_years);
fprintf('Methanol Price (USD): %.2f\n\n', methanol_price);

fprintf('--- Results ---\n');
for i = 1:5
    fprintf('Scenario %d: LCOM = %.2f USD, NPV = %.2f USD\n', i, LCOM(i), NPV(i));
end

% Open the file in append mode
fileID = fopen('Results.txt', 'a');

% Record the current date and time
% Add a divider for clarity
fprintf(fileID, '\n');
fprintf(fileID, '========================================\n');
currentTime = datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss');
fprintf(fileID, '--- New Results Recorded on %s ---\n', currentTime);
fprintf(fileID, '========================================\n');
fprintf(fileID, '--- Base Case Parameters ---\n');

% Write the base case parameters
fprintf(fileID, 'Annual Discount Rate: %.2f%%\n', annual_discount_rate * 100);
fprintf(fileID, 'EUR to USD Conversion: %.4f\n', eur_to_usd);
fprintf(fileID, 'NOK to USD Conversion: %.4f\n', nok_to_usd);
fprintf(fileID, 'Annual Methanol Production (tons): %d\n', annual_methanol_production);
fprintf(fileID, 'Bio Methane Price (USD): %.2f\n', bio_methane_price);
fprintf(fileID, 'Fossil Methane Price (USD): %.2f\n', fossil_methane_price);
fprintf(fileID, 'CO2 Price (USD): %.2f\n', co2_price);
fprintf(fileID, 'PPA Price (EUR/MWh): %.2f\n', ppa_price_eur_mwh);
fprintf(fileID, 'PPA Price (USD/MWh): %.2f\n', ppa_price_usd_mwh);
fprintf(fileID, 'Water Price (USD/ton): %.2f\n', water_price_usd_ton);
fprintf(fileID, 'Energy Cost (USD/kWh): %.4f\n', energy_cost_per_kwh);
fprintf(fileID, 'SMR Misc. OPEX Fraction: %.2f\n', smr_misc_opex_fraction);
fprintf(fileID, 'Electrolyzer Misc. OPEX Fraction: %.2f\n', electrolyzer_misc_opex_fraction);
fprintf(fileID, 'Electrolyzer Factor: %.2f\n', electrolyzer_factor);
fprintf(fileID, 'Electrolyzer Efficiency: %.2f\n', electrolyzer_efficiency);
fprintf(fileID, 'Electrolyzer Voltage (V): %.2f\n', electrolyzer_voltage);
fprintf(fileID, 'Electrolyzer CAPEX (USD/kW): %.2f\n', electrolyzer_capex_per_kw);
fprintf(fileID, 'Electrolyzer Lifetime (years): %d\n', electrolyzer_lifetime_years);
fprintf(fileID, 'SMR Reference Production (tons): %d\n', smr_ref_production);
fprintf(fileID, 'SMR Reference CAPEX (USD): %.2f\n', smr_ref_capex);
fprintf(fileID, 'SMR Scaling Factor: %.2f\n', smr_scaling_factor);
fprintf(fileID, 'SMR Lifetime (years): %d\n', smr_lifetime_years);
fprintf(fileID, 'Methanol Price (USD): %.2f\n\n', methanol_price);

% Write the results
fprintf(fileID, '--- Results ---\n');
for i = 1:5
    fprintf(fileID, 'Scenario %d: LCOM = %.2f USD, NPV = %.2f USD\n', i, LCOM(i), NPV(i));
end

% Close the file
fclose(fileID);

%% Plots for troubleshooting
plotDiscountedCapexOpex(discounted_capex, discounted_opex, annual_discount_rate, years)

%% Sensitivity analysis

% Put all variables into an array that will be looped over
parameters = [
    annual_discount_rate, ... % 1
    eur_to_usd, ... % 2
    nok_to_usd, ... % 3
    annual_methanol_production, ... % 4
    bio_methane_price, ... % 5
    fossil_methane_price, ... % 6
    co2_price, ... % 7
    ppa_price_eur_mwh, ... % 8
    ppa_price_usd_mwh, ... % 9
    water_price_usd_ton, ... % 10
    energy_cost_per_kwh, ... % 11
    smr_misc_opex_fraction, ... % 12
    electrolyzer_misc_opex_fraction, ... % 13
    electrolyzer_factor, ... % 14
    electrolyzer_efficiency, ... % 15
    electrolyzer_voltage, ... % 16
    electrolyzer_capex_per_kw, ... % 17
    electrolyzer_lifetime_years, ... % 18
    smr_ref_production, ... % 19
    smr_ref_capex, ... % 20
    smr_scaling_factor, ... % 21
    smr_lifetime_years % 22
];

for parameter = 1:length(parameters)
    
    % Loop over sensitivity cases
      for scenario_index = 1:length(sensitivity_range)
        % tweek on the parameters based on the sensitivity range  
        parameters(parameter) = parameters(parameter)*(sensitivity_range(scenario_index));

        Cost_blended_feed = calculateCostBlendedFeed(annual_production, parameters(6), parameters(5), 50);
        Cost_fossil_feed = calculateCostBlendedFeed(annual_production, parameters(6), parameters(5), 0);
        Cost_bio_feed = calculateCostBlendedFeed(annual_production, parameters(6), parameters(5), 100);
        [water_cost_0, process1_water_0, process2_water_0, electrolyzer_water_0, byproduct_water_0] = calculateWaterCostMethanolProduction(annual_production, 0, parameters(10));
        
        % 50 % green hydrogen (electrolyzer) + CO2 direct feedstock, 50 % bio methane feedstock
        [Energy_cost_50, CO2_consumption_50, CO2_cost_50] = calculateGreenHydrogenMethanolSynthesis(parameters(14), annual_production, parameters(15), parameters(11), parameters(7), parameters(16));
        Cost_bio_feed_with_green_hydrogen = calculateCostBlendedFeed((1-parameters(14))*annual_production, parameters(6), parameters(5), 100);
        [water_cost_50, process1_water_50, process2_water_50, electrolyzer_water_50, byproduct_water_50] = calculateWaterCostMethanolProduction(annual_production, parameters(14), parameters(10));
        
        % 100 % green hydrogen (electrolyzer) + CO2 direct feedstock
        [Energy_cost_100, CO2_consumption_100, CO2_cost_100] = calculateGreenHydrogenMethanolSynthesis(1, annual_production, parameters(15), parameters(11), parameters(7), parameters(16));
        [water_cost_100, process1_water_100, process2_water_100, electrolyzer_water_100, byproduct_water_100] = calculateWaterCostMethanolProduction(annual_production, 1, parameters(10));
        
        % calculation of CAPEX'es
        SMR_100_CAPEX_10_year = CAPEX_SMR(annual_production, parameters(19), parameters(20), parameters(21));
        SMR_50_CAPEX_10_year = CAPEX_SMR(annual_production/2, parameters(19), parameters(20), parameters(21));
        % Hydrogen_50_Capex_20_year
        Green_hydrogen_50_CAPEX_20_year = CAPEX_Hydrogen_AE485(annual_production/2, parameters(11));
        Green_hydrogen_100_CAPEX_20_year = CAPEX_Hydrogen_AE485(annual_production, parameters(11));
        % Initialize Capex and Opex matrices 
        capex = [zeros(1, years); ... % Capex for the blended feed (50 % bio, 50 % fossil)
            zeros(1, years); ... % Capex for the fossil feed
            zeros(1, years); ... % Capex for the bio feed
            zeros(1, years); ... % Capex for the 50 % green hydrogen with CO2 feed
            zeros(1, years)];   % Capex for the 100 % green hydrogen with CO2 feed
        
        % Capex for spesific years
        capex(1,1) = SMR_100_CAPEX_10_year; % Capex in year 1 for blended feed [USD]
        capex(1,10) = SMR_100_CAPEX_10_year; % Capex in year 1 for blended feed [USD]
        capex(2,1) = SMR_100_CAPEX_10_year; % Capex in year 1 for fossil feed [USD]
        capex(2,10) = SMR_100_CAPEX_10_year; % Capex in year 1 for fossil feed [USD]
        capex(3,1) = SMR_100_CAPEX_10_year; % Capex in year 1 for bio feed [USD]
        capex(3,10) = SMR_100_CAPEX_10_year; % Capex in year 1 for bio feed [USD]
        capex(4,1) = SMR_50_CAPEX_10_year + Green_hydrogen_50_CAPEX_20_year; % Capex in year 1 for bio feed [USD]
        capex(4,10) = SMR_50_CAPEX_10_year; % Capex in year 1 for bio feed [USD]
        capex(5,1) = SMR_50_CAPEX_10_year + Green_hydrogen_100_CAPEX_20_year; % Capex in year 1 for bio feed [USD]
        
        opex = [(Cost_blended_feed + water_cost_0 +(parameters(12)*(Cost_blended_feed + water_cost_0)/(1-parameters(12)))) * ones(1, years); ... % Opex for the blended feed); ...
            (Cost_fossil_feed + water_cost_0 + (parameters(12)*(Cost_fossil_feed + water_cost_0)/(1-parameters(12)))) * ones(1, years); ...
            (Cost_bio_feed + water_cost_0 + (parameters(12)*(Cost_bio_feed + water_cost_0)/(1-parameters(12)))) * ones(1, years); ...
            (Energy_cost_50 + CO2_cost_50 + Cost_bio_feed_with_green_hydrogen + water_cost_50 + (parameters(13)*Green_hydrogen_50_CAPEX_20_year) + (parameters(12)*(Cost_bio_feed_with_green_hydrogen + water_cost_0)/(1-parameters(12)))) * ones(1, years); ...
            (Energy_cost_100 + CO2_cost_100 + water_cost_100 + (parameters(13)*Green_hydrogen_100_CAPEX_20_year)) * ones(1, years)];    % Example base Opex per contributor
        
        % Initialize matrices for discounted Capex and Opex (contributors x years)
        discounted_capex = zeros(contributors, years);
        discounted_opex = zeros(contributors, years);
        discounted_production = zeros(1, years);
        
        % Loop over each year to calculate discounted values for Capex, Opex, and production
        for t = 1:years
        discount_factor = 1 / (1 + parameters(1))^t;  % Discount factor for year t
        
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
        for c = 1:contributors
        LCOM(c) = (npv_capex_contributor(c)+npv_opex_contributor(c))/total_npv_production;
        end
        
        %% Save the values in CSV-file
        %% Prepare column names and data values
        % Define column names for all parameters in a descriptive manner
        columnNames = {'Parameter','Years', 'Contributors', 'AnnualDiscountRate', 'EURtoUSD', 'NOKtoUSD', ...
               'AnnualMethanolProduction', 'BioMethanePrice', 'FossilMethanePrice', ...
               'CO2Price', 'PPA_Price_EUR_MWh', 'PPA_Price_USD_MWh', 'WaterPriceUSD_Ton', ...
               'EnergyCostPerkWh', 'SMR_MiscOpexFraction', 'ElectrolyzerMiscOpexFraction', ...
               'ElectrolyzerFactor', 'ElectrolyzerEfficiency', 'ElectrolyzerVoltage', ...
               'ElectrolyzerCapexPerKW', 'ElectrolyzerLifetimeYears', 'SMR_RefProduction', ...
               'SMR_RefCapex', 'SMR_ScalingFactor', 'SMR_LifetimeYears', 'LCOM', 'NPV_Opex', 'NPV_Capex'};

        dataValues = { ...
            parameter, ...
            years, ...                             % Years
            contributors, ...                      % Contributors
            parameters(1), ...                     % AnnualDiscountRate
            parameters(2), ...                     % EURtoUSD
            parameters(3), ...                     % NOKtoUSD
            parameters(4), ...                     % AnnualMethanolProduction
            parameters(5), ...                     % BioMethanePrice
            parameters(6), ...                     % FossilMethanePrice
            parameters(7), ...                     % CO2Price
            parameters(8), ...                     % PPA_Price_EUR_MWh
            parameters(9), ...                     % PPA_Price_USD_MWh
            parameters(10), ...                    % WaterPriceUSD_Ton
            parameters(11), ...                    % EnergyCostPerkWh
            parameters(12), ...                    % SMR_MiscOpexFraction
            parameters(13), ...                    % ElectrolyzerMiscOpexFraction
            parameters(14), ...                    % ElectrolyzerFactor
            parameters(15), ...                    % ElectrolyzerEfficiency
            parameters(16), ...                    % ElectrolyzerVoltage
            parameters(17), ...                    % ElectrolyzerCapexPerKW
            parameters(18), ...                    % ElectrolyzerLifetimeYears
            parameters(19), ...                    % SMR_RefProduction
            parameters(20), ...                    % SMR_RefCapex
            parameters(21), ...                    % SMR_ScalingFactor
            parameters(22), ...                    % SMR_LifetimeYears
            LCOM, ...                               % LCOM
            npv_opex_contributor, ...
            npv_capex_contributor ...
            };
        % reset base case after each iteration of sensitivty cases
        annual_discount_rate = 0.05;
        eur_to_usd = 1 / 0.92; 
        nok_to_usd = 1 / 10.97;
        annual_methanol_production = 2000;
        bio_methane_price = 96.82;
        fossil_methane_price = 60.58;
        co2_price = 50;
        ppa_price_eur_mwh = 75;
        ppa_price_usd_mwh = ppa_price_eur_mwh * eur_to_usd;
        water_price_usd_ton = 18.94 * nok_to_usd;
        energy_cost_per_kwh = ppa_price_usd_mwh / 1000;
        smr_misc_opex_fraction = 0.30;
        electrolyzer_misc_opex_fraction = 0.03;
        electrolyzer_factor = 0.5;
        electrolyzer_efficiency = 0.7;
        electrolyzer_voltage = 1.9;
        electrolyzer_capex_per_kw = 1112;
        electrolyzer_lifetime_years = 20;
        smr_ref_production = 36500;
        smr_ref_capex = 32256428;
        smr_scaling_factor = 0.7;
        smr_lifetime_years = 10;
    
        parameters = [
            annual_discount_rate, ... % 1
            eur_to_usd, ... % 2
            nok_to_usd, ... % 3
            annual_methanol_production, ... % 4
            bio_methane_price, ... % 5
            fossil_methane_price, ... % 6
            co2_price, ... % 7
            ppa_price_eur_mwh, ... % 8
            ppa_price_usd_mwh, ... % 9
            water_price_usd_ton, ... % 10
            energy_cost_per_kwh, ... % 11
            smr_misc_opex_fraction, ... % 12
            electrolyzer_misc_opex_fraction, ... % 13
            electrolyzer_factor, ... % 14 (xi)
            electrolyzer_efficiency, ... % 15 (eta)
            electrolyzer_voltage, ... % 16
            electrolyzer_capex_per_kw, ... % 17
            electrolyzer_lifetime_years, ...    % 18
            smr_ref_production, ... % 19
            smr_ref_capex, ...  % 20
            smr_scaling_factor, ... % 21
            smr_lifetime_years  % 22
            ];
              
            %% Save the values in CSV file, for data analytics.
            saveDataToCSV(columnNames, dataValues, file_name_write);
      end
end    


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% Troubleshooting Function %%%%%%%%%%%%%%%%%%%%%%%%%%%%

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