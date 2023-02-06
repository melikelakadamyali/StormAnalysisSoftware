function data_rotate = loc_list_rotate_cm(data)

input_values = inputdlg({'Enter the degrees with which you want to rotate the image'},'Rotation input',1,{'180'});
degrees = str2double(input_values{1});

data_rotate = cell(1,length(data));
for i = 1:length(data)
    data_rotate{i} = loc_list_rotate(data{i},degrees);
end
end

function data_rotate = loc_list_rotate(data,degrees)

Coords = [data.x_data data.y_data]; % Extract the coordinates of the colocalized channel

center = repmat([mean(Coords(:,1)) mean(Coords(:,2))], length(Coords),1); % Extract the center of mass
Coords_Corr = Coords - center; % shift points in the plane so that the center of rotation is at the origin

theta = deg2rad(degrees);
R = [cos(theta) -sin(theta); sin(theta) cos(theta)];

Coords_Rotated = R*Coords_Corr';           % apply the rotation about the origin
Coords_final = Coords_Rotated' + center;   % shift again so the origin goes back to the desired center of rotation

data_rotate.x_data = Coords_final(:,1);
data_rotate.y_data = Coords_final(:,2);
data_rotate.area = data.area;
data_rotate.name = [data.name,'_Rotated' num2str(degrees)];
data_rotate.type = 'loc_list';
end