clear;clc;close all
%-------------input parameters for voronoi tesselation--------------%
minimum_number_of_cells_per_cluster = 5; %voronoi-cells will be identified as clusters if at leat M-many cells are connected
clear;clc;close all
[file_name,path] = uigetfile('*.bin','Select .txt File(s)','MultiSelect','on');
data_in = Insight3(fullfile(path,file_name));
data_in = data_in.getXYcorr;
figure()
set(gcf,'name','Original File','NumberTitle','off','color','w','units','normalized','position',[0.3 0.2 0.4 0.6],'WindowButtonDownFcn',@mouse_down,'WindowButtonUpFcn',@mouse_up,'Menubar','none')
scatter(data_in(:,1),data_in(:,2),1,'b','filled')
%-------------------------------------------------------------------

vor = construct_voronoi_structure(data_in(:,1),data_in(:,2)); % construct the voronoi object
plot_voronoi_area(vor,1000); % plots the histogram of the voronoi-cells areas, 100 is number of bins

area_threshold = input('What is the Area Threshold:');
area_threshold = 10^(area_threshold); % threshold value on the voronoi-cells areas (percentile)

idx = find(vor.voronoi_areas<area_threshold);
points_wanted = vor.points(idx,:);
figure()
set(gcf,'name','Updated File','NumberTitle','off','color','w','units','normalized','position',[0.3 0.2 0.4 0.6],'WindowButtonDownFcn',@mouse_down,'WindowButtonUpFcn',@mouse_up,'Menubar','none')
scatter(points_wanted(:,1),points_wanted(:,2),1,'b','filled')

clear data
data(:,1) = points_wanted(:,1);
data(:,2) = points_wanted(:,2);
data(:,3) = points_wanted(:,1);
data(:,4) = points_wanted(:,2);
data(:,5) = 100;
data(:,6) = 10000;
data(:,7) = 300;
data(:,8) = 0;
data(:,9) = 1;
data(:,10) = 0;
data(:,11) = 10000;
data(:,12) = 0;
data(:,13) = 1;
data(:,14) = 1;
data(:,15) = 1;
data(:,16) = -1;
data(:,17) = 0;
data(:,18) = 0; 
i3 = Insight3();
i3.setData(data);
i3.write(fullfile(path,[extractBefore(file_name,'.bin'),'_modified' '.bin']));