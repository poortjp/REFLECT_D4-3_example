%% Plot results
% File for analysing and plotting the results of the UQ sample calculations

clc
clear all
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                          START USER INPUT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set-up

% Specify name of file with sample results (including file extension)
result_file = 'UQ_test_T-70_p-10_N-101_63820628514.csv';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           END USER INPUT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Load data

% Add folder location to file name
filenameloc = ['./outputs/' result_file];

% [loc, name, ext] = fileparts(filenameloc);
% 
% if strcmp(ext, '.xlsx')
%     data = readtable(filenameloc);
%     
%     % TO BE COMPLETED
%     
% elseif strcmp(ext, '.csv')
%     
% else
%     warndlg('Invalid file extension of data file, must be .csv or .xlsx')
%     return
% end

% Read data from file
data = readtable(filenameloc);

% Get barite scaling potential data
barite_scaling = data.d_Barite_out;

% Split sample variation results from nominal results
barite_varia = barite_scaling(1:length(barite_scaling)-1);
barite_nominal = barite_scaling(end);


%% Histogram plot

% Calculate statistics of sample results
mean = mean(barite_varia);
std = std(barite_varia);

% Create histogram plot
nbins = min([25, round(length(barite_varia)/10)]);
histogram(barite_varia, nbins);
hold on
set(gcf,'Position',[200 200 800 600])

% Add vertical line for mean, std, and nominal value
xline(barite_nominal, 'g-', 'linewidth', 2);
xline(mean, 'k--', 'linewidth', 2);
xline(mean+std, 'r-.', 'linewidth', 2);
xline(mean-std, 'r-.', 'linewidth', 2);

% Add title, labels, legend, etc.
xlabel('Barite scaling potential [mol/l]')
ylabel('Count')
title('Distribution of barite scaling potential under brine composition uncertainty')
legend({'Barite distribution', 'Nominal value', 'Mean value', '+-1 stdev'}, 'location', 'northwest')

% Save figure
[path, filename, ext] = fileparts(result_file);
saveas(gcf, ['./plots/' filename '_histogram.png']);
