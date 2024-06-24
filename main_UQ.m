%% Main 
% File for automating uncertainty quantification of PHREEQC models
% Publically available version

clc
clear all
close all

addpath('./utils/') % location where functions are stored



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                          START USER INPUT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Set-up (user-defined)

% Name of project. Name of file in which UQ results are collected and saved 
% is based on this
projectname = 'UQ_test';

% Specify whether to save the results in a csv or excel file
% NOTE: saving to excel is much slower and can run into writing permission
% errors, it is therefore only recommended for low number of samples.
% Otherwise it is better to save as csv and convert to excel later
save_format = 'csv'; % either 'csv' or 'xlsx'

% Specify the file name of the PHREEQC model file (without extension)
PHREEQC_filename = 'PHREEQC_REFLECT_example';

%% UQ inputs (user-defined)

% Define the elements included in the UQ
% Each element name should correspond to it counterpart as used in PHREEQC
elements = {'Ba', 'C(4)', 'Ca', 'Cl', 'K', 'Mg', 'Na', 'S(6)'};

% Set the nominal value of each element around which the variations are
% made. Should be given in the same order as the elements list
nominal_vals = [5.5 0.001 7450 145000 2200 1150 85000 585];

% Set the maximum percentage of variation. This assumes that the positive
% and negative variations are the same, e.g. if giving a value of 30, the
% variations are made between -30% and +30%.
% Again, should be given in the same order as the element list
var_percentages = [30 30 30 30 5 40 20 40];

% Total number of samples (will be ignored when sample strategy is a
% permutation)
num_samples = 10;


%% Pressure and temperature (user-defined)

% Define topside pressure (bar)
p = 10;

% Define topside temperature (C)
T = 70;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           END USER INPUT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Create samples
% Create an array containing the brine composition samples
% The resulting array will have a size of NxM, where N is the number of
% samples and M is the number of elements (thus each row in the array is a
% single brine composition). Samples are drawn from a uniform distribution
% between upper and lower bounds which are determined by adding and 
% subtracting the specified maximum percentage deviations from the
% specified nominal value of each element. This example does not include
% any other distribution besides uniform.
% The order of columns is the same as the order of elements defined
samples = create_samples(nominal_vals, var_percentages, num_samples);

%% Initialize result array

% Define outputs to be saved
output_vars = {'si_Barite', 'd_Barite', 'Barite'};

