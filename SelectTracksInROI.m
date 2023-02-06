clc;close all;clear

% Change this if needed
PixelSize = 0.117; % 117 nm per pixel
PlotFigures = 1; % Decide whether or not you want to plot the images

% Do not change from this point on
Continue = 1; % Ignore this

% Do the analysis until you're tired of it
while(Continue)
    
    [file,path] = uigetfile('*.mat','Select the file you want to load'); % Open a dialog so you can specify how to save it. For safety, we don't show any mat files so there is no confusion during loading/saving
    selectedfile = fullfile(path,file); % Create the name for the file to load
    load(selectedfile); % Load the file
    
    Image = double(data{1,4}.image{1,1}); % Extract the confocal image and store it in a matrix (keep in mind that this can be the 'binary' image sometimes. If this happens most of the times, just change the '4' to a '3' in this line)
    Tracks = data{1,5}.tracks; % Extract the tracks

    % Convert the localization coordinates in um to pixels
    for i = 1:length(Tracks)
        Tracks{i}(:,2:3) = Tracks{i}(:,2:3) / PixelSize; % Do the conversion
    end
    clear i % Because we don't need this anymore

    figure(1);imagesc(Image);colormap(gray);pbaspect([size(Image,2)/size(Image,1) 1 1]); % Show the data in th ecorresct aspect ratios

    h = impoly; % Draw a nice ROI
    CoordinatesMask = getPosition(h); % Extract the coordinates of the polygon
    CoordinatesMask = [CoordinatesMask; CoordinatesMask(1,:)]; % Add the first coordinate to close the figure
    ROIMask = createMask(h); % Make a binary mask of the ROI
    AreaTubulinsInROI = nnz(ROIMask .* double(Image)) * PixelSize.^2; % Calculate the area in um2 that represents tubulines in the ROI
    AreaROI = polyarea(CoordinatesMask(:,1),CoordinatesMask(:,2)) * PixelSize.^2; % Calculate the area in um2 that represents the ROI
    clear h % Because we don't need the handle anymore
    close(1); % Close the figure

    % Test within ROI or not
    for i = 1:length(Tracks)
        % TestInROI(i) = inpolygon(Tracks{i}(1,2),Tracks{i}(1,3),CoordinatesMask(:,1),CoordinatesMask(:,2)); % Test if cordinates are insidethe polygon or not. This is based on the coordinates at the first time point
        TestInROI(i) = inpolygon(mean(Tracks{i}(:,2),1),mean(Tracks{i}(:,3),1),CoordinatesMask(:,1),CoordinatesMask(:,2)); % Test if cordinates are insidethe polygon or not. This is based on the average coordinate
    end
    TracksInside = Tracks(TestInROI,:);
    TracksOutside = Tracks(~TestInROI,:);
    clear i Tracks

    % This is done so that it can be used in the STORM progran
    data{1,6} = data{1,5}; % Copy the structure
    data{1,7} = data{1,5}; % Copy the structure
    data{1,6}.name = 'TracksInside';data{1,7}.name = 'TracksOutside'; % Rename what we're looking at
    data{1,6}.tracks = TracksInside;data{1,7}.tracks = TracksOutside; % Fill in the tracks

    % Plot only if we want to
    if PlotFigures
        
        figure(2);imagesc(Image);colormap(gray);pbaspect([size(Image,2)/size(Image,1) 1 1]);shg % Show the image in the correct proportions
        hold on; % Add other plots on top
        plot(CoordinatesMask(:,1),CoordinatesMask(:,2),'y','LineWidth',2);shg % Add the ROI selection
        
        % Plot all the tracks inside in green
        for i = 1:length(TracksInside)
            plot(TracksInside{i}(:,2),TracksInside{i}(:,3),'g','LineWidth',2);
        end
        % Plot all the tracks outside in red
        for i = 1:length(TracksOutside)
            plot(TracksOutside{i}(:,2),TracksOutside{i}(:,3),'r','LineWidth',2);
        end
        title(['Total ROI area: ' num2str(AreaROI) ' um^2; Area Tublins in ROI: ' num2str(AreaTubulinsInROI) ' um^2']); % Show the title containing the ROI area and Tubulins in ROI area (in um^2)
        shg; %Show the current figure handle
        
    end
    
    % Save the session
    [file,path] = uiputfile([extractBefore(file,'.') '.xls'],'Please Specify a name to save this as'); % Open a dialog so you can specify how to save it. For safety, we don't show any mat files so there is no confusion during loading/saving
    file = [extractBefore(file,'.') '.mat']; % Make sure it saves as .mat
    save([path file],'data'); % Do the actual saving
    
    Continue = menu('Aren''t you tired of analyzing? Do you REALLY want to continue?','No','Yes') - 1; % Decide whether or not you want to continue with the analysis or not
    
    clearvars -except Continue PixelSize PlotFigures % Clear up the workspace
    
end

clear % Clear up the workspace