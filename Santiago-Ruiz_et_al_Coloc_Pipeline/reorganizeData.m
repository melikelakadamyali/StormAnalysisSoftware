function [newData1,newData2,newData3] = reorganizeData(data1,data2,data3,Filter)

newData1 = cell(1,length(data1));
newData2 = cell(1,length(data1));
newData3 = cell(1,length(data1));
for i = 1:length(data1)
    
    if ~isempty(data1{i})
        Clusters1 = extract_clusters(data1{i});
    end
    
    if ~isempty(data2{i})
        Clusters2 = extract_clusters(data2{i});
    end
    
    if ~isempty(data3{i})
        Clusters3 = extract_clusters(data3{i});
    end

    Areas1 = cellfun(@(x) x(1,3),Clusters1);
    Areas2 = cellfun(@(x) x(1,3),Clusters2);
    Areas3 = cellfun(@(x) x(1,3),Clusters3);

    nanoClusters = vertcat(Clusters1(Areas1<=Filter(1)),Clusters2(Areas2<=Filter(1)),Clusters3(Areas3<=Filter(1)));
    nanoClusters = vertcat(nanoClusters{:});

    midClusters = vertcat(Clusters1(Areas1>Filter(1) & Areas1<=Filter(2)),Clusters2(Areas2>Filter(1) & Areas2<=Filter(2)),Clusters3(Areas3>Filter(1) & Areas3<=Filter(2)));
    midClusters = vertcat(midClusters{:});

    macroClusters = vertcat(Clusters1(Areas1>Filter(2)),Clusters2(Areas2>Filter(2)),Clusters3(Areas3>Filter(2)));
    macroClusters = vertcat(macroClusters{:});

    if ~isempty(nanoClusters)
        newData1{i}.x_data = nanoClusters(:,1);
        newData1{i}.y_data = nanoClusters(:,2);
        newData1{i}.area = nanoClusters(:,3);
        newData1{i}.channel = nanoClusters(:,4);
        newData1{i}.type = 'loc_list';
        try
            newData1{i}.name = data1{i}.name;
        catch
            newData1{i}.name = ['Image' num2str(i) '_NanoClusters'];
        end
    end

    if ~isempty(midClusters)
        newData2{i}.x_data = midClusters(:,1);
        newData2{i}.y_data = midClusters(:,2);
        newData2{i}.area = midClusters(:,3);
        newData2{i}.channel = midClusters(:,4);
        newData2{i}.type = 'loc_list';
        try
            newData2{i}.name = data2{i}.name;
        catch
            newData2{i}.name = ['Image' num2str(i) '_MidClusters'];
        end

    end

    if ~isempty(macroClusters)
        newData3{i}.x_data = macroClusters(:,1);
        newData3{i}.y_data = macroClusters(:,2);
        newData3{i}.area = macroClusters(:,3);
        newData3{i}.channel = macroClusters(:,4);
        newData3{i}.type = 'loc_list';
        try
            newData3{i}.name = data3{i}.name;
        catch
            newData3{i}.name = ['Image' num2str(i) '_MacroClusters'];
        end
    end

end

end