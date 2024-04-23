function [LocsTable,AllClusters] = calcLocs(data)

LocsTable = cell(1,length(data));
AllClusters = cell(1,length(data));
for i = 1:length(data)

    if ~isempty(data{i})
    
        Clusters = extract_clusters(data{i});
    
        LocsTable{i} = NaN(length(Clusters),8);
        for j = 1:length(Clusters)
            LocsTable{i}(j,1) = j;
            LocsTable{i}(j,2) = Clusters{j}(1,3);
            LocsTable{i}(j,3) = size(Clusters{j},1);
            LocsTable{i}(j,4) = numel(find(Clusters{j}(:,4)==1));
            LocsTable{i}(j,5) = LocsTable{i}(j,4) / LocsTable{i}(j,2);
            LocsTable{i}(j,6) = numel(find(Clusters{j}(:,4)==2));
            LocsTable{i}(j,7) = LocsTable{i}(j,6) / LocsTable{i}(j,2);
            LocsTable{i}(j,8) = (LocsTable{i}(j,6) - LocsTable{i}(j,4)) / LocsTable{i}(j,3);
        end
        AllClusters{i} = Clusters;

    end
    
end

end