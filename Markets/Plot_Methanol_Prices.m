% Step 1: Load the data
data = readtable('Methanol_prices.csv', 'VariableNamingRule', 'preserve');

% Step 2: Extract date values and price data
dates = datetime(data{:,1}, 'InputFormat', 'MMM-yy'); % Convert first column to datetime
price_data = data{:, 2:end}; % All other columns are price data

% Define column names for the plot legend
column_names = {'US MMSA Contract Index', 'US MMSA Spot Barge Wtd Avg', ...
                'Europe MMSA Contract', 'Europe MMSA Spot Avg', ...
                'NEA/SEA MMSA Contract Net Transaction Reference', ...
                'China MMSA Spot Avg'};

% Step 3: Calculate the correlation matrix between different markets
correlation_matrix = corr(price_data, 'Rows', 'pairwise');

% Display the correlation matrix
disp('Correlation Matrix between Markets:');
disp(correlation_matrix);

% Plot correlation matrix as a heatmap with larger size and finer resolution
figure('Units', 'normalized', 'Position', [0.1, 0.1, 0.7, 0.7]); % 70% of the screen
heatmap(correlation_matrix, 'XData', column_names, 'YData', column_names, ...
        'ColorbarVisible', 'on', 'Colormap', jet);
title('Correlation Matrix of Methanol Prices across Markets');

% Save heatmap as high-resolution image (e.g., 300 dpi)
saveas(gcf, 'Correlation_Matrix.png');
print(gcf, 'Correlation_Matrix_HighRes.png', '-dpng', '-r300'); % Save as 300 dpi

% Step 4: Plot the original prices with larger size and finer resolution
figure('Units', 'normalized', 'Position', [0.1, 0.1, 0.7, 0.7]); % 70% of the screen
plot(dates, price_data, 'LineWidth', 1.5);
title('Methanol Prices Over Time');
xlabel('Date');
ylabel('Price (USD/metric ton)');
legend(column_names, 'Location','northwest');
grid on;

% Save price plot as high-resolution image (e.g., 300 dpi)
saveas(gcf, 'Methanol_Prices.png');
print(gcf, 'Methanol_Prices_HighRes.png', '-dpng', '-r300'); % Save as 300 dpi