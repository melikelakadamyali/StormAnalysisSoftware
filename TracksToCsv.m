clc;clear all;close all

[file,path] = uigetfile('*.mat','Select the .mat file containing the tracks');
name = fullfile(path,file); % Make it a full name to save it as later.
load(name);

path = uigetdir('*.xlsx','Please specify the folder where you want to save the csv files');

for j = 1:size(data,2)
    clear Tracks TracksTable
    
    for i = 1:size(data{j}.tracks,1)
        
        Tracks{i} = [ones(size(data{j}.tracks{i},1),1)*i data{j}.tracks{i}];
        
    end
    Tracks = vertcat(Tracks{:});
    
    TracksTable = array2table(Tracks);
    TracksTable.Properties.VariableNames = {'Identifier','Time [s]','x coordinate [pixels]','y coordinate [pixels]'};
    
    filename = [path '\' data{j}.name '.csv'];
    writetable(TracksTable,filename);
    
end

clear all