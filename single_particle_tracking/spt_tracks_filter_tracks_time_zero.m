function spt_tracks_filter_tracks_time_zero(data)
for i = 1:length(data)
    for j=1:length(data{i}.tracks)
        if check_for_zero(data{i}.tracks{j})
            data{i}.tracks{j} = [];
        end
    end
    data{i}.tracks = data{i}.tracks(~cellfun('isempty',data{i}.tracks));
end
spt_plot(data);
end

function contains_zero = check_for_zero(data)
if any(data(:,1)==0)
    contains_zero = 1;
else
    contains_zero = 0;
end
end