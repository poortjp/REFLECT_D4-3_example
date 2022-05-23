function [new_contents] = replace_GAS_PHASE_PARAMETER(contents, blocknumber, parameter, value)
% Replaces the current value of the specified element by the given value in
% the SOLUTION input block for the given PHREEQC contents

% Create regular expression pattern
% dash followed by parameter followed by one or more white spaces followed by one or more
% numerical symbols followed by one or no period, followed again by one or
% more numerical symbols followed by optional expression for a scientific
% exponent

pattern = ['-' parameter '\s+' '-?\d*\.?\d+(?:(e|E)[+-]?\d+)?'];

% Define replacement string
new_string = ['-' parameter '\t' num2str(value)];

% Find where pattern occurs in contents
idxs = regexp(contents, pattern);

% Find where GAS_PHASE block begins
idx_GAS_PHASE = regexp(contents, ['GAS_PHASE\s' num2str(blocknumber)]);

% Check whether specified block exists, if not return
if isempty(idx_GAS_PHASE)
    warndlg('replace_GAS_PHASE error: pattern not found in string')
    new_contents = contents;
    return
end

% Check whether pattern occurs multiple times
check = false;
if length(idxs) > 1
    % Loop through idxs
    for ii=idxs
        if ii ~= idxs(end)
            if ii > idx_GAS_PHASE && ii < idxs(ii+1)
                new_contents = regexprep(contents, pattern, new_string);
                check = true;
            end
        else
            if ~check
                new_contents = regexprep(contents, pattern, new_string);
            end
        end
    end
else
    % If pattern occurs after SOLUTION block, replace pattern
    if idxs > idx_GAS_PHASE
        new_contents = regexprep(contents, pattern, new_string);
    end
end


end

