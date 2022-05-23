function [new_contents] = replace_DATABASE(contents, database_loc)
% Replaces the current value of the specified element by the given value in
% the SOLUTION input block for the given PHREEQC contents

% Create regular expression pattern
% DATABASE 
% followed by any number of spaces
% followed by any number of any characters
% followed by a new line
pattern = 'DATABASE\s+\S*[dat|DAT]';

% Find where DATABASE block begins 
idx_DATABASE = regexp(contents, pattern, 'once');

% Check whether specified block exists, if not return
if isempty(idx_DATABASE)
    warndlg('replace_DATABASE error: pattern not found in string')
    new_contents = contents;
    return

else
    new_contents = regexprep(contents, pattern, ['DATABASE ' database_loc]);
end

end
