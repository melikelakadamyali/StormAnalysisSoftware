function spt_tracks_change_tracks_time(data)
input_values = inputdlg({'Tracks Time Step:'},'',1,{'0.05'});
if isempty(input_values)==1
    return
else
    time_step = str2double(input_values{1});
    for i = 1:length(data)
        for j=1:length(data{i}.tracks)
            data{i}.tracks{j} = chnage_tracks_time(data{i}.tracks{j},time_step);
        end
    end
end
spt_plot(data);
end

function data = chnage_tracks_time(data,time_step)
for i = 1:size(data,1)
    data(i,1) = time_step*(i-1);
end
end