% Determine number of columns in the array (= number of elements included
% in analysis + temperature + pressure + number of outputs recorded
num_columns = length(elements) + 2 + length(output_vars);

% Create array
results_array = zeros(num_samples, num_columns);

% Create header
results_header = [strcat(elements, '_in') {'temperature', 'pressure'}  strcat(output_vars, '_out')]; 

%% UQ analysis (automatic)

% DB location (database file should end in ".dat" or ".DAT")
% NOTE: changing to a different database can lead to different results or
% failure of certain calculations
DB_loc = './dbase/PITZER.DAT'; % Either FULL PATH to db anywhere on disk, or LOCAL PATH [preferred option] to db folder (with root at current directory)

% Specify the location of the PHREEQC .exe
phreeqc_exe_loc = '"./phreeqc/phreeqc" ';

% Add the nominal brine composition to the end of the samples list
samples = [samples;nominal_vals];

num_samples = num_samples + 1;

% Define file locations based on file name
PHREEQC_source_file = ['./inputs/source/' PHREEQC_filename '.phr']; % PHREEQC file containing all original definitions
PHREEQC_sample_file = ['./inputs/' PHREEQC_filename '_sample.phr']; % PHREEQC file containing the changed sample values
PHREEQC_output_file = ['./inputs/' PHREEQC_filename '_results.txt']; % PHREEQC file containing the calculation results from PHREEQC

% Create name of output result file
savename = [projectname '_T-' num2str(T) '_p-' num2str(p) '_N-' num2str(num_samples) '_' num2str(round(24*3600*now))];

% Read in contents of PHREEQC input file
PHREEQC_contents = fileread(PHREEQC_source_file);

% First change database file in PHREEQC input
PHREEQC_contents_new = replace_DATABASE(PHREEQC_contents, DB_loc);

% Start iteration over range of component values, in each iteration:
%   - Change the value of the components in the SOLUTION block of the input
%   file
%   - Run the PHREEQC file
%   - Read in the values of the saved selected output file
%   - Store the selected output data of each iteration in a new results file

timestamp = num2str(round(24*3600*now));
completed_it = 0;
num_saving_errors = 0;
start_time = clock;


for ii = 1:num_samples % Loop going through brine composition samples

    for jj = 1:length(elements)
        % Get element name
        element = elements{jj};

        % Get element value
        value = samples(ii, jj);

        % Change value of specified component in PHREEQC file
        PHREEQC_contents_new = replace_SOLUTION_COMPONENT(PHREEQC_contents_new, 1, element, value);
    end

    % Write variables to gas exsolution (block 2)
    PHREEQC_contents_new = replace_REACTION_TEMPERATURE(PHREEQC_contents_new, 2, T);
    PHREEQC_contents_new = replace_REACTION_PRESSURE(PHREEQC_contents_new, 2, p);
    PHREEQC_contents_new = replace_GAS_PHASE_PARAMETER(PHREEQC_contents_new, 2, 'pressure', p);
    PHREEQC_contents_new = replace_GAS_PHASE_PARAMETER(PHREEQC_contents_new, 2, 'temperature', T);

    % Write pressure to cooling calculations (block 3)
    PHREEQC_contents_new = replace_REACTION_TEMPERATURE(PHREEQC_contents_new, 3, T);

    % Write/change selected output file name
    PHREEQC_contents_new = replace_SELOUT_FILENAME(PHREEQC_contents_new, PHREEQC_output_file);


    % Save file
    fileID = fopen(PHREEQC_sample_file, 'w');
    fprintf(fileID, PHREEQC_contents_new);
    fclose(fileID);

    % Run file
    system([phreeqc_exe_loc PHREEQC_sample_file]);
    clc
    % Read selected output file (it reads the final empty space as an
    % additional variable with NaN, but so far it doesn't seem to interfere
    % with the rest of the script or saving, so letting it be for now
    results_table = readtable(PHREEQC_output_file, 'Delimiter', '\t');

    % Fill results array
    % Add current sample combination
    results_array(ii, 1:length(elements)) = samples(ii,:);

    % Add temperature
    results_array(ii, length(elements)+1) = T;

    % Add pressure
    results_array(ii, length(elements)+2) = p;

    % Add PHREEQC results
    results_array(ii, (length(elements)+3):end) = table2array(results_table(:, output_vars));

    % Convert table to cell and add header
    results_cell = num2cell(results_array);
    results_cell = [results_header;results_cell];
    

    % Display progress
    completed_it = (completed_it + 1);
    current_time = clock;
    time_elapsed = etime(current_time, start_time);
%         clc
    fprintf('Total iterations completed: %d/%d (time elapsed: %.2f s (%.2f s per it.)\n', ...
        completed_it*length(T), num_samples, time_elapsed, time_elapsed/(completed_it*length(T))); % Multiply by number of temp. variations since those are all done in a single PHREEQC calculation
    
    
        % Write calculation outputs to results file(s)
    if strcmp(save_format, 'xlsx')
        % Pause briefly to avoid writing permission errors
        pause(1);
        % Write to excel sheet
        xlswrite(['./outputs/' savename '.xlsx'], results_cell);

    elseif strcmp(save_format, 'csv')
        % Convert results cell to table
%         save_table = cell2table(results_cell(2:end,:),'VariableNames',results_cell(1,:));
        % Write to csv
%         writetable(save_table, ['./outputs/' savename '.csv']);
        writecell(results_cell, ['./outputs/' savename '.csv'], 'FileType', 'text');
    end
end

disp('PHREEQC calculations completed!')


