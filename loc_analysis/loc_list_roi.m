function loc_list_roi(data)
try
    coordinates = getline();
    data_roi = cell(1,length(data));
    for i = 1:length(data)
        data_roi{i} = loc_list_roi_inside(data{i},coordinates);
    end
    data_roi = data_roi(~cellfun('isempty',data_roi));
catch
    data_roi = [];    
end
loc_list_plot(data_roi)
end

function data_crop = loc_list_roi_inside(data,coordinates)
I = inpolygon(data.x_data,data.y_data,coordinates(:,1),coordinates(:,2));
if ~isempty(data.x_data(I))
    data_crop.x_data = data.x_data(I);
    data_crop.y_data = data.y_data(I);
    data_crop.area = data.area(I);
    data_crop.name = [data.name,'_roi'];
    data_crop.type = 'loc_list';
else
    data_crop = [];
end
end