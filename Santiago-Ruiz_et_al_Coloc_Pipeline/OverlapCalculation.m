function newData = OverlapCalculation(data,OverlapPerc,minLocs,minArea)

wb = waitbar(0,['Calculating the percentage of overlap between the two channels per cluster of data set ' num2str(1) '/' num2str(length(data))]);

newData = cell(1,length(data));
for i = 1:length(data)

    if ~isempty(data{i})
        
        Clusters = extract_clusters(data{i});
    
        Data_new = cell(length(Clusters)*2,1);
        for j = 1:length(Clusters)
    
            waitbar((i-1)/length(data)+(j/length(Clusters))/length(data),wb,['Calculating the percentage of overlap between the two channels per cluster of data set ' num2str(i) '/' num2str(length(data))]);
    
            Data = Clusters{j}; % Set up the reference data
            Groups = findgroups(Data(:,4)); % Find unique groups and their number
    
            if numel(unique(Groups)) > 1
                SplitChannels = splitapply(@(x){(x)},Data(:,[1 2 4]),Groups);
    
                PolyshapeCloud = cell(length(SplitChannels),1);
                areaCluster = NaN(length(SplitChannels),1);
                for k = 1:length(SplitChannels)
                    if size(SplitChannels{k},1) > 2
                        alphaShp = alphaShape(SplitChannels{k}(:,1),SplitChannels{k}(:,2));
                        a = criticalAlpha(alphaShp,'all-points');
                        alphaShp.Alpha = a;
    
                        [~, PolyshapeCloud{k}] = FindBorders(alphaShp);
                        areaCluster(k) = area(PolyshapeCloud{k});
                    end
                end
    
                if ~any(cellfun(@isempty,PolyshapeCloud))
                    Intersections = intersect(PolyshapeCloud{1},PolyshapeCloud{2});
    
                    AreaChannels = area(PolyshapeCloud{1});
                    AreaIntersect = area(Intersections);
    
                    PercentageOverlap = AreaIntersect ./ AreaChannels * 100;
    
                else
    
                    PercentageOverlap = 0;
    
                end
    
                if PercentageOverlap >= OverlapPerc
    
                    Data_new{(j-1)*2+1} = Data;
    
                else
    
                    if size(SplitChannels{1},1) > minLocs && areaCluster(1) > minArea 
                        Data_new{(j-1)*2+1} = horzcat(SplitChannels{1}(:,1:2),repmat(areaCluster(1),[size(SplitChannels{1},1) 1]),SplitChannels{1}(:,3));
                    end
                    if size(SplitChannels{2},1) > minLocs && areaCluster(2) > minArea 
                        Data_new{j*2} = horzcat(SplitChannels{2}(:,1:2),repmat(areaCluster(2),[size(SplitChannels{2},1) 1]),SplitChannels{2}(:,3));
                    end
    
                end
    
            else
    
                Data_new{(j-1)*2+1} = Data;
    
            end
    
        end
    
        Data_new = Data_new(~cellfun('isempty',Data_new));
        Data_new = vertcat(Data_new{:});
    
        newData{i}.x_data = Data_new(:,1);
        newData{i}.y_data = Data_new(:,2);
        newData{i}.area = Data_new(:,3);
        newData{i}.channel = Data_new(:,4);
        newData{i}.type = 'loc_list';
        newData{i}.name = [data{i}.name '_SplitClusters'];

    end

end

close(wb)

end