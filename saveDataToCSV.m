function saveDataToCSV(columnNames, dataValues, filename)
    % This function writes a single row of data to a CSV file.
    % If the file already exists, it appends the new row without duplicating headers.
    % If the file does not exist, it creates the file with headers.
    %
    % Inputs:
    % - columnNames: A cell array of column names, e.g., {'Year', 'Production', 'OPEX'}
    % - dataValues: A 1xN array or cell array where each element corresponds to a column name
    % - filename: Name of the CSV file to write to (e.g., 'plant_financial_data.csv')
    
    % Ensure dataValues is a single row and matches the length of columnNames
    if numel(dataValues) ~= numel(columnNames)
        error('Length of dataValues must match the number of elements in columnNames');
    end

    % Convert dataValues to a table with the specified column names
    data_table = array2table(dataValues, 'VariableNames', columnNames);
    
    % Check if the file already exists
    if isfile(filename)
        % Append the new row without writing headers again
        writetable(data_table, filename, 'WriteMode', 'Append', 'WriteVariableNames', false);
    else
        % If the file doesn't exist, write the table with headers
        writetable(data_table, filename);
    end

    disp(['Data written to ', filename]);
end
