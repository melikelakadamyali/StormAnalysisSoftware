clc;close all;clear

% Do not change from this point on
Continue = 1; % Ignore this

while(Continue)
    
    [file,path] = uigetfile('*.mat','Select the file you want to load'); % Open a dialog so you can specify how to save it. For safety, we don't show any mat files so there is no confusion during loading/saving
    selectedfile = fullfile(path,file); % Create the name for the file to load
    load(selectedfile); % Load the file
    
    figure(1);imagesc(data{1,4}.image{1,1});colormap(gray);pbaspect([size(data{1,4}.image{1,1},2)/size(data{1,4}.image{1,1},1) 1 1])
    title(file); % Show the file name as the title
    
    Change = menu('Is this the binary image?','No','Yes') - 1; % Decide whether or not it is the binary image
    
    % Only do something if it's not the binary image
    if ~Change
        
        % Switch the 3rd and 4th lines in the sessions
        data{1,end+1} = data{1,4};
        data{1,4} = data{1,3};
        data{1,3} = data{1,end};
        data(end) = [];
        
        file_b = [extractBefore(file,'.') 'b.mat']; % Change te name to the b-file
        [file,path] = uiputfile(file_b,'Please Specify a name to save this as'); % Open a dialog so you can specify how to save it. For safety, we don't show any mat files so there is no confusion during loading/saving
        save([path file],'data'); % Do the actual saving
        
    end
    
    Continue = menu('Want to check other data?','No','Yes') - 1; % Decide whether or not you want to continue with the analysis or not
    
end

clear % Clear up the workspace