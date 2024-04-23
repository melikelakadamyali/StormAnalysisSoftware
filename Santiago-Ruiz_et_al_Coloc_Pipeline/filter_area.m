function [data_filter_above,data_filter_below,I] = filter_area(data,min_area)

clusters = extract_clusters(data);

areas = cellfun(@(x) x(1,3),clusters);

I = areas > min_area;

clusters_above = clusters(I);
if ~isempty(clusters_above)
    clusters_above = vertcat(clusters_above{:});
    data_filter_above.x_data = clusters_above(:,1);
    data_filter_above.y_data = clusters_above(:,2);
    data_filter_above.area = clusters_above(:,3);
    if isfield(data,'channel')
        data_filter_above.channel = clusters_above(:,4);
    end
    data_filter_above.name = [data.name,'_area_filter_above_',num2str(min_area)];
    data_filter_above.type = 'loc_list';
else
    data_filter_above = [];
end

clusters_below = clusters(~I);
if isempty(clusters_below)~=1
    clusters_below = vertcat(clusters_below{:});
    data_filter_below.x_data = clusters_below(:,1);
    data_filter_below.y_data = clusters_below(:,2);
    data_filter_below.area = clusters_below(:,3);
    if isfield(data,'channel')
        data_filter_below.channel = clusters_below(:,4);
    end
    data_filter_below.name = [data.name,'_area_filter_below_',num2str(min_area)];
    data_filter_below.type = 'loc_list';
else
    data_filter_below = [];
end

end