function piled_data = pile_data(data,name,delname)

delname = cellfun(@(x) append("_",x),delname,'UniformOutput',false);
delname = horzcat(delname{:});

x = cell(1,length(data));
y = cell(1,length(data));
area = cell(1,length(data));
Channel = cell(1,length(data));
for i = 1:length(data)
    if ~isempty(data{i})
        x{i} = data{i}.x_data;
        y{i} = data{i}.y_data;
        area{i} = data{i}.area;
        Channel{i} = repmat(i,[length(data{i}.x_data) 1]);
    end
end
x = x(~cellfun('isempty',x));
y = y(~cellfun('isempty',y));
area = area(~cellfun('isempty',area));
Channel = Channel(~cellfun('isempty',Channel));

if size(x,2) ~= 0
    x = vertcat(x{:});
    y = vertcat(y{:});
    area = vertcat(area{:});
    channel = vertcat(Channel{:});
    
    data_to_unique(:,1) = x;
    data_to_unique(:,2) = y;
    data_to_unique(:,3) = area;
    data_to_unique(:,4) = channel;
    [~,Idx] = unique(data_to_unique(:,1:3),'rows');
    data_to_unique = data_to_unique(Idx,:);
    
    piled_data.x_data = data_to_unique(:,1);
    piled_data.y_data = data_to_unique(:,2);
    piled_data.area = data_to_unique(:,3);
    piled_data.channel = data_to_unique(:,4);
    oldname = erase(data{1}.name,delname);
    piled_data.name = [oldname '_' char(name)];
    piled_data.type = 'loc_list';
else
    piled_data.x_data = [];
    piled_data.y_data = [];
    piled_data.area = [];
    piled_data.channel = [];
    piled_data.name = '';
    piled_data.type = 'loc_list';
end

end