function loc_list_clusters_data_table(data)
counter = 0;
for i = 1:length(data)
    data_to = unique(data{i}.area);
    if length(data_to)>1
        counter = counter+1;
        data_to_send{counter} = data{i};
    end
end
if exist('data_to_send','var')
    f = waitbar(0,'Extracting Data Table Information...');
    for i = 1:length(data_to_send)
        data_table{i} = clusters_extract_statistics(data_to_send{i});
        waitbar(i/length(data_to_send),f,['Extracting Data Table Information...',num2str(i),'/',num2str(length(data_to_send))]);
    end
    close(f)
    plot_data_table(data_table)
else
    msgbox('there is only one cluster')
end
end

function data_table = clusters_extract_statistics(data)
% [no_of_locs, cluster_area] = hist(data.area,unique(data.area));
% data_table.data(:,1) = no_of_locs';
% data_table.data(:,2) = cluster_area;
data_table.name = data.name;
clusters = loc_list_extract_clusters_from_data(data);
for i = 1:length(clusters)
    [~,cluster] = pca(clusters{i}(:,1:2));
    major_axis_length = max(cluster(:,1))-min(cluster(:,1));
    minor_axis_length = max(cluster(:,2))-min(cluster(:,2));
    max_val = max(major_axis_length,minor_axis_length);
    min_val = min(major_axis_length,minor_axis_length);
    data_table.data(i,1) = size(clusters{i},1);
    data_table.data(i,2) = clusters{i}(1,3);    
    data_table.data(i,5) = max_val;
    data_table.data(i,6) = min_val;
    data_table.data(i,7) = max_val/min_val;
end
temp = data_table.data(:,1)./data_table.data(:,2);
temp(temp==Inf) = 0;
data_table.data(:,3) = temp;
data_table.data(:,4) = data_table.data(:,3)./mean(data_table.data(:,3));
data_table.data = sortrows(data_table.data,1);
end

function plot_data_table(data)
figure()
set(gcf,'name','clusters_statistics_table','NumberTitle','off','color','w','units','normalized','position',[0.15 0.2 0.7 0.6],'menubar','none','toolbar','figure')

if length(data)>1
    slider_step=[1/(length(data)-1),1];
    uicontrol('style','slider','units','normalized','position',[0,0,0.05,0.9],'value',1,'min',1,'max',length(data),'sliderstep',slider_step,'Callback',{@sld_callback});
end
slider_value=1;
slider_plot_inside(data{slider_value})

uimenu('Text','Send Data to Excel Sheet','ForegroundColor','b','CallBack',@save_data);

    function save_data(~,~,~)
        [file,path] = uiputfile('*.xlsx');
        if path~=0            
            save_to = fullfile(path,file);
            for i = 1:length(data)                  
                data_table = array2table(data{i}.data);
                data_table.Properties.VariableNames = {'Locs','Area','Locs/Area (Density)','Normalized Density','Major Axis','Minor Axis','Aspect Ratio'};
                writetable(data_table,save_to,'sheet',regexprep([data{i}.name(1:30),num2str(i)],'_',' '))                
            end
        end
    end

    function sld_callback(hobj,~,~)
        slider_value = round(get(hobj,'Value'));        
        slider_plot_inside(data{slider_value})
    end

    function slider_plot_inside(data)
        axis off
        title(regexprep(data.name,'_',' '),'interpreter','latex','fontsize',18)
        uitable('Data',data.data,'units','normalized','position',[0.05 0 0.95 0.9],'ColumnWidth',{150},'FontSize',12,'ColumnName',{'Locs','Area','Locs/Area (Density)','Normalized Density','Major Axis','Minor Axis','Aspect Ratio'});
    end
end