function [new_contents] = replace_SOLUTION_COMPONENT(contents, blocknumber, element, value)
% Replaces the current value of the specified element by the given value in
% the SOLUTION input block for the given PHREEQC contents

% If the element contains parentheses, they will trip up the regular
% expression since these have a special meaning in a regex. Thus here we replace all
% opening and closing parentheses in the element name by their escaped version
element = strrep(element, '(', '\(');
element = strrep(element, ')', '\)');

% Create regular expression pattern
% element followed by one or more white spaces followed by one or more
% numerical symbols followed by one or no period, followed again by one or
% more numerical symbols followed by optional expression for a scientific
% exponent
% pattern = [element '\s+\d+(\.)?\d*'];
pattern = ['\n' element '\s+' '-?\d*\.?\d+(?:(e|E)[+-]?\d+)?'];
% pattern = [element '\s+' '-?\d*\.?\d+(?:(e|E)[+-]?\d+)?'];

% Define replacement string
new_string = ['\n' element '\t' num2str(value)];

% Find where pattern occurs in contents
idxs = regexp(contents, pattern);

% Find where SOLUTION block begins (exlude things such as USE/SAVE
% SOLUTION)
idx_SOLUTION = regexp(contents, ['[\W]\sSOLUTION\s' num2str(blocknumber)]);

% Check whether specified block exists, if not return
if isempty(idx_SOLUTION)
    warndlg('replace_SOLUTION error: pattern not found in string')
    new_contents = contents;
    return
end

% Check whether pattern occurs multiple times
check = false;
if length(idxs) > 1
    % Loop through idxs
    for ii=idxs
        % If pattern occurs after SOLUTION block, replace pattern, then
        % break, as we are only interested in replacing the first instance
        % after the block
        if ii > idx_SOLUTION
            % TODO: FIND A WAY TO ONLY REPLACE THE FIRST INSTANCE IN WHICH
            % THE PATTERN IS FOUND
            new_contents = regexprep(contents, pattern, new_string);
            break
        end
    end
else
    % If pattern occurs after SOLUTION block, replace pattern
    if idxs > idx_SOLUTION
        new_contents = regexprep(contents, pattern, new_string);
    end
end


end

