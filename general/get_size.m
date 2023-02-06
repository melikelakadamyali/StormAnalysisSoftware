function total_size = get_size(data)
%size of structured data in MB
names = fieldnames(data);
total_size = 0;
for i=1:numel(names)   
    var = getfield(data,names{i});
    s = (whos('var').bytes)/(1024^2);
    total_size = total_size + s;
end
end