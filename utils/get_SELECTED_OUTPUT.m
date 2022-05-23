function [val] = get_SELECTED_OUTPUT(output_file, param_name)
%getPHR2PHR_output retrieves the desired output value for a given PHREEQC
%SELECTED_OUTPUT file

% Read file and get cells with row data
% fileID = fopen(output_file, 'r');
% textheader = strsplit(fgetl(fileID));
% textvals = strsplit(fgetl(fileID));
% fclose(fileID);

% Read file and get cells with row data
fileID = fopen(output_file, 'r');

count = 0;
while true
    line = fgetl(fileID);
    if ~ischar( line ); break; end
    linecontents = strsplit(line);
    count = count + 1;
    textcell(count, :) = linecontents;
end
fclose(fileID);

textheader = textcell(1, :);
textvals = textcell(end, :);

% Find index of desired parameter and retrieve corresponding value
validx = find(strcmp(textheader, param_name));

% Try to convert value to double
try
    val = str2double(textvals{validx});
% If not possible, value is likely not numerical, return string instead
catch
    val = textvals{validx};
end

end

