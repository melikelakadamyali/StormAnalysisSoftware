function data_out = calcArea(data)

clusters = extract_clusters(data);

xRef = cellfun(@(x) x(:,1),clusters,'UniformOutput',false);
yRef = cellfun(@(x) x(:,2),clusters,'UniformOutput',false);
shpRef = cellfun(@(x,y) alphaShape(x,y),xRef,yRef,'UniformOutput',false);
CritAlpha = cellfun(@(x) criticalAlpha(x,'one-region'),shpRef,'uniformoutput',false);

x_data = cell(1,length(shpRef));
y_data = cell(1,length(shpRef));
areasClus = cell(1,length(shpRef));
channel = cell(1,length(shpRef));
for i = 1:length(shpRef)
    try
        shpRef{i}.Alpha = CritAlpha{i};
        areas = area(shpRef{i});
    catch
        areas = sum(clusters{i}(:,3));
    end

    x_data{i} = clusters{i}(:,1);
    y_data{i} = clusters{i}(:,2);
    areasClus{i} = repmat(areas,[size(clusters{i},1) 1]);
    if size(clusters{i},2) == 4
        channel{i} = clusters{i}(:,4);
    end
end

data_to_unique(:,1) = vertcat(x_data{:});
data_to_unique(:,2) = vertcat(y_data{:});
data_to_unique(:,3) = vertcat(areasClus{:});
if size(clusters{1},2) == 4
    data_to_unique(:,4) = vertcat(channel{:});
end
[~,Idx] = unique(data_to_unique(:,1:3),'rows');
data_to_unique = data_to_unique(Idx,:);

data_out.x_data = data_to_unique(:,1);
data_out.y_data = data_to_unique(:,2);
data_out.area = data_to_unique(:,3);
data_out.name = data.name;
data_out.type = data.type;
if size(clusters{1},2) == 4
    data_out.channel = data_to_unique(:,4);
end


end