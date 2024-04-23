function unpiled_data = unpile_data(data,name)
f = waitbar(0,'Unpiling Data');

unpiled_data = [];
for i = 1:length(data)
    waitbar(i/length(data),f,'Unpiling Data');

    DataConcat = horzcat(data{i}.x_data,data{i}.y_data,data{i}.area);
    DataSplit = splitapply(@(x){(x)},DataConcat(:,1:3),data{i}.channel);

    for j = 1:length(DataSplit)
        DataSplit_strct{j}.x_data = DataSplit{j}(:,1);
        DataSplit_strct{j}.y_data = DataSplit{j}(:,2);
        DataSplit_strct{j}.area = DataSplit{j}(:,3);
        DataSplit_strct{j}.channel = repmat(j,[size(DataSplit{j},1) 1]);
        DataSplit_strct{j}.name = [data{i}.name '_' char(name{j})];
        DataSplit_strct{j}.type = 'loc_list';

        unpiled_data = horzcat(unpiled_data,DataSplit_strct(j));
    end
end

close(f)
end