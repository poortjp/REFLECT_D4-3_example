function [new_contents] = replace_REACTION_PRESSURE(contents, number, value)
% Finds and replaces the REACTION_PRESSURE of the specified input
% block in the given PHREEQC file contents by the given value

% Define the pattern to look for:
% - String starting with the literal (case sensitive) word:
% 'REACTION_PRESSURE'
% - Followed by one or more white spaces ('\s+')
% - Followed by the number of the reaction block for which we need to
% replace the pressure values ('num2str(number)')
% - Followed by one or more of the following pattern '(\s*\d+(\.)?\d*)+':
%   - Zero or more white spaces ('\s*')
%   - Followed by one or more numeric digits ('\d+')
%   - Followed by either one or no period ('(\.)?')
%   - Followed by zero or more numeric digits ('\d*')
pattern = ['REACTION_PRESSURE\s+' num2str(number) '(\s*\d+(\.)?\d*)+'];

% Define the string to replace the pattern with
% First check whether the value is a scalar, or array
if isscalar(value)
    % Simply cast the scalar to a string
    repval_string = num2str(value);
else
    % First cast the array elements to string
    value_string = string(value);
    % Then join the array into a single string separated by spaces
    repval_string = strjoin(value_string, ' ');  
end

blocknum = num2str(number);
new_string = "REACTION_PRESSURE " + blocknum + "\n" + repval_string;

% Check whether pattern exists in contents
idxs = regexp(contents, pattern);
if isempty(idxs)
    warndlg('replace_REACTION_PRESSURE error: pattern not found in string')
    new_contents = contents;
    return
end

new_contents = regexprep(contents, pattern, new_string);

end

