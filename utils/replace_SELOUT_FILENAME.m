function [new_contents] = replace_SELOUT_FILENAME(contents, newstring)
% Finds and replaces the filename of a SELECTED_OUTPUT block with
% the new string

pattern = ['SELECTED_OUTPUT\s+' '\s*-file\s+.+\.txt'];

new_string = ['SELECTED_OUTPUT\n' '\t-file ' newstring];

% Check whether pattern exists in contents
idxs = regexp(contents, pattern);
if isempty(idxs)
    warndlg('replace_SELOUT_FILENAME error: pattern not found in string')
    new_contents = contents;
    return
end

new_contents = regexprep(contents, pattern, new_string);

end

