% Load the session you want to analyze
clc;close all;clear
[file,path] = uigetfile('*.mat','Load the MATLAB file');

% Do the analysis
if isequal(file,0)
    disp('User selected Cancel'); % Stop the script.
else
    filename = fullfile(path,file);
    load(filename,'data');

    textdata = cell(numel(data),1);
    for i = 1:numel(data)
        textdata{i} = data{i}.name;
    end
    textdata = cell2table(textdata);
    writetable(textdata,[filename(1:end-4) '.txt']);
end