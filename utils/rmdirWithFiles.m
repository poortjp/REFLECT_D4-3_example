function [] = rmdirWithFiles(folder)
%rmdirWithFiles Removes a folder along with the files in the folder
%   Regular rmdir function only works if the folder is empty, in this
%   function we first remove all files in the specified folder, and then
%   the folder itself


% Get all files in the folder
allFiles = dir(folder);

% Go through files and remove them
for ii = 1:length(allFiles)
    % Get base file name from file list
    baseFileName = allFiles(ii).name;
    
    % The file directory object also contains references to the folder's
    % root and parent ('.' and '..'), so we skip those
    if strcmp(baseFileName, '.') || strcmp(baseFileName, '..')
        continue
    end
    
    % Construct full file name
    fullFileName = fullfile(folder, baseFileName);
    
    % Delete file
    delete(fullFileName);
end

% Delete folder itself
rmdir(folder);

end

