function clusters = extract_clusters(data)

% Extract the reference data and its individual clusters
try
    DataArray = horzcat(data.x_data,data.y_data,data.area,data.channel); % Set up the reference data
catch
    DataArray = horzcat(data.x_data,data.y_data,data.area); % Set up the reference data
end

[~,Idx] = unique(DataArray(:,1:3),'rows');
DataArray = DataArray(Idx,:);

Groups = findgroups(DataArray(:,3)); % Find unique groups and their number
try
    clusters = splitapply(@(x){(x)},DataArray(:,1:4),Groups);
catch
    clusters = splitapply(@(x){(x)},DataArray(:,1:3),Groups);
end

end