% Define the filename
filename = 'test_data13.csv';

% Check if the file exists
if ~isfile(filename)
    error(['File ', filename, ' does not exist. Please ensure data has been saved using saveDataToCSV.']);
end

% Read the data
data = readtable(filename);

% Define parameter columns (excluding 'Parameter', 'Years', 'Contributors', etc.)
parameter_columns = {'AnnualDiscountRate', 'EURtoUSD', 'NOKtoUSD', ...
                     'AnnualMethanolProduction', 'BioMethanePrice', 'FossilMethanePrice', ...
                     'CO2Price', 'PPA_Price_EUR_MWh', 'PPA_Price_USD_MWh', 'WaterPriceUSD_Ton', ...
                     'EnergyCostPerkWh', 'SMR_MiscOpexFraction', 'ElectrolyzerMiscOpexFraction', ...
                     'ElectrolyzerFactor', 'ElectrolyzerEfficiency', 'ElectrolyzerVoltage', ...
                     'ElectrolyzerCapexPerKW', 'ElectrolyzerLifetimeYears', 'SMR_RefProduction', ...
                     'SMR_RefCapex', 'SMR_ScalingFactor', 'SMR_LifetimeYears'};

% Define units for each parameter column
parameter_units = containers.Map( ...
    {'AnnualDiscountRate', 'EURtoUSD', 'NOKtoUSD', 'AnnualMethanolProduction', 'BioMethanePrice', ...
     'FossilMethanePrice', 'CO2Price', 'PPA_Price_EUR_MWh', 'PPA_Price_USD_MWh', 'WaterPriceUSD_Ton', ...
     'EnergyCostPerkWh', 'SMR_MiscOpexFraction', 'ElectrolyzerMiscOpexFraction', 'ElectrolyzerFactor', ...
     'ElectrolyzerEfficiency', 'ElectrolyzerVoltage', 'ElectrolyzerCapexPerKW', 'ElectrolyzerLifetimeYears', ...
     'SMR_RefProduction', 'SMR_RefCapex', 'SMR_ScalingFactor', 'SMR_LifetimeYears'}, ...
    {'%', 'EUR/USD', 'NOK/USD', 'Tonnes', 'USD/m³', 'USD/m³', 'USD/ton', 'EUR/MWh', 'USD/MWh', 'USD/ton', ...
     'USD/kWh', '%', '%', 'Factor', '%', 'V', 'USD/kW', 'Years', 'Tonnes', 'USD', 'Factor', 'Years'} ...
);

% Define LCOM columns
lcom_columns = {'LCOM_1', 'LCOM_2', 'LCOM_3', 'LCOM_4', 'LCOM_5'};

% Check if the 'Parameter' and LCOM columns exist in the data
if ~ismember('Parameter', data.Properties.VariableNames)
    error('The "Parameter" column is missing in the data file.');
end
missing_lcom_columns = setdiff(lcom_columns, data.Properties.VariableNames);
if ~isempty(missing_lcom_columns)
    error(['The following LCOM columns are missing in the data file: ', strjoin(missing_lcom_columns, ', ')]);
end

% Create folder for saving figures
output_folder = 'FIGURES/LCOM_Plots';
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

% Open the text file for writing results
fileID = fopen('LCOM_Analysis_Results.txt', 'w');
fprintf(fileID, 'LCOM Analysis Results\n');
fprintf(fileID, 'Data source file: %s\n\n', filename);

% Loop over each parameter column
for i = 1:numel(parameter_columns)
    param_column = parameter_columns{i};
    
    % Check if the parameter column exists in the data
    if ~ismember(param_column, data.Properties.VariableNames)
        warning(['Parameter column ', param_column, ' does not exist in the data file. Skipping.']);
        continue;
    end
    
    % Filter data where the 'Parameter' column equals the current index `i`
    filtered_data = data(data.Parameter == i, :);
    
    % Skip plotting if there are no rows matching the condition
    if isempty(filtered_data)
        warning(['No data available for Parameter = ', num2str(i), '. Skipping.']);
        continue;
    end
    
    % Write the parameter name to the text file
    fprintf(fileID, 'Parameter: %s\n', param_column);

    % Create a new figure for each parameter column with larger dimensions
    figure('Units', 'pixels', 'Position', [100, 100, 1200, 800]); % Larger figure size in pixels
    hold on;
    
    % Loop over each LCOM column and plot it against the current parameter column
    for j = 1:numel(lcom_columns)
        lcom_column = lcom_columns{j};
        
        % Extract current LCOM and parameter data for plotting
        x_data = filtered_data.(param_column);
        y_data = filtered_data.(lcom_column);
        
        % Plot the data with larger line width and marker size
        plot(x_data, y_data, '-o', 'DisplayName', lcom_column, 'LineWidth', 1.5, 'MarkerSize', 6);
        
        % Find and write the max and min values of the current LCOM plot to the text file
        max_value = max(y_data);
        min_value = min(y_data);
        
        fprintf(fileID, '  %s:\n', lcom_column);
        fprintf(fileID, '    Max %s: %.2f\n', lcom_column, max_value);
        fprintf(fileID, '    Min %s: %.2f\n', lcom_column, min_value);
    end
    
    % Replace underscores with whitespace for the parameter column label
    param_column_label = strrep(param_column, '_', ' ');

    % Retrieve unit for the current parameter from the map
    if isKey(parameter_units, param_column)
        x_unit = [' (', parameter_units(param_column), ')'];
    else
        x_unit = ''; % Default to empty if unit is not defined
    end

    % Configure plot labels, title, and legend with larger font size
    xlabel([param_column_label, x_unit], 'FontSize', 14);
    ylabel('LCOM_{USD}', 'FontSize', 14);
    title(['Sensitivity analysis for parameter: ', param_column_label], 'FontSize', 16);
    legend('show', 'FontSize', 12);
    set(gca, 'FontSize', 12); % Set font size for tick labels
    grid on;
    hold off;
    
    % Save figure to the designated folder with higher resolution
    print(gcf, fullfile(output_folder, ['LCOM_', param_column, '.png']), '-dpng', '-r300'); % Saves at 300 DPI for higher quality
    close(gcf); % Close the figure to save memory
    
    % Add a newline to separate results for each parameter in the text file
    fprintf(fileID, '\n');
end

% Close the file
fclose(fileID);

disp('Data analytics completed with filtered parameter plots against LCOM values. Analysis results saved to LCOM_Analysis_Results.txt.');
disp(['Figures saved to the folder: ', output_folder]);